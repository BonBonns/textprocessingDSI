#include <Rcpp.h>
#include <iostream>
#include <fstream>
#include <string.h> //strtok

using namespace Rcpp;

//' Rcpp Summary
//'
//' Given a file returns each unique word, the number of times that word appeared,
//' and the number of documents that word appeared in. Assumes documents are delimited
//' by newlines. If the file contains only one document then set delim arg to 1.
//' @param ipath A string specifying the path to the input file.
//' @param delim An int, set to 1 if only one document per file, 0 if each document is on a newline.
//' returns A string vector of the results.
//' @export
// [[Rcpp::export]]
std::vector <std::string> rcpp_summary(std::string ipath, int delim)
{
  std::ifstream infile(ipath); // always text not binary
  std::vector <std::string> result;

  if (infile.is_open())
  {

    std::string line;
    std::vector <std::string> unique;
    std::vector <int> count;
    std::vector <int> doccount;
    unique.reserve(512); // to avoid massive amounts of resizing at small numbers
    count.reserve(512);
    doccount.reserve(512);
    while (getline(infile, line))
    {
      std::vector <int> inds;
      char *token;
      char delims[] = " \t";
      token = strtok(&line[0], delims);
      while (token != NULL)
      {
	int indx = -1;
	// check if word is in unique already
	for (size_t i = 0; i < unique.size(); i++)
	{
	  if (unique[i] == token)
	    indx = i;
	}

	// if not found (indx = -1)
	if (indx == -1)
	{
	  unique.push_back(token);
	  count.push_back(1);
	  doccount.push_back(1);
	}

	else
	{
	  count[indx] ++;
	  // this is updating at each occurance of the word, not each time the word appears in a doc...
	  if (delim == 1 && std::find(inds.begin(), inds.end(), indx) == inds.end())
	  {
	    inds.push_back(indx);
	    doccount[indx]++;
	  }
	}

	token = strtok(NULL, delims);
      }//for each word in line
    }//while (for each line in file)

    for (size_t i = 0; i < unique.size(); i++)
    {
      std::stringstream res;
      res << unique[i] << " " << count[i] << " " << doccount[i];
      result.push_back(res.str());
    }

  }//if file read

  else
  {
     stop("file not read");
  }

  return result;
}
