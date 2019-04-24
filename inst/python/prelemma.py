#!/usr/bin/python3
# ./prelemma.py filename
# creates temp file and then writes over original
import sys
import os

ifilename = sys.argv[1]
ofilename = ifilename + "_pre"
ifile = open(ifilename, "r")
ofile = open(ofilename, "w")

for line in ifile:
    line = line.rstrip()
    line = line + " DOCB"
    words = line.split()
    for w in words:
        print(w, file=ofile)
