library(parallel)
# given an input path, output path, number of cores, clean exe path, and commands for that exe path
# cleans the corpus and puts the cleaned one in output path
# add permissions warnings at some point

clean_corpus = function (ipath, opath, ncores, interpreter, cleanscript, clean_commands_str)
{
  # check if ipath exists 
  if (!dir.exists(ipath))
    stop("no input directory")

  # check if there are text files in input directory
  filelist = list.files(path = ipath, pattern=".txt", full.names = TRUE)
  if (length(filelist) < 1 )
    stop ("no (.txt) files in directory")

  # check if opath exists
  if (dir.exists(opath))
  {
  # if yes prompt user to delete it
    value = menu(c("Yes", "No"), title="odir exists. Do you want to overwrite the directory?")
    if (value == 1)
    {
      unlink(opath, force= TRUE, recursive=T)
    }
    else
      stop("output directory already exists, and user chose to not delete it")
  }
  # create opath
  dir.create(opath)

  # parlapply (clean_file)
  cluster = makeCluster(ncores)
  processed = parLapply (cluster, filelist, clean_file, opath, interpreter, cleanscript, clean_commands_str)

  print(processed)
}

clean_file = function (ifile, odir, interpreter, cleanscript, clean_commands_str)
{
  # check if file exists
  if (!file.exists(ifile))
    stop(paste("couldnt find file", ifile, sep=" "))

  # double check odir exists (in case calling this function directly instead of clean_corpus
  if (!dir.exists(odir))
    stop("output directory doesn't exist")

  # check if exe exists
  if (!file.exists(cleanscript))
    stop("couldn't find cleaning script")
	 
  # ofilename
  ofilename = paste(odir,basename(ifile), sep="/")

  # generate system command
  command = paste(cleanscript, clean_commands_str, ifile, sep=" ")

  # run exe with commands
  system2(interpreter, command, stdout = ofilename)

  return (ifile)
}
