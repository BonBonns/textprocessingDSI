#include <Rcpp.h>
#include <fstream>

using namespace Rcpp;

std::istream& safe_get_line(std::istream& is, std::string& t);

//' Dos to Unix line endings
//'
//' Removes the windows dos \\r from input file.
//' @param ifilename A string specifying path to input file.
//' @param ofilename A string specifying path to output file.
//' @export
// [[Rcpp::export]]
void dos2unix (std::string ifilename, std::string ofilename)
{
    std::ifstream ifile(ifilename);
    std::ofstream ofile(ofilename);

	if (ifile.is_open() && ofile.is_open()) 
	{
		std::string line;
		while (!safe_get_line(ifile, line).eof())
		{
          ofile << line << "\n";
		}//while
	} // if ifile and ofile open
	return; 
}
