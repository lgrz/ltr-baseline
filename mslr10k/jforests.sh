#!/bin/bash

set -ue

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE=$SPATH/..
JF=$SPATH/../bin/jforests

mkdir -p model run eval

dat="$SPATH/dat"

trees=1000
leaves=63
eta=0.05
name="jf.lmart.${trees}.${leaves}.${eta}"
for i in {1..5}; do
suffix="${name}.fold${i}"
qrels="${dat}/MSLR-WEB10K/Fold${i}/test.qrels"

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
    --train-file $dat/MSLR-WEB10K/Fold${i}/train.bin \
    --validation-file $dat/MSLR-WEB10K/Fold${i}/vali.bin \
    --output-model model/model.${suffix}

$JF \
    --cmd=predict \
    --ranking \
    --model-file model/model.${suffix} \
    --tree-type RegressionTree \
    --test-file $dat/MSLR-WEB10K/Fold${i}/test.bin \
    --output-file run/score.${suffix}

rm ranking.properties

paste -d' ' run/score.${suffix} $qrels \
    | awk '{print $2, "Q0", $4, 0, $1, "jforests"}' \
    | sort -k1n -k5nr \
    | $BASE/script/trecrank.awk > run/run.${suffix}
done

cat $SPATH/run/run.${name}.fold? > $SPATH/run/run.all.${name}
$BASE/script/eval.sh $dat/all.test.qrels $SPATH/run/run.all.${name} > $SPATH/eval/eval.all.${name}
