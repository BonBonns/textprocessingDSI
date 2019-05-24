#' Filter Corpus
#' 
#' A function that removes all occurances from a given list of words from each (.txt) file in ipath.
#' Generally used after some analysis of the summary_corpus results. To remove the most and least frequent
#' terms. Handles each file in the ipath in parallel over the number of cores specified. Runs filter_file
#' on each file in the ipath.
#' 
#' @param words A character vector of all the words to remove.
#' @param ipath A string specifying the path to all the text files to handle.
#' @param ncores A number specifying the number of cores to use.
#'
#' @examples
#' \dontrun{
#' filter_corpus(most_common_terms, "/path/to/corpus/", 10)
#' filter_corpus(stopwords, "/path/to/corpus/", 10)
#' }
filter_corpus = function (words, ipath, ncores)
{
  # check if ipath exists 
  if (!dir.exists(ipath))
    stop("no input directory")

  # check if there are text files in input directory
  filelist = list.files(path = ipath, pattern=".txt", full.names = TRUE)
  if (length(filelist) < 1 )
    stop ("no (.txt) files in directory")

  # parlapply (clean_file)
  cluster = makeCluster(ncores)

  # list of results df
  processed = parLapply (cluster, filelist, filter_file, words)
  stopCluster(cluster)
}

#' Filter File
#'
#' A wrapper around the rcpp_filter function.
#' Given a file and a list of words. Remove each occurance of those words from that file.
#' Will modify the input file, so no output file is specified.
#'
#' @param words A character vector of all the words to remove.
#' @param ifilepath A string specifying the path to the input file.
#' @return ifilepath
#'
#' @examples
#' \dontrun{
#' filter_file(most_common_terms, "/path/to/file.txt")
#' filter_file(stopwords, "/path/to/file.txt")
#' }
filter_file = function (words, ifilepath) 
{
  res = rcpp_filter(ifilepath, words)

  return (res)
}
