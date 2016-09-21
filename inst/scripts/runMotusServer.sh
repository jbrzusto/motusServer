#!/bin/bash

if [[ "$1" == "-h" ]]; then cat <<EOF

Usage: runMotusServer.sh [-h] [-e]

Run the motus server which handles incoming data emails and other
moves of data to /sgm/incoming

-h : show usage
-e : embargo; do not process new emails.  Normally, emails are
moved to /sgm/incoming as received.  With this option, emails are
written to /sgm/embargoed_incoming instead, which prevents them
from being processed.  Files or folders moved to /sgm/incoming
in other ways (e.g. from a shell "mv" command) are still processed
as usual.

EOF
    exit 1;
fi

if [[ "$1" == "-e"]]; then
    rm -f /sgm/EMBARGO
else
    touch /sgm/EMBARGO
fi

## restart the process whenever it dies, allowing a
## short interval to prevent thrashing

while (( 1 )); do
   nohup Rscript -e 'library(motus);server(tracing=FALSE)'
   sleep 15
done
