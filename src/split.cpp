// INPUT ARGS: fpath, odir, splitbylines/splitbyside, linecount or char count
// given a single input file, split into multiple files
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
  char ofilename[20];

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
	if (nchars > count) // assumes one char is one byte
	{
	  nchars = line.length();
	  // close current file
	  ofile.close();
	  //   open next file
	  fileiter++;
  	  sprintf(ofilename, "%s/%04d.txt", odir.c_str(), fileiter); 
	  ofile.open(ofilename);
	  if (!ofile.is_open())
	    stop("can't open file for output");
	}
	//write to file
	ofile << line << "\n"; 
      }

      if (splitter == "l")
      {
	nlines++;
	if (nlines > count)
	{
	  nlines = 1;
	  //close current file
	  ofile.close();
	  //  open next file
	  fileiter++;
  	  sprintf(ofilename, "%s/%04d.txt", odir.c_str(), fileiter); 
	  ofile.open(ofilename);
	  if (!ofile.is_open())
	    stop("can't open file for output");
	}
	//write to file
	ofile << line << "\n"; 
      }


    }//while
  }//if file read
  else
  {
    stop("file not read");
  }

  return 0;
}
