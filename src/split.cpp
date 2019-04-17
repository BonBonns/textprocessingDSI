// INPUT ARGS: fpath, odir, splitbylines/splitbyside, linecount or char count
// given a single input file, split into multiple files
// returns number of files
#include <Rcpp.h>
#include <iostream>
#include <fstream>

using namespace Rcpp;

// [[Rcpp::export]]
int rcpp_split(std::string fpath, std::string odir, std::string splitter, int count)
{
  std::string line;
  std::ifstream infile(fpath); // always text not binary
  int nlines = 0;
  int nchars = 0; 
  int fileiter = 1;
  char ofilename[256];

  std::sprintf(ofilename, "%s/%04d.txt", odir.c_str(), fileiter);  // default 
  std::ofstream ofile (ofilename);
  if (!ofile.is_open())
    stop("can't open file for output");

  if (! (splitter == "c" or splitter == "l"))
    stop("pass valid splitter - c or l");


  if (infile.is_open())
  {
    while (getline(infile, line))
    {

      if (splitter == "c")
      {
	nchars = nchars + line.length(); 

	if (nchars > count * 1000) // assumes one char is one byte and size given in kb
	{
	  if (fileiter == 1)
	  {
	    ofile << line << "\n"; 
	    nchars = line.length();
	    ofile.close();
	    fileiter++;
	    sprintf(ofilename, "%s/%04d.txt", odir.c_str(), fileiter); 
	    ofile.open(ofilename);
	    if (!ofile.is_open())
	      stop("can't open file for output");
	    continue;
	  }
	  else 
	  {
	    nchars = line.length();
	    ofile.close();
	    fileiter++;
	    sprintf(ofilename, "%s/%04d.txt", odir.c_str(), fileiter); 
	    ofile.open(ofilename);
	    if (!ofile.is_open())
	      stop("can't open file for output");
	  }
	}
	ofile << line << "\n"; 
      }

      if (splitter == "l")
      {
	nlines++;

	if (nlines > count)
	{
	  nlines = 1;
	  ofile.close();
	  std::cout << "closed\n";
	  fileiter++;
	  sprintf(ofilename, "%s/%04d.txt", odir.c_str(), fileiter); 
	  ofile.open(ofilename);
	  if (!ofile.is_open())
	    stop("can't open file for output");
	}
	ofile << line << "\n"; 
      }


    }//while
    ofile.close();

    //delete the file
    std::remove(fpath.c_str());
  }//if file read
  else
  {
    stop("file not read");
  }

  //return fileiter;
  return fileiter;
}
