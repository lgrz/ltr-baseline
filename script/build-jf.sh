#!/bin/bash

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BINDIR=$SPATH/../bin

echo -n "#!/usr/bin/env bash
SPATH=\"\$( cd \"\$( dirname \"\${BASH_SOURCE[0]}\" )\" && pwd )\"
java -jar \$SPATH/../ext/jforests/releases/jforests-0.5.jar \"\$@\"
" > $BINDIR/jforests
chmod +x $BINDIR/jforests
