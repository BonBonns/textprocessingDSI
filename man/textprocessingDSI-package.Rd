\name{textprocessingDSI-package}
\alias{textprocessingDSI-package}
\alias{textprocessingDSI}
\docType{package}
\title{
  Efficiently clean a corpus in parallel
}
\description{
  This package was designed for corpuses too large for conventional R cleaning methods.
  The majority of the functionality of this package is written in cpp and linked with Rcpp.
  The R code is for the most part a wrapper around the cpp files that perform the operations on the corpus.
  Given an input list of text files, this package provides the tools to clean, tokenize, and reduce
  the number of terms of the corpus to prepare it for topic modelling and other nlp tasks.
}
\details{
  This section should provide a more detailed overview of how to use the
  package, including the most important functions.
}
\author{
Arthur Koehl

Maintainer: Arthur Koehl <avkoehl@ucdavis.edu>
}
\keyword{ package }
\examples{
  \dontrun{
     ## Optional simple examples of the most important functions
     ## These can be in \dontrun{} and \donttest{} blocks.   
  }
}
