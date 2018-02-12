#!/bin/bash

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
JF=$SPATH/../bin/jforests

if [ $# -lt 2 ]; then
    echo "usage: $0 <path> [file ...]" >&2
    exit 1
fi

dat=$1
shift;
fileargs=$(echo "$@" | awk '{ gsub(/ /, " --file "); print "--file", $0 }')
echo $fileargs
$JF \
    --cmd=generate-bin \
    --ranking \
    --folder $dat \
    $fileargs
