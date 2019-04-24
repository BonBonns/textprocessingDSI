#!/usr/bin/python3
# ./postlemma.py filename
# creates temp file then writes over original
import sys
import os

ifilename = sys.argv[1]
ofilename = ifilename + "_post"
ifile = open(ifilename, "r")
ofile = open(ofilename, "w")

# each line is a different word
for line in ifile:
    line = line.rstrip()
    elem = line.split()
    lemma = elem[1]
    if lemma == "DOCB":
        print("", file=ofile)
    elif lemma == "@card@": # not sure what this is in tree-tagger but ignoring it
        continue
    else:
        print(lemma, file=ofile, end=" ")

os.rename(ofilename, ifilename)
