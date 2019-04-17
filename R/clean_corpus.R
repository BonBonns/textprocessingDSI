clean_corpus = function (ipath, odir, ncores, clean_commands_str)
{
  # check if ipath exists 
  if (!dir.exists(ipath))
    stop("no input directory")

  if (dir.exists(odir))
      unlink(odir, recursive=TRUE)

  dir.create(odir)

  # check if there are text files in input directory
  filelist = list.files(path = ipath, pattern=".txt", full.names = TRUE)
  if (length(filelist) < 1 )
    stop ("no (.txt) files in directory")

  # parlapply (clean_file)
  cluster = makeCluster(ncores)
  processed = parLapply (cluster, filelist, clean_file, odir, clean_commands_str)
  stopCluster(cluster)

  return (processed)
}
   

clean_file = function (ifile, odir, clean_commands_str)
{
    interpreter = "python3"
    script = system.file("python", "clean.py", package="textprocessingDSI")
    base = basename(ifile)
    ofile = paste(odir, base, sep="/")
    full_command = paste(script, clean_commands_str, ifile, sep=" ")

    system2(interpreter, full_command, stdout=ofile)

    return (ifile)
}
