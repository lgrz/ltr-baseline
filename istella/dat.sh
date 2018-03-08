#!/usr/bin/env bash

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE=$SPATH/..
DATDIR=$SPATH/dat

cd $DATDIR
T=test.txt
TR=train.txt

(test ! -f $T \
    || test ! -f $TR) \
    && echo "Data files required in $DATDIR" 1>&2 \
    && exit 1

# xgboost, lgbm
cut -d' ' -f1,3- $T > $T.xgb
awk '{sub(/qid:/, "", $2); print $2;}' $T | uniq -c | awk '{print $1}' > $T.xgb.group
cut -d' ' -f1,3- $TR > $TR.xgb
awk '{sub(/qid:/, "", $2); print $2;}' $TR | uniq -c | awk '{print $1}' > $TR.xgb.group
cp $T.xgb.group $T.xgb.query
cp $TR.xgb.group $TR.xgb.query

# jforest
$BASE/script/jfmkbin.sh $DATDIR $T $TR

$BASE/script/svm2qrel.sh $T > test.qrels
