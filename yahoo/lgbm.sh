#!/bin/bash

set -ue

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE=$SPATH/..
LGBM=$SPATH/../bin/lightgbm

mkdir -p model run eval

dat="$SPATH/dat"
qrels=$dat/set1.test.qrels

trees=1000
leaves=63
eta=0.05
name="lgbm.gbdt.${trees}.${leaves}.${eta}"

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
    output_model="model/${name}.model" \
    data="${dat}/set1.train.txt.xgb" \
    valid_data="${dat}/set1.valid.txt.xgb"

$LGBM \
    task=predict \
    data="${dat}/set1.test.txt.xgb" \
    input_model="model/${name}.model" \
    output_result="run/${name}.score"

paste -d' ' run/${name}.score $qrels \
    | awk '{print $2, "Q0", $4, 0, $1, "lgbm"}' \
    | sort -k1n -k5nr \
    | $BASE/tools/trecrank.awk > run/run.${name}

$BASE/tools/eval.sh $qrels run/run.${name} > eval/eval.${name}
