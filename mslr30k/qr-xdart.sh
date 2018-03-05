#!/bin/bash

set -ue

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE=$SPATH/..
QR=$SPATH/../bin/quicklearn

mkdir -p model run eval

dat="$SPATH/dat"

trees=1000
leaves=63
eta=0.05
name="qr.xdart.${trees}.${leaves}.${eta}"
for i in {1..5}; do
suffix="${name}.fold${i}"
qrels="${dat}/MSLR-WEB30K/Fold${i}/test.qrels"

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
    --train $dat/MSLR-WEB30K/Fold${i}/train.txt \
    --valid $dat/MSLR-WEB30K/Fold${i}/vali.txt \
    --model-out model/model.${suffix}

$QR \
    --test $dat/MSLR-WEB30K/Fold${i}/test.txt \
    --model-in model/model.${suffix} \
    --scores run/score.${suffix}

paste -d' ' run/score.${suffix} $qrels \
    | awk '{print $2, "Q0", $4, 0, $1, "xdart"}' \
    | sort -k1n -k5nr \
    | $BASE/script/trecrank.awk > run/run.${suffix}
done

cat $SPATH/run/run.${name}.fold? > $SPATH/run/run.all.${name}
$BASE/script/eval.sh $dat/all.test.qrels $SPATH/run/run.all.${name} > $SPATH/eval/eval.all.${name}
