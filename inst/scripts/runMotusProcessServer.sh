#!/bin/bash
#
# run a motus processing server
#

# assume no tracing

function show_usage {
            cat <<EOF

Usage: runMotusProcessServer.sh [-h] [-t] [N]

Run a motus process server that deals with batches of files.

   -h : show usage

   -t enable tracing, so run in foreground.  Program will enter the
      debugger before each job step.

   N [optional] assign this process to queue N, which must be a
      positive integer.  If not specified, uses the first N in 1..8
      for which /sgm/processServerN.pid does not exist.  If N > 100,
      runs as a high priority server, for short fast jobs entered
      into /sgm/priority.  A priority server doesn't handle uploaded
      data, and won't claim jobs from /sgm/queue/0

EOF
            exit 1;
}

TRACE=0
N=0

while [[ "$1" != "" ]]; do
    case "$1" in
        -t)
            TRACE=1
            ;;

        [0-9]*)
            N=$1
            if [[ $N -lt 1 ]]; then
                echo If specified, N must be positive
                exit 1
            fi
            ;;

        -h|*)
            show_usage
            ;;
        esac
    shift
done

## grab the first available queue number if none specified

export SPID=$$;

if [[ $N == 0 ]]; then
    ## find an unused queue

    for i in `seq 1 8`; do
        ## We use a lock on /sgm/locks/queueN to atomically test
        ## existence of and create /sgm/processServerN.pid
        export i=$i
        (
            flock -n 9 || exit 1
            if [[ ! -s /sgm/processServer$i.pid ]]; then
                echo $SPID > /sgm/processServer$i.pid ;
                exit 0;
            fi
            exit 1;
        ) 9>/sgm/locks/queue$i
        rv=$?
        if [[ $rv == 0 ]]; then
            N=$i;
            break
        fi
    done;
else
    PIDFILE=/sgm/processServer$N.pid
    if [[ -s $PIDFILE ]]; then
        OLDPID=`cat $PIDFILE`
        if [[ -d /proc/$OLDPID ]]; then
            cat <<EOF
There is already a server running for queue $N.
Not starting another one.
EOF
            exit 1;
        fi
        echo $SPID > $PIDFILE
    fi
fi

if [[ $N == 0 ]]; then
    cat <<EOF

There are servers running for all available queues (1..8).
Not running another one.

EOF
    exit 1
fi

## cleanup handler

function onExit {
## cleanup the pid file, and possibly the temporary directory
    rm -f /sgm/processServer$N.pid
    if [[ $TRACE != 0 && "$MYTMPDIR" =~ /tmp/tmp* ]]; then
        rm -rf "$MYTMPDIR"
    fi

    ## delete receiver locks held by this process
    sqlite3 /sgm_local/server.sqlite "pragma busy_timeout=10000; delete from symLocks where owner=$SPID" > /dev/null
}

## call the cleanup handler on exit

trap onExit EXIT

echo $$ > /sgm/processServer$N.pid

if [[ $N -lt 100 ]]; then
    killFile=/sgm/queue/0/kill$N
else
    killFile=/sgm/priority/kill$N
fi
rm -f $killFile

## restart the process whenever it dies, allowing a
## short interval to prevent thrashing

if [[ $TRACE == 0 ]]; then
    while (( 1 )); do
        echo running server for queue $N
        nohup Rscript -e "library(motusServer);processServer($N, tracing=FALSE)" >> /sgm/logs/process$N.txt 2>&1

        ## Kill off the inotifywait process; it's in our process group.
        ## This should happen internally, but might not.
        pkill -g $$ inotifywait

        ## delete receiver locks held by this process
        sqlite3 /sgm_local/server.sqlite "pragma busy_timeout=10000; delete from symLocks where owner=$SPID" > /dev/null

        ## check for a file called $killFile, and if it exists, delete it and quit
        if [[ -f $killFile ]]; then
            rm -f $killFile
            exit 0
        fi
        sleep 15
    done
else
    MYTMPDIR=`mktemp -d`
    cd $MYTMPDIR
    ## set up an .Rprofile; because loading of the usual libraries
    ## happens after .Rprofile is eval'd, they won't have been loaded
    ## when processServer is called, so load them manually
    cat <<EOF > .Rprofile
    for (l in c("datasets", "utils", "grDevices", "graphics", "stats", "motusServer"))
        library(l, character.only=TRUE)
    rm(l)
    options(error=recover)
    processServer($N, tracing=TRUE)
EOF
    R
    echo running tracing server for queue $N
    pkill -g $$ inotifywait
fi
