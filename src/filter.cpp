#include <Rcpp.h>
#include <unordered_set>
#include <fstream>
#include <string.h> //strtok

using namespace Rcpp;

// [[Rcpp::export]]
std::string rcpp_filter(Rcpp::StringVector words, std::string ifilename)
{
    // in place replacement
    std::string ofilename = ifilename + "_temp";

    double scale = 1.5;
    std::unordered_set<std::string> uset_words;
    uset_words.reserve(words.size() * scale);

    // 1. CREATE UNORDERED SET OF WORDS
    // unordered set, given the fact that there are unlikely to be many
    // conflicts seems to be the way to go here

    // iterate through the vector inserting each element into the set
    std::string word;
    for (int i = 0; i < words.size(); i++)
    {
        word = words[i];//necessary to convert type from R string to cpp string
        uset_words.insert(word);
    }

    // 2. ITERATE THROUGH INPUT FILE STRIPPING WORDS THAT ARE IN THE SET
    // iterate through a text file line by line
    // assumes words delimited by whitespace! and no punc
    //   for each line iterate word by word
    //     if word not in list, write to output file
    //   print newline to output file
    std::ifstream ifile(ifilename);
    std::ofstream ofile(ofilename);
    std::string line;
    int count = 0;
    char *token;
    char delims[] = " \t";
    if (ifile.is_open() && ofile.is_open())
    {
        while(getline(ifile, line)) //read file line by line
        {
            token = strtok(&line[0], delims);
            while (token != NULL)
            {
                // if word not in set, write to file
                if (uset_words.find(token) == uset_words.end())
                {
                    ofile << token << " ";
                }
                else
                {
                    count = count + 1;
                }
                token = strtok(NULL,delims);
            } //while token
            ofile << "\n";
        }//for each line
    }//if files open

    std::rename (ofilename.c_str(), ifilename.c_str());

    return ifilename;
}
