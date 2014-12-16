#! /usr/bin/pypy

import csv
import json
import math
import operator
import string

from collections import Counter
from itertools import chain

def main():
    # Training dataset
    T = import_data('training.csv')
    V = import_data('validation.csv')
    F = import_data('testing.csv')
    (word_map, word_idx_map) = gen_wordmap(T + V + F)
    print '# of insignificant words :%d\n # of feature words :%d' % (len(word_map),len(word_idx_map))
    cache_results(word_map, word_idx_map)

class DataRow:
    desc = []
    city = 0
    country = 0

    def __init__(self, csv_row):
        # Get description
        desc = csv_row[0]
        desc = desc.lower()                          # To lowercase
        includes = set(string.ascii_lowercase + ' ') # Filter everything apart from lowercase
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

    thresh = 0
    thresh_pct = 0.05

    i = 0
	# For each word in dict, go through all the words under it and try to find matches (levenshtein dist. small enough). 
    # Go through sorted list of tuples (word, count)
    while i < len(C):
        word1 = C[i][0]
        len1 = len(word1)
        thresh = round(thresh_pct * max(len1, len2))
	   	# Add word1 to word_idx_map
        #  significant word - to - index in feature matrix
        if word1 not in word_idx_map: 
            word_idx_map[word1] = w
            w += 1
        # Go through all words from index i + 1 (one after word1)
        j = i + 1
        while j < len(C):
            word2 = C[j][0]
            len2 = len(word2)

            # Check lengths before attempting levenshtein
            if abs(len1 - len2) > thresh:
                j += 1
                continue

            # Calculate custom levenshtein word-distance
            dist = levenshtein(word1, word2, thresh + 100)
            #print '%s <-> %s: %f' % (word1, word2, dist)

            # If distance below threshold, consider word2 insignificant
            if dist < thresh:
                word_map[word2] = word1 # word2 maps to word1
                del C[j]                # Remove word2 from C to skip in outer loop 			           

                print '(%d/%d) %s <- %s (%f)' % (i, len(C), word1, word2, dist)

            j += 1

        i += 1

    return (word_map, word_idx_map)

# levenshtein calculates the Levenshtein distance between two words and stops
# past a given threshold
def levenshtein(s1, s2, thresh):
    if len(s1) < len(s2):
        return levenshtein(s2, s1, thresh)

    # len(s1) >= len(s2)
    if len(s2) == 0:
        return len(s1)

    previous_row = range(len(s2) + 1)
    for i, c1 in enumerate(s1):
        current_row = [i + 1]

        # Exponentially decay score further from first char
        score = 1. / pow(1.2, i)

        for j, c2 in enumerate(s2):
            # j+1 instead of j since previous_row and current_row are one character longer
            insertions = previous_row[j + 1] + score

            # than s2
            deletions = current_row[j] + score

            substitutions = previous_row[j] + (c1 != c2)
            current_row.append(min(insertions, deletions, substitutions))

            # Early termin if threshold reached
            if current_row[-1] > thresh:
                return current_row[-1]

        previous_row = current_row

    return previous_row[-1]


if __name__ == "__main__":
    # execute only if run as a script
    main()
