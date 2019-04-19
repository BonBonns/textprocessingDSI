#include <Rcpp.h>
#include <fstream>
#include <dirent.h>
using namespace Rcpp;

std::istream& safe_get_line(std::istream& is, std::string& t)
{
	//from https://stackoverflow.com/questions/6089231/getting-std-ifstream-to-handle-lf-cr-and-crlf
	t.clear();

	// The characters in the stream are read one-by-one using a std::streambuf.
	// That is faster than reading them one-by-one using the std::istream.
	// Code that uses streambuf this way must be guarded by a sentry object.
	// The sentry object performs various tasks,
	// such as thread synchronization and updating the stream state.

		std::istream::sentry se(is, true);
	std::streambuf* sb = is.rdbuf();

	for(;;) {
		int c = sb->sbumpc();
		switch (c) {
			case '\n':
				return is;
			case '\r':
				if(sb->sgetc() == '\n')
					sb->sbumpc();
				return is;
			case std::streambuf::traits_type::eof():
				// Also handle the case when the last line has no line ending
				if(t.empty())
				is.setstate(std::ios::eofbit);
				return is;
			default:
				t += (char)c;
		}
	}
}


//' Rcpp Join
//'
//' Given an input directory merge all the files into one large file.
//' Expects each file to have multiple documents each delimited by newline.
//' If that is not the case, set the newline argument to 1 to ensure each
//' document is delimited by newlines.
//' @param idir A string specifying the path to the input directory.
//' @param ofilename A string specifying the path to the outputfile.
//' @param newline An int, if set to 0 files are just concatenated as they are
//'		   if set to 1 the files have their newlines replaced by spaces and
//'		   when they are merged together, a newline is added between them. 
//' Returns number of files that were joined.
//' @export
// [[Rcpp::export]]
std::vector<std::string> rcpp_join (std::string idir, std::string ofilename, int newline)
{
	int newline_delim = newline; // if 1 that means we need to delimit the docs by newlines
	// if 0 that means we need to do nothing
	std::vector <std::string> myfiles;
	std::ofstream ofile (ofilename);
	int ndocs = 0;

	// 1. get list of all the myfiles in directory, store in string vector
	DIR *dir;
	struct dirent *ent;
	if ( (dir=opendir(idir.c_str())) != NULL) 
	{
		while ((ent = readdir(dir)) != NULL)
		{
			std::string fname = ent->d_name;
			if (fname.find(".txt") != std::string::npos)
				myfiles.push_back(fname);
		}
	}

	std::sort (myfiles.begin(), myfiles.end());

	// 2. loop through the files and concat into ofile
	//    for each file, for each line, read in line and print to ofile
	std::string line;
	std::ifstream infile;
	for (size_t i = 0; i < myfiles.size(); i++)
	{
		infile.close();
		infile.open(idir + myfiles[i]);
		if (infile.is_open())
		{
			//while (getline(infile, line))
			while (!safe_get_line(infile, line).eof())
			{
				if (newline_delim == 0)
				{
					ofile << line << "\n";
					ndocs++;
				} // if already delimited by newlines
				else
				{
					ofile << line << " ";
				}//

			}//for each line

			if (newline_delim == 1)
			{
				ofile << "\n"; 
				ndocs++;
			}

		}//if open
	}//for each file
	return myfiles;
}
