#!/usr/bin/env bash

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE=$SPATH/..
DATDIR=$SPATH/dat

cd $DATDIR
T=set1.test.txt
V=set1.valid.txt
TR=set1.train.txt

(test ! -f $T \
    || test ! -f $V \
    || test ! -f $TR) \
    && echo "Data files required in $DATDIR" 1>&2 \
    && exit 1

# xgboost, lgbm
cut -d' ' -f1,3- $T > $T.xgb
awk '{sub(/qid:/, "", $2); print $2;}' $T | uniq -c | awk '{print $1}' > $T.xgb.group
cut -d' ' -f1,3- $V > $V.xgb
awk '{sub(/qid:/, "", $2); print $2;}' $V | uniq -c | awk '{print $1}' > $V.xgb.group
cut -d' ' -f1,3- $TR > $TR.xgb
awk '{sub(/qid:/, "", $2); print $2;}' $TR | uniq -c | awk '{print $1}' > $TR.xgb.group
cp $T.xgb.group $T.xgb.query
cp $V.xgb.group $V.xgb.query
cp $TR.xgb.group $TR.xgb.query

# jforest
$BASE/script/jfmkbin.sh $DATDIR $T $V $TR

$BASE/script/svm2qrel.sh $T > set1.test.qrels
