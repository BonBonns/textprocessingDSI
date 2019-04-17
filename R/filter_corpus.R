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

  return (processed)
}

filter_file = function (words, ifilepath) 
{
  res = cpp_filter(ifilepath, words)

  return (res)
}
