#include <Rcpp.h>
#include <iostream>
#include <fstream>
#include <string.h> //strtok

using namespace Rcpp;

//' Rcpp Doccount
//'
//' Given a file returns the number of words for each document in the file.
//' Assumes documents are delimited
//' by newlines. If the file contains only one document then set fileflag arg to 1.
//' @param ipath A string specifying the path to the input file.
//' @param fileflag An int, set to 1 if only one document per file, 0 if each document is on a newline.
//' returns An int vector of the results.
//' @export
// [[Rcpp::export]]
std::vector <int> rcpp_doccount(std::string ipath, int fileflag)
{
    std::ifstream infile(ipath); // always text not binary
    std::vector <int> result;
    int linen = 0;

    if (infile.is_open())
    {
	std::string line;
	while (getline(infile, line))
	{
	    int wc = 0;
	    char *token;
	    char delims[] = " \t";
	    token = strtok(&line[0], delims);
	    while (token != NULL)
	    {
		wc = wc + 1;
		token = strtok(NULL, delims);
	    }// while tokens

	    if (fileflag == 1)
	    {
		if (linen == 0)
		    result.push_back(wc);
		else
		    result[0] += wc;
	    }
	    else
	    {
		result.push_back(wc);
	    }//else fileflag == 0
	    linen++;

	}//while (for each line in file)
    }//if file read

    else
    {
	stop("file not read");
    }

    // in case file is empty
    if (result.size() == 0)
    {
	result.push_back(0);
    }
    return result;
}// rcpp_summary
