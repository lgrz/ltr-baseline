#!/bin/bash

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

test ! -f "$SPATH/rbp_eval" \
    && echo "run \`cd $SPATH && make\` first" 1>&2 \
    && exit 1

if [ $# -ne 2 ]; then
    echo "usage: $0 <qrels> <runfile>" >&2
    exit 1
fi

QRELS=$1
TMP5=$(mktemp -p .)
TMP10=$(mktemp -p .)
TMP20=$(mktemp -p .)
MAXJ=$(awk '{print $4}' $QRELS | sort -nu | tail -1)
($SPATH/gdeval.pl -k 5 -j $MAXJ $QRELS $2 | tail -1 > $TMP5)&
($SPATH/gdeval.pl -k 10 -j $MAXJ $QRELS $2 | tail -1 > $TMP10)&
($SPATH/gdeval.pl -k 20 -j $MAXJ $QRELS $2 | tail -1 > $TMP20)&
wait
echo -n "ERR_5 "
awk -F, '{printf "%.4f\n", $4}' $TMP5
echo -n "ERR_10 "
awk -F, '{printf "%.4f\n", $4}' $TMP10
echo -n "ERR_20 "
awk -F, '{printf "%.4f\n", $4}' $TMP20
echo -n "NDCG_5 "
awk -F, '{printf "%.4f\n", $3}' $TMP5
echo -n "NDCG_10 "
awk -F, '{printf "%.4f\n", $3}' $TMP10
echo -n "NDCG_20 "
awk -F, '{printf "%.4f\n", $3}' $TMP20
rm $TMP5 $TMP10 $TMP20
$SPATH/rbp_eval -HW -p 0.8 $QRELS $2 | awk '{print "RBP_08", $8 $9}'
$SPATH/rbp_eval -HW -p 0.9 $QRELS $2 | awk '{print "RBP_09", $8 $9}'
