#!/usr/bin/env bash

set -ue

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE=$SPATH/..
XGB=$SPATH/../bin/xgboost

mkdir -p model run eval

dat="$SPATH/dat"

trees=1000
depth=6
eta=0.05
name="xgb.gbdt.${trees}.${depth}.${eta}"
for i in {1..5}; do
suffix="${name}.fold${i}"
qrels="${dat}/MSLR-WEB30K/Fold${i}/test.qrels"

# if doing multi:softprob
num_classes=$(awk '{print $4}' $qrels | sort -nu | wc -l)

echo "
booster=gbtree
num_round=$trees
max_depth=$depth
objective=\"multi:softprob\"
num_class=$num_classes
eta=$eta
eval_metric=mlogloss
model_out=\"model/model.${suffix}\"
save_period=0
data=\"${dat}/MSLR-WEB30K/Fold${i}/train.txt.xgb\"
eval[test]=\"${dat}/MSLR-WEB30K/Fold${i}/vali.txt.xgb\"
test:data=\"${dat}/MSLR-WEB30K/Fold${i}/test.txt.xgb\"
name_pred=\"run/score.${suffix}\"
" > xgb-train.conf

$XGB xgb-train.conf

$XGB xgb-train.conf task=pred \
    model_in=model/model.${suffix}

rm xgb-train.conf

python $BASE/script/softprob_comb.py run/score.${suffix} $num_classes

paste -d' ' run/score.${suffix}.softprob $qrels \
    | awk '{print $2, "Q0", $4, 0, $1, "xgb"}' \
    | sort -k1n -k5nr \
    | $BASE/script/trecrank.awk > run/run.${suffix}
done

cat $SPATH/run/run.${name}.fold? > $SPATH/run/run.all.${name}
$BASE/script/eval.sh $dat/all.test.qrels $SPATH/run/run.all.${name} > $SPATH/eval/eval.all.${name}
