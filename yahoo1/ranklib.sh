#!/bin/bash

set -ue

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE=$SPATH/..
RL=$SPATH/../bin/ranklib

mkdir -p model run eval

dat="$SPATH/dat"
qrels=$dat/set1.test.qrels

trees=1000
leaves=63
eta=0.05
name="ranklib.lmart.${trees}.${leaves}.${eta}"

$RL -ranker 6 \
    -tree $trees \
    -leaf $leaves \
    -shrinkage $eta \
    -mls 1 \
    -estop 100 \
    -metric2t NDCG@10 \
    -train $dat/set1.train.txt.dense \
    -validate $dat/set1.valid.txt.dense \
    -save model/model.${name}

$RL \
    -rank $dat/set1.test.txt.dense \
    -load model/model.${name} \
    -score run/tmp.${name}

awk '{print $3}' run/tmp.${name} > run/score.${name}
rm -f run/tmp.${name}

paste -d' ' run/score.${name} $qrels \
    | awk '{print $2, "Q0", $4, 0, $1, "jforests"}' \
    | sort -k1n -k5nr \
    | $BASE/script/trecrank.awk > run/run.${name}

$BASE/script/eval.sh $qrels run/run.${name} > eval/eval.${name}
