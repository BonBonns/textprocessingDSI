#' Summary of Corpus
#'
#' A function that calculates word frequency and document frequency
#' for all the words in the corpus. The output can then be analyzed
#' to remove outlier words, or stop words. Handles each file in 
#' parallel over the number of cores specified using parlapply. 
#' Runs summary_file function on each of the files in the ipath.
#' 
#' @param ipath A string specifying the path to the input files.
#' @param ncores A number specifying the number of cores to use.
#' @param flag **optional** A number specifying if documents are delimited by newline (set to 0)
#' 		  or each document is in a different text file. 
#' @return A dataframe object that has merged the dataframes for each file.
#'		   Has term,freq,doccount for each term.
#'
#' @examples
#' \dontrun{
#' summary_corpus("/path/to/corpus/", 0)
#' }
summary_corpus = function (ipath, ncores, flag=0)
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
  processed = parLapply (cluster, filelist, summary_file, flag)
  stopCluster(cluster)
  # merge
  dt = data.table_rbindlist = data.table::rbindlist(processed)

  # collapse df on duplicate rows
  dt = dt[, j=list(sum(freq), sum(doccount)), by=term]
  colnames(dt) = c("term", "freq", "doccount")

  return (dt)
}

#' Summary of File Word Counts
#'
#' A wrapper around the rcpp_summary function. Given a file, get the unique words,
#' their counts, and the number of documents they appeared in. The flag argument
#' specifies if there are more than one document per text file. Set to 0 if that is the case
#' and the documents are delimited by newlines. Set to 1 if there is only one document in
#' the file.
#' 
#' @param ipath A string specifying the path to the file.
#' @param flag **optional** A number, set to 1 if only one document per text file.
#' @return A dataframe object with term, freq, doccount fields.
#' 
#' @examples
#' \dontrun{
#' summary_file("10documents.txt")
#' summary_file("onedocument.txt", 1)
#' }
summary_file = function (ipath, flag=0) 
{
  # just a little helper function to parse the list of lists
  mysplit = function (x)
  {
    x = strsplit(x, " ")
    return (unlist(x))
  }
  res = rcpp_summary(ipath, flag)

  if (length(res) == 0) {
      df = data.frame(term=character(), freq=integer(), doccount=integer())
      return(df)
  }

  # parse res (a list of strings where each string should be split on whitespace) into list of lists into df
  reslistoflists = lapply(res, mysplit)
  df = data.frame(do.call(rbind, reslistoflists))
  colnames(df) = c("term", "freq", "doccount")
  df$freq = as.numeric(as.character(df$freq))
  df$doccount = as.numeric(as.character(df$doccount))

  # returns df
  return (df)
}
