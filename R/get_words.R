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
  words = wf[doccount <= val][[1]]
  return (as.character(words))
}

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
