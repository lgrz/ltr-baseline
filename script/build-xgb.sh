#!/bin/bash

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BIN=$SPATH/../bin

cd $SPATH/../ext/xgboost
make -j8
cp $SPATH/../ext/xgboost/xgboost $BIN
