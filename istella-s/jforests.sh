#!/bin/bash

set -ue

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE=$SPATH/..
JF=$SPATH/../bin/jforests

mkdir -p model run eval

dat="$SPATH/dat"
qrels=$dat/test.qrels

trees=1000
leaves=63
eta=0.05
name="jf.lmart.${trees}.${leaves}.${eta}"

echo "
learning.algorithm=LambdaMART-RegressionTree
learning.evaluation-metric=NDCG
trees.num-leaves=$leaves
trees.min-instance-percentage-per-leaf=0.25
boosting.learning-rate=$eta
boosting.num-trees=$trees
boosting.early-stopping-tolerance=0.0
params.print-intermediate-valid-measurements=true
" > ranking.properties

$JF --cmd=train \
    --ranking \
    --config-file ranking.properties \
    --train-file $dat/train.bin \
    --validation-file $dat/vali.bin \
    --output-model model/model.${name}

$JF \
    --cmd=predict \
    --ranking \
    --model-file model/model.${name} \
    --tree-type RegressionTree \
    --test-file $dat/test.bin \
    --output-file run/score.${name}

rm ranking.properties

paste -d' ' run/score.${name} $qrels \
    | awk '{print $2, "Q0", $4, 0, $1, "jforests"}' \
    | sort -k1n -k5nr \
    | $BASE/script/trecrank.awk > run/run.${name}

$BASE/script/eval.sh $qrels run/run.${name} > eval/eval.${name}
