#' Doccount of Corpus
#'
#' A function to get the total words for each document in the corpus.
#' Useful for things like ldavisCpp for estimating topic proportion in corpus.
#'
#' @param ipath A string specifying the path to the input files.
#' @param ncores A number specifying the number of cores to use.
#' @param flag **optional** A number specifying if documents are delimited by newline (set to 0)
#' 		  or each text file has only one document (1)
#' @return An int vector with num elements = num docs
#'
#' @examples
#' \dontrun{
#' doccout_corpus("/path/to/corpus/", 20)
#' }
doccount_corpus = function (ipath, ncores, flag=0)
{
  # check if ipath exists 
  if (!dir.exists(ipath))
    stop("no input directory")

  # check if there are text files in input directory
  filelist = list.files(path = ipath, pattern=".txt", full.names = TRUE)
  if (length(filelist) < 1 )
    stop ("no (.txt) files in directory")

  cluster = makeCluster(ncores)

  # list of results df
  processed = parLapply (cluster, filelist, rcpp_doccount, flag)
  stopCluster(cluster)
  # merge

  doccounts = unlist(processed)

  return (doccounts)
}
