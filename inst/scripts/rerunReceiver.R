#!/usr/bin/Rscript
##
##
## Reprocess raw data from a receiver.
##

ARGS = commandArgs(TRUE)

if (length(ARGS) == 0) {
    cat("

Usage: rerunReceiver.R [-F] [-p] [-c] [-e] [-t] [-o PARAM_OVERRIDES] -P PROJECTID -U USERID SERNO [BLO BHI]

where:

 SERNO: receiver serial number; e.g. SG-0613BB000613 or Lotek-123
 PROJECTID: integer ID of motus project which should own products
 (will be overridden by receiver deployment records, where these exist)
 USERID: integer ID of motus user who initiated the rerun

Note: the -P and -U options are now mandatory.

 BLO BHI: for an SG, you can specify a range of boot sessions by specifying
 BLO and BHI as the low and high boot sessions, respectively;
 for Lotek receivers, all raw data are reprocessed

 -p: run the job at high priority, on one of the processServers dedicated
     to short, fast jobs; this jumps the queue of processing uploaded data.

 -P PROJECTID: specify integer ID of motus project that will own products; overridden by
     receiver deployment records where these exist

 -U USERID: specify integer ID of motus user who is submitting this job

 -e: don't re-run the tag finder; just re-export data

 -c: cleanup: before running the tag finder, delete existing batches, runs, hits for
     the specified boot sessions

 -F: full rerun: delete all internally-stored files before running, then behave
     as if full contents of file_repo for that receiver consists of new files
     WARNING:  this option makes the rerun very slow; each data file is scanned
     twice, once to test validity/completeness of a .gz file while populating
     the receiver database's 'files' table, and then again when running the tag
     finder.  Unless you have reason to think the 'files' table doesn't match
     the contents of the receiver's file_repo folder, you should use '-c'
     instead of this option.

 -o PARAM_OVERRIDES:  specify job-specific overrides to the tag finder parameters.
     PARAM_OVERRIDES is a quoted string scalar with space-separated
     tag finder options; e.g. `-o '--default_frequency 150.1 --unsigned_dfreq'`
     To see a list of possible parameters, run '/sgm/bin/find_tags_motus --help'
     This script doesn't verify the syntax or semantics of such overrides.

 -t: mark job output as `isTesting`; data from such batches will only be returned
     for admin users who specify they want to see testing batches.

A new job will be created and placed into the master queue (queue 0),
from where a processServer can claim it.

")

    q(save="no", status=1)
}

priority = FALSE
exportOnly = FALSE
cleanup = FALSE
monoBN = NULL
fullRerun = FALSE
isTesting = FALSE
userID = NULL
projectID = NULL
paramOverrides = NULL

while(isTRUE(substr(ARGS[1], 1, 1) == "-")) {
    switch(ARGS[1],
           "-p" = {
               priority = TRUE
           },
           "-e" = {
               exportOnly = TRUE
           },
           "-c" = {
               cleanup = TRUE
           },
           "-F" = {
               fullRerun = TRUE
           },
           "-o" = {
               ARGS = ARGS[-1]
               paramOverrides = ARGS[1]
           },
           "-t" = {
               isTesting = TRUE
           },
           "-P" = {
               ARGS = ARGS[-1]
               projectID = as.integer(ARGS[1])
           },
           "-U" = {
               ARGS = ARGS[-1]
               userID = as.integer(ARGS[1])
           },
           {
               stop("Unknown argument: ", ARGS[1])
           })
    ARGS = ARGS[-1]
}

if (is.null(userID) || is.null(projectID))
    stop("You must specify a motus user (using -U) and motus project (using -P).")
serno = sub("\\.motus$", "", perl=TRUE, ARGS[1])
if (is.na(serno)) stop("You must specify a receiver serial number.")

ARGS = ARGS[-1]

if (length(ARGS) > 0) {
    monoBN = range(as.integer(ARGS))
    ARGS = ARGS[-1]
}

suppressMessages(suppressWarnings(library(motusServer)))

## set up the jobs structure

loadJobs()

if (fullRerun) {
    j = newJob("fullRecvRerun", .parentPath=MOTUS_PATH$INCOMING, serno=serno, motusUserID = userID, motusProjectID = projectID, .enqueue=FALSE)
    jobLog(j, paste0("Fully rerunning receiver ", serno, " from file_repo files."), summary=TRUE)
} else {
    j = newJob("rerunReceiver", .parentPath=MOTUS_PATH$INCOMING, serno=serno, monoBN=monoBN, exportOnly=exportOnly, cleanup=cleanup,
                motusUserID = userID, motusProjectID = projectID,
               .enqueue=FALSE)
    jobLog(j, paste0(if(isTRUE(exportOnly)) "Re-exporting data from" else "Rerunning", " receiver ", serno), summary=TRUE)
}

if (isTesting) {
   j$isTesting = TRUE
}

if (isTRUE(nchar(paramOverrides) > 0)) {
    j$paramOverrides = paramOverrides
}

## move the job to the queue 0 or the priority queue

j$queue = "0"

safeSys("sudo", "chown", "sg:sg", j$path)
if (priority) {
    moveJob(j, MOTUS_PATH$PRIORITY)
    cat("Job", unclass(j), "has been entered into the priority queue\n")
} else {
    moveJob(j, MOTUS_PATH$QUEUE0)
    cat("Job", unclass(j), "has been entered into queue 0\n")
}
