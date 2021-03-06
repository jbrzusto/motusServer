% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ensureParamOverridesTable.R
\name{ensureParamOverridesTable}
\alias{ensureParamOverridesTable}
\title{make sure we have a valid parameterOverrides table}
\usage{
ensureParamOverridesTable()
}
\value{
returns a \code{safeSQL} object to the override database
}
\description{
The function takes no parameters.
}
\details{
This table allows us to specify overrides to default parameters for the tag finder.
Ideally, these would be specified on the motus side, by receiver deployment,
but for now we do it like this.  For example, some projects operate on a listening
frequency of 150.1 MHz.  We need to specify that default frequency to the tag
finder in case the relevant frequency-setting records from the SG did not
make it into the data stream (usually because the user didn't send files with
pre-GPS dates like 2000-01-01).

Each override can apply to either a particular receiver deployment, or to all
receiver deployments for a project.

If the serno field is not null, the override is for a receiver deployment, given
by serno and either the timestamp range (tsStart, tsEnd) for Lotek receivers, or
the boot session range (monoBNlow, monoBNhigh) for SGs.  A range where the
second element (tsEnd or monoBNhigh) is null is treated as on-going.

If the serno field is null but the projectID is not null, then the override applies
to all receivers for the specified project.  For SGs, only those boot sessions
where the receiver's deployment belonged to that project apply.

FIXME: for Lotek receivers, the parameter overrides apply for the entire
sequence of data processed for this receiver.
}
\author{
John Brzustowski \email{jbrzusto@REMOVE_THIS_PART_fastmail.fm}
}
