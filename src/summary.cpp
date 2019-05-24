#include <Rcpp.h>
#include <iostream>
#include <fstream>
#include <string.h> //strtok
#include <map>

using namespace Rcpp;

//' Rcpp Summary
//'
//' Given a file returns each unique word, the number of times that word appeared,
//' and the number of documents that word appeared in. Assumes documents are delimited
//' by newlines. If the file contains only one document then set delim arg to 1.
//' @param ipath A string specifying the path to the input file.
//' @param fileflag An int, set to 1 if only one document per file, 0 if each document is on a newline.
//' returns A string vector of the results.
//' @export
// [[Rcpp::export]]
std::vector <std::string> rcpp_summary(std::string ipath, int fileflag)
{
  std::ifstream infile(ipath); // always text not binary
  std::vector <std::string> result;
  std::map <std::string, std::vector<int> > word_frequencies;
  int linen = 0;

  if (infile.is_open())
  {

    std::string line;
    while (getline(infile, line))
    {
      char *token;
      char delims[] = " \t";
      token = strtok(&line[0], delims);
      while (token != NULL)
      {
		auto s = word_frequencies.find(token);
		if (s != word_frequencies.end())
		{
		    s->second[0]++;

		    if (fileflag == 0 && s->second[2] != linen)
		    {
			s->second[1]++;
			s->second[2] = linen;
		    }
		} // if word in map
		else {
		    std::vector<int> a(3,1);
		    a[2] = linen;
		    word_frequencies[token] = a;
		}
		token = strtok(NULL, delims);
      }// while tokens
      linen++;
    }//while (for each line in file)

    for (auto it = word_frequencies.begin(); it!= word_frequencies.end(); ++it)
    {
        std::stringstream res;
	res << it->first << " " << it->second[0] << " " << it->second[1];
	result.push_back(res.str());
    }

  }//if file read

  else
  {
     stop("file not read");
  }

  return result;
}// rcpp_summary
