#' Text Processing Pipeline
#' 
#' A function that runs the full pipeline for cleaning a corpus and preparing it
#' to be topic modelled. Has several optional arguments and some mandatory arguments.
#' Designed to be the simplest way to process a corpus. If you want more control,
#' run the various pieces of the pipeline manually. The pipeline is essentially: \cr
#' 1) combine the corpus into a single file (one document per line) and split the corpus into equal sized chunks \cr
#' 2) clean those chunks in parallel \cr
#' 3) find and remove the 'sparse' and 'abundant' terms \cr
#' 4) recombine the now cleaned corpus into a single file (one document per line) \cr
#' 5) delete the intermediary directories that were created \cr
#' 6) save the parameters used to clean in an info file in the opath \cr
#'
#' @param ipath A string specifying path to the raw text files containing the corpus.
#' @param opath A string specifying the path to put all the outputs in.
#' @param delim A number (1 or 0), 0 means files are concated as they are, 1 means to replace newlines with spaces 
#'				and delimit each document with a newline.
#' @param ncores A number specifying the number of cores to use. 
#' @param clean_commands A string containing the combined parameters for running the cleaning script, 
#'        refer to clean_corpus and clean_file documentation.
#' @param split **optional** A character('c' or 'l', default='c') specifying if the corpus should be split by memory size or by line count.
#' @param size **optional** A number (default 50,000) specifying the line count or size in kilobytes to segment the corpus into.
#' @param sparsity **optional** A number (default = 0.02) determining the threshold for sparse words to get rid of,
#'		  refer to get_sparse documenation.
#' @param abundance **optional** A number (default = 0.98) determining the threshold for abundant words to get rid of,
#'		  refer to get_abundant documentation.
#' @param verbose **optional** A bool, if set to TRUE print to console more information.
#' @return A string giving path to the cleaned corpus file, containing one document on each line.
#'
#' @examples
#' \dontrun{
#' pipeline("/corpus/", "/opath/", 1, 20, "-lnprsd --maintain-newlines", split="l", size="2000")
#' pipeline("/corpus/", "/opath/", 1, 20, "-lnpr --maintain-newlines", split="c", size="200000")
#' pipeline("/corpus/", "/opath/", 1, 20, "-lnprsd --maintain-newlines", sparsity=0.04)
#' }
pipeline = function(ipath, opath, delim, ncores, clean_commands, split="c", size=50000, sparsity=0.02, abundance=0.98, verbose=FALSE)
{
    # 0. get paths ready 
    jfile = paste(opath, "corpus.txt", sep="/")
    spath = paste(opath, "split/", sep="/")
    cpath = paste(opath, "cleaned/", sep="/")
    dir.create(opath)
    dir.create(spath)
    dir.create(cpath)
    
    # 1. prep (Format the corpus)
    print("joining files")
    filenames = rcpp_join(ipath, jfile, delim)
    print("splitting files")
    nsplitfiles = rcpp_split(jfile, spath, split, size)
    
    # 2. clean the corpus
    print("cleaning the corpus")
    cleaned = clean_corpus (spath, cpath, ncores, clean_commands)
    
    # 3. filter (summary + filter)
    print("getting summary of corpus")
    freq = summary_corpus(cpath, ncores)
    print(paste(nrow(freq), " unique words in corpus"))
    sparse = get_sparse(freq, length(files), sparsity)
    abundant = get_abundant(freq, length(files), abundant)
    terms = c(sparse,abundant)
    filter_corpus(terms, cpath, ncores)
    print(paste(nrow(freq) - terms, " unique words in corpus"))
    
    # 4. recombine the corpus and overwrite the corpus file
    print("rejoining corpus")
    nsplitfiles = rcpp_join(cpath, jfile)
    
    # 5. cleanup directories
    print("cleaning up temp directories")
	unlink(spath, recursive=TRUE)
	unlink(cpath, recursive=TRUE)
	
	# 6. save filenames and parameters used to file
    print("saving run info")
    infofile = fileConn(paste(opath, "/info.txt"))
    workflowfile = fileConn(paste(opath, "/parameters.txt"))
	writeLines(filenames, infofile)
    writeLines(c(ipath, opath, clean_commands,sparsity,abundance), workflowfile)

    return (jfile)
}
