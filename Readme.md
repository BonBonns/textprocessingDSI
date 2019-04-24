# Text Processing DSI

This package is part of the text report generating pipeline of the DSI. This package in particular is meant to be the starting point, used to perform operations on the raw corpus, such as formatting, cleaning and lemmatizing to make it suitable for the next steps. The next step is generally to run a topic model and the text report. 

[TOC]

## Background

There are many different ways to process text data. In R, the standard text processing packages such as **tm**, **topicmodeling**, **quanteda**, **koRpus**, **hunspell**, corpora, don't handle large corpora (>100GB) well. The problem is that these packages rely on loading the files that make up the corpora entirely into memory before performing the operations on those files. We would need a clever programming model to get these to work for our data. Instead of trying to solve this complex problem, this package provides the tools to perform some text processing methods on an arbitrarily large corpus. It does so by streaming the files line by line, using languages other than R for the io and distributing the transformations over many cores.

## System Requirements

Most of the functionality of this package is done in python and Rcpp. In addition, this package provides a wrapper to tree-tagger (for lemmatization). As a result, there are several system requirements beyond having R installed. To use this package, you need **python3**, as well as the python3 modules **hunspell** and **regex** (both can be installed through pip). The python hunspell module requires the **hunspell** as well as  **libhunspell** installed on your system. In addition** you need **tree-tagger** installed on your system. To build the package you need Rcpp that supports the std=c++11 gcc flag. 

The package was designed to be used on a linux server with many cores.

## Installation Instructions

Clone the bitbucket repository. Through the command line run R CMD build and R CMD INSTALL. When installed refer to the **quick start** and **reference** pages to see how to use it.

## Making modifications to this package

This package uses **Rcpp** for most of its functionality. To make changes to those files, you need to change the code in the /src/ directory, and if you changed how to interface with those functions, you need to make the appropriate changes in the R function that wraps the cpp. 

The building and checking for this package is done using the **devtools** R package. The documentation was provided through **Roxygen2** and this website was created with the **pkgdown** package.

## Contact

To contact the maintainer email Arthur Koehl at avkoehl at ucdavis.edu