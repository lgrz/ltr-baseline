#!/bin/bash

set -ue

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE=$SPATH/..
LGBM=$SPATH/../bin/lightgbm

mkdir -p model run eval

dat="$SPATH/dat"

trees=1000
leaves=63
eta=0.05
name="lgbm.lrank.${trees}.${leaves}.${eta}"
for i in {1..5}; do
suffix="${name}.fold${i}"
qrels="${dat}/MSLR-WEB10K/Fold${i}/test.qrels"

$LGBM \
    app=lambdarank \
    save_binary=true \
    boosting=gbdt \
    num_trees=$trees \
    num_leaves=$leaves \
    learning_rate=$eta \
    metric=ndcg \
    eval_at=1,5,10,20 \
    early_stopping_round=$trees \
    output_model="model/model.${suffix}" \
    data="${dat}/MSLR-WEB10K/Fold${i}/train.txt.xgb" \
    valid_data="${dat}/MSLR-WEB10K/Fold${i}/vali.txt.xgb"

$LGBM \
    task=predict \
    data="${dat}/MSLR-WEB10K/Fold${i}/test.txt.xgb" \
    input_model="model/model.${suffix}" \
    output_result="run/score.${suffix}"

paste -d' ' run/score.${suffix} $qrels \
    | awk '{print $2, "Q0", $4, 0, $1, "lgbm"}' \
    | sort -k1n -k5nr \
    | $BASE/script/trecrank.awk > run/run.${suffix}
done

cat $SPATH/run/run.${name}.fold? > $SPATH/run/run.all.${name}
$BASE/script/eval.sh $dat/all.test.qrels $SPATH/run/run.all.${name} > $SPATH/eval/eval.all.${name}
