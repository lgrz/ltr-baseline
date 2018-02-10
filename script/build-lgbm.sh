#!/bin/bash

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BIN=$SPATH/../bin

cd $SPATH/../ext/lgbm
mkdir -p build && cd build
# cmake -DUSE_GPU=1 \
#     -DOpenCL_LIBRARY=/usr/local/cuda/lib64/libOpenCL.so \
#     -DOpenCL_INCLUDE_DIR=/usr/local/cuda/include \
#     -DBoost_INCLUDE_DIR=$HOME/local/include
cmake ..
make -j8
cp $SPATH/../ext/lgbm/lightgbm $BIN
