% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/endpoint.R
\name{check_endpoints}
\alias{check_endpoints}
\title{Check endpoints in WORCS project}
\usage{
check_endpoints(worcs_directory = ".", verbose = TRUE, ...)
}
\arguments{
\item{worcs_directory}{Character, indicating the WORCS project directory
to which to save data. The default value "." points to the current directory.
Default: '.'}

\item{verbose}{Logical. Whether or not to print status messages to the
console. Default: TRUE}

\item{...}{Additional arguments.}
}
\value{
Returns a logical value (TRUE/FALSE) invisibly.
}
\description{
Check that the checksums of all endpoints in a WORCS project
match their snapshots.
}
\examples{
# Create directory to run the example
old_wd <- getwd()
test_dir <- file.path(tempdir(), "check_endpoint")
dir.create(test_dir)
setwd(test_dir)
file.create(".worcs")
writeLines("test", "test.txt")
add_endpoint("test.txt")
check_endpoints()
# Cleaning example directory
setwd(old_wd)
unlink(test_dir, recursive = TRUE)
}
\seealso{
\code{\link[worcs]{add_endpoint}}
\code{\link[worcs]{snapshot_endpoints}}
}
