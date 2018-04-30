#!/bin/bash

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BINDIR=$SPATH/../bin

echo -n "#!/usr/bin/env bash
SPATH=\"\$( cd \"\$( dirname \"\${BASH_SOURCE[0]}\" )\" && pwd )\"
java -jar \$SPATH/../ext/ranklib/bin/RankLib.jar \"\$@\"
" > $BINDIR/ranklib
chmod +x $BINDIR/ranklib
