% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/readDTA.R
\name{readDTA}
\alias{readDTA}
\title{read a lotek .DTA file}
\usage{
readDTA(filename = "", lines = NULL, numLines = -1)
}
\arguments{
\item{filename}{if specified, gives the full path to the .DTA file}

\item{lines}{if specified, this is a character vector of lines from the .DTA file
(helpful if it has already been read in for some reason).  If NULL (the default),
this function reads the file specified by \code{filename}}

\item{numLines}{the maximum number of lines to read from the file.
Useful if reading the file only to get a serial number, which
is within the first 20 lines. Default: -1, which reads all lines.}
}
\value{
A named list with some or all of these items:

\itemize{
\item  recv serial number; e.g. "Lotek-123"
\item  siteCode; integer; code for site
\item  tags a data.frame with these columns:
\itemize{

\item    ts       numeric GMT timestamp (seconds since 1 Jan 1970)
\item    id       integer, no 999s
\item    ant      factor - Lotek antenna name
\item    sig      signal strength, in raw Lotek units (0..255)
\item    lat      if available, NA otherwise
\item    lon      if available, NA otherwise
\item    dtaline  line in the original .DTA file for this detection, beginning at 1
\item    antfreq  antenna listening frequency, in MHz
\item    gain     gain setting in place during this detection (0..99)
\item    codeset  factor - Lotek codeset name "Lotek3" or "Lotek4" so far

}
\item pieces chunks of text of various types
\item piece.lines.before number of lines before pieces of various types
\item boottimes character of formatted boot timestamps
}
}
\description{
.DTA Files are generated by Lotek receiver software, and contain interspersed
blocks of tag detections, antenna settings, and other metadata.
}
\note{
The .DTA file is processed in lexical order, so that changes
    to antenna frequency settings etc. are taken into account in
    subsequent detection blocks.
}
\author{
John Brzustowski \email{jbrzusto@REMOVE_THIS_PART_fastmail.fm}
}
