#' Clean Corpus
#'
#' A function that cleans a corpus based on user specification. 
#' Handles each file in the ipath in parallel and runs clean_file on each file.
#' Outputs the cleaned version of the file into the output directory specified. 
#' Make sure output directory either doesn't exist (yet) or has nothing important in it,
#' As this function will delete whatever is already in there.
#' Look at the documentation for clean_file to see the commands to pass to the cleaning 
#' script.
#'
#' @param ipath A string specifying the path to all the text files to handle.
#' @param odir A string specifying the path to an output directory.
#' @param ncores A number specifying the number of cores to use.
#' @param clean_commands_str A string containing the combined commands for the cleaning script.
#' @return A character vector of all the files taht were cleaned.
#'
#' @examples
#' \dontrun{
#' clean_corpus("/path/to/corpus/", "./cleaned/", 20, "-lnprsd --maintain-newlines --min-size 2")
#' }
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

#' Clean File
#' 
#' A wrapper around the clean.py script in /inst/python/.
#' Specify the path to file you want to clean, an output directory and a string 
#' containing the commands you want to send to the cleaning script.
#' Be sure to pass the maintain-newlines parameter if your files are in a format 
#' where many documents are in one text file delimited by newlines.
#' Also, if you plan on using the lemmatizing functions be sure to add the --lemma flag
#' here as well, as it prepares the corpus for tree tagger lemmatizing.
#' For conveniance I am putting all the possible commands that can be passed to that python
#' script here. \cr 
#'      -l                     : if words should be lowercased \cr
#'      -n                     : if digits should be stripped \cr
#'      -p                     : if punctuation should be stripped \cr
#'      -r                     : if roman numerals should be stripped \cr
#'      -s                     : if stop words should be stripped \cr
#'      -d                     : if non dictionary words should be stripped \cr
#'      -t                     : if tweet specific cleaning options should be used \cr
#'      --additional           : if triggered then adds all stopwords and dictionary files \cr
#'      --lemma                : if triggered convert common regexes to common form \cr
#'      --no-usernames         : if usernames (ampersand<name>) should be removed \cr
#'      --maintain-newlines    : use space for deilm instead of default(newline) \cr
#'      --min-size [N]         : specify the minimum size for a token (default=2)  \cr
#'
#' @param ifile A string containing the path to the input file.
#' @param odir A string containing the path to the output directory.
#' @param clean_commands_str A string containing the combined commands for the cleaning script.
#' @return A string containing the name of the file that was cleaned.
#'
#' @examples
#' \dontrun{
#' clean_file("myfile.txt", "./cleaned/", "-d")
#' clean_file("myfile.txt", "./cleaned/", "-lnp")
#' clean_file("myfile.txt", "./cleaned/", "-lnprsdt")
#' clean_file("myfile.txt", "./cleaned/", "-lnprsdt --additional")
#' clean_file("myfile.txt", "./cleaned/", "-lnprsdt --lemma --maintain-newlines --min-size 3")
#' }
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
