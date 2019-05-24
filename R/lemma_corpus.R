#' Clean Corpus
#'
#' A function that lemmatizes a corpus using tree-tagger.
#' Handles each file in the ipath in parallel and runs lemma_file on each file.
#' Outputs to the output directory specified. Make sure the output directory 
#' doesn't exist already or has nothing in there.
#'
#' @param ipath A string specifying the path to the input directory with all the text files to lemma.
#' @param odir A string specifying the output directory path.
#' @param ncores A number specifying the number of cores ot use.
#' @param cmd **optional** path to the tree taggery binary on your system.
#' @param param **optional** path to the param file to use.
#'
#' @examples
#' \dontrun{
#' lemma_corpus("/path/to/corpus/", "./lemmad/", 20)
#' lemma_corpus("corpus/", "lemmad/", 20, cmd="~/tt/bin/tree-tagger", param="~/tt/lib/english.par")
#' }
lemma_corpus = function (ipath, odir, ncores, cmd="/opt/tree-tagger/bin/tree-tagger", param="/opt/tree-tagger/lib/english.par")
{
  # check if ipath exists
  if (!dir.exists(ipath))
    stop("no input directory")
  
  if (dir.exists(odir))
    unlink(odir, recursive=TRUE)
  
  dir.create(odir)
  
  # check if there are text files in input directory
  filelist = list.files(path = ipath, pattern=".txt", full.names = TRUE)
  if (length(filelist) < 1)
    stop("no (.txt) files in directory")
  
  # parLapply
  cluster = makeCluster(ncores)
  processed = parLapply(cluster, filelist, lemma_file, odir, cmd, param)
  stopCluster(cluster)
}
  
#' Lemma File
#'
#' System call to tree-tagger binary to lemmatize file based on our tokenization.
#' Give input filename and outputfilename, the function will handle creating
#' temporary files, and the pre and post processing of the tree-tagger lemmatization necessary.
#'
#' @param ifile A string containing the path to the input file.
#' @param odir A string containign the path to the output file.
#' @param cmd **optional** path to the tree taggery binary on your system.
#' @param param **optional** path to the param file to use.
#' @return A string containing the name of the file that was lemmatized.
#'
#' @examples
#' \dontrun{
#' lemma_file("ifile.txt", "ofile.txt")
#' lemma_file("ifile.txt", "ofile.txt", cmd="~/tt/bin/tree-tagger", param="~/tt/lib/english.par")
#' }
lemma_file = function (ifile, odir, cmd="/opt/tree-tagger/bin/tree-tagger", param="/opt/tree-tagger/lib/english.par")
{
  base = basename(ifile)
  ofile = paste(odir, base, sep="/")
  args = "-lemma -no-unknown"
  
  # 1. call the python preprocess script (add DOCB to end of sentences)
  preprocess_script = system.file("python", "prelemma.py", package="textprocessingDSI")
  system2("python3", paste(preprocess_script,ifile, sep=" "), stdout=NULL)

  # 2. run tree tagger note uses our tokenization
  prefname = paste(ifile,"_pre",sep="")
  system2(cmd, paste(args, param, prefname, sep=" "), stdout=ofile)

  # delete prelemma file
  unlink(prefname)

  # 3. call python cleanup script
  postprocess_script = system.file("python", "postlemma.py", package="textprocessingDSI")
  system2("python3", paste(postprocess_script, ofile, sep=" "), stdout=NULL)
}
