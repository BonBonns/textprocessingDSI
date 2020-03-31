#!/usr/bin/python3

# ==========================================================================================
#                          clean.py      
#     Arthur Koehl                         Version 3.1
#
#     Flags 
#      -l                      if words should be lowercased
#      -n                      if digits should be stripped 
#      -p                      if punctuation should be stripped
#      -r                      if roman numerals should be stripped
#      -s                      if stop words should be stripped
#      -d                      if non dictionary words should be stripped
#      -t                      if tweet specific cleaning options should be used
#      -z                      if removed words are to be the output
#      -c                      if remove words less than three characters
#      -f                      if two neighboring non dictionary words can be appened to form a dictionary word
#      -a                      if autocorrect should be applied
#      --additional            if triggered then adds all stopwords and dictionary files
#      --tags                  if common patterns should be tagged
#      --no-tags               if common patterns should be removed
#      --no-usernames          if usernames (@name) should be removed
#      --maintain-newlines     if set, will use space for delim instead of default(newline) 
#      --min-size              specify the minimum size for a token (default=2)
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
from textblob import Word
from datetime import datetime


HALF_WORD = ""
NON_DICT_FILE = "./non_dict_file"
NON_DICT_WORDS = []


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
    parser.add_argument('-z', help="print only non dictionary words", action='store_true', default=False)
    
    parser.add_argument('-a', help="autocorrect enter percentage followed by min wordlength", nargs=2, type=int)
    
    parser.add_argument('-f', help="if two seperate words can be appened to form a full word ", action='store_true',default=False)
    parser.add_argument('-c', help="remove words less than two characters", action='store_true',default=False)
    parser.add_argument('--additional', help="if additional stopwords and dictionaries should be loaded", action='store_true')
    parser.add_argument('--tags', help="if common patterns should be tagged", action='store_true')
    parser.add_argument('--no-tags', help="if common patterns should be removed", action='store_true')
    parser.add_argument('--no-usernames', help="if usernames should be removed", action='store_true')
    parser.add_argument('--maintain-newlines', help="uses space as delim instead of newlines", action='store_true')
    parser.add_argument('--min-size', help="min token size to keep", type=int, default=0)
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
    regexes = [URL, EMAIL, PHONENUMBER, PRICE, DATE, TIME, HASHTAG, USER]
    text = re.sub("|".join(regexes), r"", text)

    #apostrophe, hypthen and punct
    regexes = [APOSTROPHE, HYPHEN, PUNCT]
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

def auto_correct(word,percent):      
       
        
        new_percent = float(percent)
        new_percent = new_percent/100
        w = Word(word)
        fixed_word = w.spellcheck()
        if fixed_word[0][1] > new_percent : 
          return fixed_word[0][0] 
        else:
          return "FAILED"      


def remove_non_dictionary(word,hspell,is_auto_correct,append,remove_chars,percent,min_word_len):
   
   global HALF_WORD 
   dict_word = False
   
   if hspell.spell(word.upper()):
        dict_word = True
   
   if remove_chars == True and len(word)<3:
      return ""
    
   if len(word)>2 and dict_word == True:
      return word
   
   
   else:

  #at this point we might have a two letter non dictonary word.  
  #word may potntally be "half" a word wait until next itteration before resetting HALF_WORD 
     
      full_word = HALF_WORD+word
      if hspell.spell(full_word.upper()) and append == True:
        HALF_WORD = ""
        #NON_DICT_WORDS.append(full_word +" saved!")  
        #print(full_word +" Appended!")
        return full_word

      HALF_WORD = word
      if is_auto_correct == True and len(word)>=min_word_len:
         corrected_word = auto_correct(word,percent)
         if corrected_word != "FAILED":
           HALF_WORD = ""   
           return corrected_word
         else: 
           NON_DICT_WORDS.append(full_word)     
           return ""
      else:
        NON_DICT_WORDS.append(full_word)     
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
            if len(t) < 1:
                continue
            else:
                print(t)

def get_script_path():
    return os.path.dirname(os.path.realpath(sys.argv[0]))

def main(args):
    script_path = get_script_path()
    auto_correct = False
    append = False
    remove_chars = False   
    if args.s:
        stopwords = {}
        stopwords = load_stopwords_file(stopwords, script_path  + "/include/stopwords.txt")
        if args.additional:
            additional_files = [f for f in os.listdir(script_path + "/include/additional/") if ".txt" in f]
            for stop_file in additional_files:
                stopwords = load_stopwords_file(stopwords, script_path + "/include/additional/" + stop_file)
    
    
    percent = 0
    auto_correct = 0
    if args.a:
      percent = args.a[0]
      min_word_len = args.a[1]
      auto_correct = True  
    
    if args.f:
      append = True 
    if args.c:
      remove_chars = True   
      
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
        text = re.sub(r'\*', '', text)

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
                    if args.p: w = w.translate(str.maketrans('','',".?!#[]()$%&@:;,"))
                    if args.n: w = w.translate(str.maketrans('','',digits)) 
                    if args.s: w = remove_stopwords(w, stopwords)
                    if args.d: w = remove_non_dictionary(w,hspell,auto_correct,append,remove_chars,percent,min_word_len)

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
                if args.d: w = remove_non_dictionary(w,hspell,auto_correct,append,remove_chars,percent,min_word_len)

                if len(w) >= args.min_size:
                    clean_tokens.append(w)

        if args.z:
            print_result(NON_DICT_WORDS, args.maintain_newlines)
        else:
            print_result(clean_tokens, args.maintain_newlines)
if __name__ == "__main__": 
    args = parse_arguments()
    main(args)
