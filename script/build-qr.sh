#!/bin/bash

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BIN=$SPATH/../bin

cd $SPATH/../ext/quickrank
mkdir -p build && cd build
cmake ..
make -j8
cp $SPATH/../ext/quickrank/bin/quicklearn $BIN
