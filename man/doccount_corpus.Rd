% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/doccount_corpus.R
\name{doccount_corpus}
\alias{doccount_corpus}
\title{Doccount of Corpus}
\usage{
doccount_corpus(ipath, ncores, flag = 0)
}
\arguments{
\item{ipath}{A string specifying the path to the input files.}

\item{ncores}{A number specifying the number of cores to use.}

\item{flag}{**optional** A number specifying if documents are delimited by newline (set to 0)
or each text file has only one document (1)}
}
\value{
An int vector with num elements = num docs
}
\description{
A function to get the total words for each document in the corpus.
Useful for things like ldavisCpp for estimating topic proportion in corpus.
}
\examples{
\dontrun{
doccout_corpus("/path/to/corpus/", 20)
}
}
