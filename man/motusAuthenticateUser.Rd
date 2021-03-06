% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/motusAuthenticateUser.R
\name{motusAuthenticateUser}
\alias{motusAuthenticateUser}
\title{authenticate a user with motus.org}
\usage{
motusAuthenticateUser(username, password)
}
\arguments{
\item{username}{motus user name}

\item{password}{motus password (plaintext)}
}
\value{
if the credentials are valid, a list with these items:
\itemize{
\item token character scalar token used in subsequent API calls
\item expiry numeric timestamp at which \code{token} expires
\item userID integer user ID of user at motus
\item projects list of projects user has access to; indexed by integer projectID, values are project names
\item receivers FIXME: will be list of receivers user has access to
}
Otherwise, generate an error.
}
\description{
authenticate a user with motus.org
}
\note{
This function uses the global \code{AuthDB}, defined in \link{serverCommon}
}
\author{
John Brzustowski \email{jbrzusto@REMOVE_THIS_PART_fastmail.fm}
}
