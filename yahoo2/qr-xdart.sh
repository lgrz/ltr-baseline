#!/bin/bash

set -ue

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE=$SPATH/..
QR=$SPATH/../bin/quicklearn

mkdir -p model run eval

dat="$SPATH/dat"
qrels=$dat/set2.test.qrels

trees=1000
leaves=63
eta=0.05
name="qr.xdart.${trees}.${leaves}.${eta}"

$QR \
    --algo dart \
    --num-trees $trees \
    --num-leaves $leaves \
    --shrinkage $eta \
    --end-after-rounds $trees \
    --min-leaf-support 10 \
    --sample-type UNIFORM \
    --normalize-type TREE \
    --adaptive-type PLUSHALF_RESET_LB1_UBRD \
    --rate-drop 0.015 \
    --keep-drop \
    --best-on-train \
    --train $dat/set2.train.txt \
    --valid $dat/set2.valid.txt \
    --model-out model/model.${name}

$QR \
    --test $dat/set2.test.txt \
    --model-in model/model.${name} \
    --scores run/score.${name}

paste -d' ' run/score.${name} $qrels \
    | awk '{print $2, "Q0", $4, 0, $1, "qr-xdart"}' \
    | sort -k1n -k5nr \
    | $BASE/script/trecrank.awk > run/run.${name}

$BASE/script/eval.sh $qrels run/run.${name} > eval/eval.${name}
