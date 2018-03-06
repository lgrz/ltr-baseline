#!/bin/bash

set -eu

if [ $# -lt 2 ]; then
    echo "usage: $0 <qrels> [runfile ...]" >&2
    exit 1
fi

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BIN=$SPATH/../bin
BASE=$SPATH/..
QRELS=$1; shift
TMP1=$(mktemp)
TMP2=$(mktemp)
TMP3=$(mktemp)
TMP4=$(mktemp)
TMPNAM=$(mktemp)
MAXJ=$(awk '{print $4}' $QRELS | sort -nu | tail -1)
HYPDIR=$(mktemp -d)

# ERR, NDCG
prev=0
for k in 5 10 20; do
for r in $@; do
suffix=$(basename $r)
ndcg="$HYPDIR/ndcg${k}.${suffix}"
err="$HYPDIR/err${k}.${suffix}"
$SPATH/gdeval.pl -j $MAXJ -k $k $QRELS $r \
    | sed -e 1d -e \$d \
    | awk -F, -v ndcg=$ndcg -v err=$err '{print $2,$3 > ndcg; print $2,$4 > err;}' 
if [ $prev -eq 0 ]; then
    echo "qid" > $TMPNAM
    cp $ndcg $TMP2
    cp $err $TMP4
else
    join $TMP2 $ndcg > $TMP1
    cp $TMP1 $TMP2
    join $TMP4 $err > $TMP3
    cp $TMP3 $TMP4
fi
echo $suffix >> $TMPNAM
prev=1
done
prev=0
hdr=$(cat $TMPNAM | xargs | sed 's/run\.//g')
echo "$hdr" > $TMP1
echo "$hdr" > $TMP3
cat $TMP2 >> $TMP1
cp $TMP1 "$HYPDIR/b.ndcg.${k}"
cat $TMP4 >> $TMP3
cp $TMP3 "$HYPDIR/b.err.${k}"
done

# RBP
prev=0
for p in 0.8 0.9; do
for r in $@; do
suffix=$(basename $r)
rbp="$HYPDIR/rbp${p}.${suffix}"
$BIN/rbp_eval -WHTq -p $p $QRELS $r | awk '{print $4,$8}' > $rbp
if [ $prev -eq 0 ]; then
    echo "qid" > $TMPNAM
    cp $rbp $TMP2
else
    join $TMP2 $rbp > $TMP1
    cp $TMP1 $TMP2
fi
echo $suffix >> $TMPNAM
prev=1
done
prev=0
hdr=$(cat $TMPNAM | xargs | sed 's/run\.//g')
echo "$hdr" > $TMP1
cat $TMP2 >> $TMP1
cp $TMP1 "$HYPDIR/b.rbp.${p}"
done

rm $TMP1 $TMP2 $TMP3 $TMP4 $TMPNAM
echo "result files are at: $HYPDIR"
