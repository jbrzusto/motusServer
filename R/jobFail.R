#' mark a job as failed
#'
#' record an error message for the job, mark it with done=-1,
#' and move its folder to MOTUS_PATH$ERRORS
#'
#' @param j the job
#'
#' @param msg message to add to job's log
#'
#' @param code; the value to store in "done"; should be non-zero
#' and defaults to -1.
#'
#' @return no return value
#'
#' @export
#'
#' @author John Brzustowski \email{jbrzusto@@REMOVE_THIS_PART_fastmail.fm}

jobFail = function(j, msg, code=-1) {
    j$done = code
    jobLog(j, msg, summary=TRUE)
    moveJob(j, MOTUS_PATH$ERRORS)
}
