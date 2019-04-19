#' Get List of Sparse Terms
#'
#' A function to analyze the output of the summary_corpus. Returns words that appeared in less
#' than or equal to X percent of documents, if you pass X as a decimal. Otherwise, if X is a whole number
#' returns the words that appeared in X or less documents.
#' @param wf A data table containing the word and document frequencies accross the corpus.
#' @param ndocs A number specifying the total number of unique documents in the corpus.
#' @param sparsity A number either decimal or whole; interpreted as percent, whole as count.
#' @return words A character vector of all the sparse terms.
#'
#' @examples
#' \dontrun{
#' sparse = get_sparse(wf, 100, .03)
#' sparse = get_sparse(wf, 100, 3)
#' }
get_sparse = function (wf, ndocs, sparsity)
{
  if (sparsity < 1)
  {
    val = sparsity * ndocs
  }
  else
  {
    val = sparsity

  }
  words = as.character(wf[doccount <= val][[1]])
  return (words)
}

#' Get List of Abundant Terms
#'
#' A function to analyze the output of the summary_corpus similar to get_spare.
#' Returns words that appeared in more than or equal to X percent of documents, 
#' if you pass X as a decimal. Otherwise, if X is a whole number
#' returns the words that appeared in X or more documents.
#' @param wf A data table containing the word and document frequencies accross the corpus.
#' @param ndocs A number specifying the total number of unique documents in the corpus.
#' @param abundance A number either decimal or whole; interpreted as percent, whole as count.
#' @return words A character vector of all the abundant terms.
#'
#' @examples
#' \dontrun{
#' sparse = get_abundant(wf, 100, .95)
#' sparse = get_abundant(wf, 100, 95) 
#' }
get_abundant = function (wf, ndocs, abundance)
{
  if (abundance < 1)
  {
    val = abundance * ndocs
  }
  else
  {
    val = abundance
  }
  words = wf[doccount >= val][[1]]
  return (as.character(words))
}

#' Get List of Least Frequent Terms
#' 
#' Similar to get_sparse but looks at word frequency not doc count.
#' If X is whole number, returns the X least frequent terms. If X is decimal
#' returns the X% least frequent words.
#' @param wf A data table containing the word and document frequencies accross the corpus.
#' @param nterms A number specifying the total number of unique words in the corpus.
#' @param count A number either decimal or whole; interpreted as percent, whole as count.
#' @return words A character vector of the least frequent terms
#'
#' @examples
#' \dontrun{
#' infreq = get_bottom_terms(wf, 100000, 5000) #returns 5000 least common terms
#' infreq = get_bottom_terms(wf, 100000, .05) #returns the bottom 5% of terms
#'}
get_bottom_terms = function (wf, nterms, count)
{
  if (count < 1)
  {
    val = count * nterms
  }
  else
  {
    val = count
  }
  sorted = wf[order(rank(freq))]
  words = sorted[[1]][1:val]
  return (as.character(words))
}

#' Get List of Most Frequent Terms
#' 
#' Similar to get_sparse but looks at word frequency not doc count.
#' If X is whole number, returns the X most frequent terms. If X is decimal
#' returns the X% most frequent words.
#' @param wf A data table containing the word and document frequencies accross the corpus.
#' @param nterms A number specifying the total number of unique words in the corpus.
#' @param count A number either decimal or whole; interpreted as percent, whole as count.
#' @return words A character vector of the least frequent terms
#'
#' @examples
#' \dontrun{
#' infreq = get_top_terms(wf, 100000, 5000) #returns 5000 most common terms
#' infreq = get_top_terms(wf, 100000, .05) #returns the top 5% of terms
#'}
get_top_terms = function (wf, nterms, count)
{
  if (count < 1)
  {
    val = count * nterms
  }
  else
  {
    val = count
  }
  sorted = wf[order(-rank(freq))]
  words = sorted[[1]][1:(nterms - val)]
  return(as.character(words))
}
