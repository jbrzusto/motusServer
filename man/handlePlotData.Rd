% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/handlePlotData.R
\name{handlePlotData}
\alias{handlePlotData}
\title{plot data from a receiver}
\usage{
handlePlotData(j)
}
\arguments{
\item{j}{the job, with these fields:
\itemize{
\item serno - the receiver serial number
\item monoBN - the range of receiver bootnums; NULL for Lotek receivers.
\item ts - the approximate range of timestamps; NULL for SGs.
}}
}
\value{
TRUE
}
\description{
plot data from a receiver
}
\details{
Generate unified status / data plots and datasets for a receiver.
If the top-level job has a motusProjectID field, then this function plots
only the data for receiver deployments belonging to that project.
}
\author{
John Brzustowski \email{jbrzusto@REMOVE_THIS_PART_fastmail.fm}
}
