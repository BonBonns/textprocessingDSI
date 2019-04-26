#!/usr/bin/python3

# ==========================================================================================
#                          clean.py      
#     Arthur Koehl                         Version 3.0
#
#     Python 3 for unicode strings.
#     will read either from file specified on command line or stdin
#     tokenize and clean the file. Return each token on newline.
#     Prints to stdout
#
#     Flags 
#      -l                     : if words should be lowercased
#      -n                     : if digits should be stripped 
#      -p                     : if punctuation should be stripped
#      -r                     : if roman numerals should be stripped
#      -s                     : if stop words should be stripped
#      -d                     : if non dictionary words should be stripped
#      -t                     : if tweet specific cleaning options should be used
#      --additional           : if triggered then adds all stopwords and dictionary files
#      --lemma                : if triggered convert common regexes to common form
#      --no-usernames         : if usernames (@name) should be removed
#      --maintain-newlines    : use space for deilm instead of default(newline) 
#      --min-size             : specify the minimum size for a token (default=2)
# =========================================================================================

import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)
import os 
import sys
from string import digits, punctuation, printable
import argparse
import codecs
import regex as re #for grapheme support
import hunspell #pyhunspell not cyhunspell

def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('infile', type=str)
    parser.add_argument('-l', help="if words should be lowercased", action='store_true')
    parser.add_argument('-n', help="if digits should be striped", action='store_true')
    parser.add_argument('-p', help="if punctuation should be striped", action='store_true')
    parser.add_argument('-r', help="if roman numerals should be striped", action='store_true')
    parser.add_argument('-s', help="if stopwords should be striped", action='store_true')
    parser.add_argument('-d', help="if non dictionary words should be striped", action='store_true')
    parser.add_argument('-t', help="use tweet specific cleaning", action='store_true')
    parser.add_argument('--additional', help="if additional stopwords and dictionaries should be loaded", action='store_true')
    parser.add_argument('--tags', help="if common patterns should be tagged", action='store_true')
    parser.add_argument('--no-tags', help="if common patterns should be removed", action='store_true')
    parser.add_argument('--no-usernames', help="if usernames should be removed", action='store_true')
    parser.add_argument('--maintain-newlines', help="uses space as delim instead of newlines", action='store_true')
    parser.add_argument('--min-size', help="min token size to keep", type=int, default=2)
    args = parser.parse_args()
    return args


URL = r"(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})"
EMAIL = r"(\b[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}\b)"
PHONENUMBER = r"(([0-9]( |-)?)?(\(?[0-9]{3}\)?|[0-9]{3})( |-)?([0-9]{3}( |-)?[0-9]{4}|[a-zA-Z0-9]{7}))"
PRICE = r"(\$[0-9]+\.[0-9][0-9])"
DATE = r"(\b(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d\b)"
TIME = r"(\b([0-1]?[0-9]|[2][0-3]):([0-5][0-9])(:[0-5][0-9])?\b)"
HASHTAG = r"(\#+[\w_]+[\w\'_\-]*[\w_]+)"
USER = r"(?:\@+[\w_]+[\w\'_\-]*[\w_]+)"
APOSTROPHE = r"(\b[A-Za-z]+'[A-Za-z]+\b)"
HYPHEN = r"(\b[A-Za-z]+-[A-Za-z]+\b)"
PUNCT = r"([\#!\"$%&'()+,\-./:;<\|=>?@\[\\\]^_`{|}~])"
ROMAN = r"^(?=[MDCLXVI])M*(C[MD]|D?C{0,3})(X[CL]|L?X{0,3})(I[XV]|V?I{0,3})$"

def tokenize(text):
    """ takes string input and returns list of tokens, * before any special token"""
    regexes = [URL, EMAIL, PHONENUMBER, PRICE, DATE, TIME, HASHTAG, USER, APOSTROPHE, HYPHEN, PUNCT]
    text = re.sub("|".join(regexes), r" *\g<0> ", text)
    text = re.sub(r'\s+', ' ', text)
    words = text.split()
    return (words)

def no_tags_tokenize(text):
    # tags to be removed
    regexes = [URL, EMAIL, PHONENUMBER, PRICE, DATE, TIME]
    text = re.sub("|".join(regexes), r"", text)

    #missing hashtag, user, apostrophe, hypthen and punct
    regexes = [HASHTAG, USER, APOSTROPHE, HYPHEN, PUNCT]
    text = re.sub("|".join(regexes), r" *\g<0> ", text)
    text = re.sub(r'\s+', ' ', text)
    words = text.split()
    return words

def tags_tokenize(text):
    text = re.sub(URL, "*url", text)
    text = re.sub(EMAIL, "*emailaddress", text)
    text = re.sub(PHONENUMBER, "*phonenumber", text)
    text = re.sub(PRICE, "*price", text)
    text = re.sub(DATE, "*date", text)
    text = re.sub(TIME, "*time", text)

    #missing hashtag, user, apostrophe, hypthen and punct
    regexes = [HASHTAG, USER, APOSTROPHE, HYPHEN, PUNCT]
    text = re.sub("|".join(regexes), r" *\g<0> ", text)
    text = re.sub(r'\s+', ' ', text)
    words = text.split()

    # protect usernames and hashtags not needed with tree tagger
    #text = re.sub(USER, "User" + "\g<0>", text)
    #text = re.sub(r"\bUser\@", "User", text)
    return words

def remove_stopwords(word, stopwords):
    if word in stopwords:
        return ""
    else:
        return word 

def remove_non_dictionary(word, hspell):
    if hspell.spell(word):
        return word
    else:
        return ""

def convert_emoji(text, emojis):
    text.replace('*', '')
    text2 = re.sub(r"\X", r" \g<0> ", text)
    graphemes = text2.split(' ')
    for g in graphemes:
        query = ""
        for char in g:
            cp = "U+" + format((ord(char)), 'x').upper()
            if query == "":
                query = cp
            else:
                query = query + " " + cp
        if query in emojis:
            text = re.sub(g, emojis[query] + " ", text)

    return text

def load_stopwords_file(stopwords, stopwords_fpath):
    with open(stopwords_fpath) as sfile:
        for line in sfile:
            stopwords[line.rstrip()] = 1
    return stopwords

def load_emojis(script_path):
    emoji_csv_fpath = script_path + "/include/emoji.csv"
    emojis = {}
    with open(emoji_csv_fpath) as efile:
        for line in efile:
            line = line.rstrip()
            elem = line.split(',')
            desc = elem[2].translate(str.maketrans('','',punctuation))
            parts = desc.split(' ')
            desc = "*Emoji"
            for p in parts:
                desc = desc + p.capitalize()
            emojis[elem[0]] = desc
    return emojis

def print_result(tokens, maintain_newlines):

    if maintain_newlines:
        delim = " "
        if (len(tokens)) < 1:
            print("")
        else:
            print(delim.join(tokens))
    else:
        for t in tokens:
            print(t)

def get_script_path():
    return os.path.dirname(os.path.realpath(sys.argv[0]))

def main(args):
    script_path = get_script_path()

    if args.s:
        stopwords = {}
        stopwords = load_stopwords_file(stopwords, script_path  + "/include/stopwords.txt")
        if args.additional:
            additional_files = [f for f in os.listdir(script_path + "/include/additional/") if ".txt" in f]
            for stop_file in additional_files:
                stopwords = load_stopwords_file(stopwords, script_path + "/include/additional/" + stop_file)
    if args.d:
        hspell = hunspell.HunSpell(script_path + "/include/en_US.dic", script_path + "/include/en_US.aff")
        if args.additional:
            hspell.add_dic(script_path + "/include/additional/en_US-large.dic")
            hspell.add_dic(script_path + "/include/additional/en_GB-large.dic")
            
    if args.t:
        emojis = load_emojis(script_path)

    # ==================================================================================================== #
    #                               LOOP THROUGH FILE OR STDIN
    # ==================================================================================================== #
    for line in codecs.open(args.infile, "r", encoding="utf8", errors="ignore"):
        text = line.rstrip()

        if args.l:
          text = text.lower()
    
        if args.t: 
            text = convert_emoji(text, emojis)
            text = re.sub(r'"rt', '', text)
            text = re.sub(r'"', '', text)
            if (args.no_usernames):
                text = re.sub(USER, "", text)
        else:
            text = "".join([c for c in text if 0 < ord(c) < 127])
    
        if args.tags:
            words = tags_tokenize(text)
        elif args.no_tags:
            words = no_tags_tokenize(text)
        else:
            words = tokenize(text)
    
        clean_tokens = []
        for i,w in enumerate(words):
            if w[0] == "*":
                if len(w) == 2 and args.p: # makes sure punctuation is lost... e.g *.
                   continue

                if re.search("|".join([APOSTROPHE,HYPHEN]), w) and not re.search("|".join([URL,USER,EMAIL]), w):
                    if args.s: w = remove_stopwords(w, stopwords)
                    if args.d: w = remove_non_dictionary(w, hspell)

                if len(w) > args.min_size:
                   clean_tokens.append(w[1:])

            else:
                ## CLEANING
                    # punct
                if args.p:
                    w = w.translate(str.maketrans('','',punctuation)) 

                    # digits
                if args.n:
                    w = w.translate(str.maketrans('','',digits)) 

                    # roman numerals
                if args.r:
                    w = re.sub(ROMAN, "", w, flags=re.IGNORECASE)
                else:
                    if args.tags:
                        w = re.sub(ROMAN, "roman-numeral", w, flags=re.IGNORECASE)

                if args.s: w = remove_stopwords(w, stopwords)
                if args.d: w = remove_non_dictionary(w, hspell)

                if len(w) >= args.min_size:
                    clean_tokens.append(w)

        print_result(clean_tokens, args.maintain_newlines)
    
if __name__ == "__main__": 
    args = parse_arguments()
    main(args)
