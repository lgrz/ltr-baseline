#!/usr/bin/env bash

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE=$SPATH/..
DATDIR=$SPATH/dat
MSLRDIR=$DATDIR/MSLR-WEB10K

if [ ! -d $MSLRDIR ]; then
    echo "Missing data files: $MSLRDIR" 1>&2
    exit 1
fi

cd $MSLRDIR
for i in Fold?; do
    cd $i
    T=train.txt
    V=vali.txt
    TR=test.txt
    cut -d' ' -f1,3- $T > $T.xgb
    awk '{sub(/qid:/, "", $2); print $2;}' $T | uniq -c | awk '{print $1}' > $T.xgb.group
    cut -d' ' -f1,3- $V > $V.xgb
    awk '{sub(/qid:/, "", $2); print $2;}' $V | uniq -c | awk '{print $1}' > $V.xgb.group
    cut -d' ' -f1,3- $TR > $TR.xgb
    awk '{sub(/qid:/, "", $2); print $2;}' $TR | uniq -c | awk '{print $1}' > $TR.xgb.group
    cp $T.xgb.group $T.xgb.query
    cp $V.xgb.group $V.xgb.query
    cp $TR.xgb.group $TR.xgb.query
    $BASE/script/jfmkbin.sh . $T $V $TR
    $BASE/script/svm2qrel.sh $TR > test.qrels
    cd -
done

cat Fold?/test.qrels > $DATDIR/all.test.qrels
