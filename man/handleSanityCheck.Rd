% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/handleSanityCheck.R
\name{handleSanityCheck}
\alias{handleSanityCheck}
\title{Do basic sanity checks on all files (recursively0 in a folder.}
\usage{
handleSanityCheck(j)
}
\arguments{
\item{j}{the subjob, which has parameters:
\itemize{
\item dir: path to the folder to be checked
}}
}
\value{
TRUE if all files pass; FALSE otherwise
}
\description{
Files are checked with testFile.  Any files which fail the
test are archived into the file badfiles.zip.NOAUTO in the
folder for the top job, and then deleted.
}
\details{
If any files fail sanity checks, summary messages are written to
the job log.
}
\author{
John Brzustowski \email{jbrzusto@REMOVE_THIS_PART_fastmail.fm}
}
