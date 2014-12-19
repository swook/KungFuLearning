#! /usr/bin/pypy

import csv
import json
import math
import operator
import string

from collections import Counter
from itertools import chain

def main():
    prep_levenshtein() # Calculate some numbers in advance

    # Training dataset
    T = import_data('training.csv')
    V = import_data('validation.csv')
    F = import_data('testing.csv')
    (word_map, word_idx_map) = gen_wordmap(T + V + F)
    #(word_map, word_idx_map) = gen_wordmap(T)
    #(word_map) = gen_wordTestMap(V + F,word_map,word_idx_map)
    print '# of insignificant words: %d' % len(word_map)
    print '# of feature words: %d'       % len(word_idx_map)
    cache_results(word_map, word_idx_map)

class DataRow:
    desc = []
    city = 0
    country = 0

    def __init__(self, csv_row):
        # Get description
        desc = csv_row[0]
        desc = desc.lower()                     # To lowercase
        includes = set(                         # Filter everything apart from...
                       string.ascii_lowercase + # - lowercase
                       string.digits +          # - digits
                       ' '                      # - whitespace
                   )
        desc = ''.join(ch for ch in desc if ch in includes)
        self.desc = desc.split() # Split into list of words

        # Get country and city codes
        if len(csv_row) > 1:
            self.city = int(csv_row[1]);
            self.country = int(csv_row[2])

    # Basic string repr of object of this class
    def __str__(self):
        items = self.desc
        items.extend([str(self.city), str(self.country)])
        return " ".join(items)


# Import data from CSV file and return feature and class matrices
def import_data(fname):
    dat = []

    with open("../data/"+ fname, "r") as f:
        reader = csv.reader(f)
        for idx, row in enumerate(reader):
            dat.append(DataRow(row))

    return dat

# Caches data to file
def cache_results(word_map, word_idx_map):

    # Insignificant word - to - Significant word
    with open('../data/word_map.json', 'w') as f:
        json.dump(word_map, f)

    # Significant word - to - Index in feature matrix
    with open('../data/word_idx_map.json', 'w') as f:
        json.dump(word_idx_map, f)


# Reduce duplicate information
# Returns map of insignificant word to significant word
def gen_wordmap(dat):
    # Count word occurrences
    C = Counter([x for x in chain.from_iterable(row.desc for row in dat)])

    # Convert to sorted list of (word, occurrence_count)
    C = sorted(C.items(), key=operator.itemgetter(1), reverse=True)

    # Iterate through list and combine words
    word1 = ''
    word2 = ''
    len1 = 0
    len2 = 0
    count1 = 0
    count2 = 0

    word_map     = {}
    word_idx_map = {}
    w = 0

    thresh_pct = 0.39	# was 0.39

    # For each word in dict, go through all the words under it and try to find
    # matches (levenshtein dist. small enough).
    #
    # Go through sorted list of tuples (word, count)
    i = 0
    while i < len(C):
        word1 = C[i][0]

        # Add word1 to word_idx_map
        #  significant word - to - index in feature matrix
        if (word1 not in word_idx_map):
            word_idx_map[word1] = w
            w += 1

        len1 = len(word1)
        count1 = C[i][1]
        thresh = thresh_pct * max(len1, len2)

        # Go through all words from index i + 1 (one after word1)
        j = i + 1
        while j < len(C):
            word2 = C[j][0]
            len2 = len(word2)

            # Check lengths before attempting levenshtein
            if (abs(len1 - len2) > thresh):
                j += 1
                continue

            # Calculate custom levenshtein word-distance
            dist = levenshtein(word1, word2)
            #print '%s <-> %s: %f' % (word1, word2, dist)
            # If distance below threshold, consider word2 insignificant
            if dist < thresh_pct:
                word_map[word2] = word1 # word2 maps to word1
                del C[j]                # Remove word2 from C to skip in outer loop
                print '(%d/%d) %s <- %s (%f)' % (i, len(C), word1, word2, dist)

            j += 1

        i += 1

    return (word_map, word_idx_map)

def gen_wordTestMap(dat,word_map,word_idx_map):
    # Count word occurrences
    C = Counter([x for x in chain.from_iterable(row.desc for row in dat)])

    # Convert to sorted list of (word, occurrence_count)
    C = sorted(C.items(), key=operator.itemgetter(1), reverse=True)

    # Iterate through list and combine words
    word1 = ''
    word2 = ''
    len1 = 0
    len2 = 0
    count1 = 0
    count2 = 0

    dictionary = word_idx_map.keys()
    print len(dictionary)
    print len(word_idx_map)
    thresh_pct = 0.39   # was 0.39
    print "Processing new words"

    i = 0
    # Map new words
    while i < len(C):
        print '%s\r' % ' '*20,
        print '   ' , i*100/len(C),
        word1 = C[i][0]
        

        # If word1 not in word_map, then find the most close 
        if (word1 not in word_map):
            min_dist = 10000
            for j in xrange(len(dictionary)):
                word2 = dictionary[j]
                dist = levenshtein(word2, word1)
                if dist < min_dist:
                    min_dist = min
                    word_map[word1] = word2

        i += 1

    return (word_map)


decay_fac  = 1.5 # Decay factor to value first chars more in levenshtein dist
scores     = []  # Pre-calculation of score at index
max_scores = []  # Pre-calculation of max scores possible

def prep_levenshtein():
    max_score = 0.
    for i in range(0, 100):
        scores.append(1. / pow(decay_fac, i))
        max_score += scores[-1]
        max_scores.append(max_score)

# levenshtein calculates the Levenshtein distance between two words
# Returns a value in range [0, 1]
def levenshtein(s1, s2):
    if len(s1) < len(s2):
        return levenshtein(s2, s1)

    previous_row = range(len(s2) + 1)
    for i, c1 in enumerate(s1):
        current_row = [i + 1]

        # Exponentially decay score further from first char
        score = scores[i]

        for j, c2 in enumerate(s2):
            # j+1 instead of j since previous_row and current_row are one character longer
            insertions = previous_row[j + 1] + 1

            # than s2
            deletions = current_row[j] + 1

            substitutions = previous_row[j] + (score if c1 != c2 else 0)
            current_row.append(min(insertions, deletions, substitutions))

            # Early termin if threshold reached
            # TODO: This doesn't work... try to fix
            #if current_row[-1] > thresh:
            #    break

        previous_row = current_row

    return previous_row[-1] / max_scores[len(s1) - 1] # Normalise


if __name__ == "__main__":
    # execute only if run as a script
    main()
