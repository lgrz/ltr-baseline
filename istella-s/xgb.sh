#!/usr/bin/env bash

set -ue

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE=$SPATH/..
XGB=$SPATH/../bin/xgboost

mkdir -p model run eval

dat="$SPATH/dat"
qrels=$dat/test.qrels

trees=1000
depth=6
eta=0.05
name="xgb.gbtree.${trees}.${depth}.${eta}"

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
model_out=\"model/${name}.model\"
save_period=0
data=\"${dat}/train.txt.xgb\"
eval[test]=\"${dat}/vali.txt.xgb\"
test:data=\"${dat}/test.txt.xgb\"
name_pred=\"run/score.${name}\"
" > xgb-train.conf

$XGB xgb-train.conf

$XGB xgb-train.conf task=pred \
    model_in=model/${name}.model
rm xgb-train.conf

python $BASE/script/softprob_comb.py run/score.${name} $num_classes

paste -d' ' run/score.${name}.softprob $qrels \
    | awk '{print $2, "Q0", $4, 0, $1, "xgb"}' \
    | sort -k1n -k5nr \
    | $BASE/script/trecrank.awk > run/run.${name}

$BASE/script/eval.sh $qrels run/run.${name} > eval/eval.${name}
