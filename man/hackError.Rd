% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/hackError.R
\name{hackError}
\alias{hackError}
\title{examine the calling environments of a failed job}
\usage{
hackError(j, type, index, topLevel = TRUE)
}
\arguments{
\item{j}{the top-level motus job ID one of whose subjobs failed}

\item{type}{the type of subjob to examine.  If not specified,
the first such subjob is examined.}

\item{topLevel}{logical; if TRUE (the default), treat {j} as a top-level
job; otherwise, treat \code{j} as the job of interest, and ignore \code{type}
and \code{index}.}

\item{index;}{integer; optional.  If present, selects from multiple
subjobs of the same type.}
}
\description{
examine the calling environments of a failed job
}
