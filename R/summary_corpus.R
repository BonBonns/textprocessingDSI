summary_corpus = function (ipath, ncores, delim)
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
  print("processing the files")
  processed = parLapply (cluster, filelist, summary_file, delim)
  stopCluster(cluster)
  # merge
  print("merging dataframes")
  #df = do.call("rbind", processed)
  dt = data.table_rbindlist = data.table::rbindlist(processed)

  # collapse df on duplicate rows
  ## want to use data.table for this

  print("collapsing to unique terms")
  #print(head(dt)) 
  
  dt = dt[, j=list(sum(freq), sum(doccount)), by=term]

  return (dt)
}

summary_file = function (ipath, delim) 
{
  res = rcpp_summary(ipath, delim)

  # parse res (a list of strings where each string should be split on whitespace) into list of lists into df
  reslistoflists = lapply(res, mysplit)
  df = data.frame(do.call(rbind, reslistoflists))
  colnames(df) = c("term", "freq", "doccount")
  df$freq = as.numeric(as.character(df$freq))
  df$doccount = as.numeric(as.character(df$doccount))

  # returns df
  return (df)
}

mysplit = function (x)
{
  x = strsplit(x, " ")
  return (unlist(x))
}

