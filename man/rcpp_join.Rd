% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RcppExports.R
\name{rcpp_join}
\alias{rcpp_join}
\title{Rcpp Join}
\usage{
rcpp_join(idir, ofilename, newline)
}
\arguments{
\item{idir}{A string specifying the path to the input directory.}

\item{ofilename}{A string specifying the path to the outputfile.}

\item{newline}{An int, if set to 0 files are just concatenated as they are
       if set to 1 the files have their newlines replaced by spaces and
       when they are merged together, a newline is added between them. 
Returns number of files that were joined.}
}
\description{
Given an input directory merge all the files into one large file.
Expects each file to have multiple documents each delimited by newline.
If that is not the case, set the newline argument to 1 to ensure each
document is delimited by newlines.
}
