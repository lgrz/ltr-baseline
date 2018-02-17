#!/bin/bash

set -ue

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE=$SPATH/..
QR=$SPATH/../bin/quicklearn

mkdir -p model run eval

dat="$SPATH/dat"
qrels=$dat/set1.test.qrels

trees=1000
leaves=63
eta=0.05
name="qr.lmart.${trees}.${leaves}.${eta}"

$QR \
    --algo lambdamart \
    --num-trees $trees \
    --num-leaves $leaves \
    --shrinkage $eta \
    --end-after-rounds $trees \
    --min-leaf-support 10 \
    --train $dat/set1.train.txt \
    --valid $dat/set1.valid.txt \
    --model-out model/model.${name}

$QR \
    --test $dat/set1.test.txt \
    --model-in model/model.${name} \
    --scores run/score.${name}

paste -d' ' run/score.${name} $qrels \
    | awk '{print $2, "Q0", $4, 0, $1, "lgbm"}' \
    | sort -k1n -k5nr \
    | $BASE/script/trecrank.awk > run/run.${name}

$BASE/script/eval.sh $qrels run/run.${name} > eval/eval.${name}
