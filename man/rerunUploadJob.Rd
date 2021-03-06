% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rerunUploadJob.R
\name{rerunUploadJob}
\alias{rerunUploadJob}
\title{Rerun an upload job, after some external error condition has been fixed.}
\usage{
rerunUploadJob(j)
}
\arguments{
\item{j}{the job, as an integer scalar job number. This can be a
top-level job, or one of its sub-jobs; in the latter case, the
top-level job is used anyway.  The top-level job must be of
type "uploadFile", otherwise this function throws an error.}
}
\value{
TRUE if the job was found, of the correct type and
    resubmitted to the uploadServer; FALSE otherwise.
}
\description{
Rerun an upload job, after some external error condition has been fixed.
}
\details{
First, this removes all traces of the original upload job, both from the
job database, and the filesystem:
\itemize{
\item{all jobs in server.sqlite with \code{stump == j}}
\item{the folder at \code{j$path}}
\item{any files \code{/sgm/errors/NNNNNNNN.rds} where \code{stump(NNNNNNNN) == j}}
}

Then, a new hardlink to the original uploaded file is created in
\code{/sgm/uploads}.  The original uploaded file is recorded in
\code{j$filename}, or as \code{sj$file} where \code{sj} is a subjob
of \code{j} with type "unpackArchive").

This will cause the uploadServer to re-queue the
originally-uploaded file.
}
\note{
this function does not revert any changes to receiver
    databases affected by the original processing of the uploaded
    file.
}
\seealso{
\code{\link{processServer}}
}
\author{
John Brzustowski \email{jbrzusto@REMOVE_THIS_PART_fastmail.fm}
}
