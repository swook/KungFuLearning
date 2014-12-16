#! /usr/bin/python2

import csv
import json
import math
import operator
import string

import numpy as np
from sklearn.neighbors import KNeighborsClassifier

from collections import Counter
from itertools import chain

from preprocess import import_data

def main():
    # Import training dataset and generate feature matrix
    (word_map, word_idx_map) = import_wordmap()
    (T, Y) = dat_to_featmat(import_data('training.csv'), word_map, word_idx_map)

    # Create K-nearest neighbors classifier
    neigh = KNeighborsClassifier(n_neighbors=3)
    neigh.fit(T, Y) # Fit to classifier

    #model = train(T, Y)
    #Y_hat = classify(T, model)
    #err = calc_error(Y, Y_hat)
    #print err

    (V, _) = dat_to_featmat(import_data('validation.csv'), word_map, word_idx_map)
    print 'V = %s\nsize(V): %s\nsize(T): %s' % (V, V.size, T.size)
    Y_hat = neigh.predict(V)
    write_results('predictions_V.txt', Y_hat)
    print Y_hat
    return

    (F, _) = dat_to_featmat(import_data('testing.csv'), word_map, word_idx_map)

def import_wordmap():

    # Insignificant word - to - Significant word
    with open('../data/word_map.json', 'r') as f:
        word_map = json.load(f)

    # Significant word - to - Index in feature matrix
    with open('../data/word_idx_map.json', 'r') as f:
        word_idx_map = json.load(f)

    return (word_map, word_idx_map)

# Uses reduced dataset to create feature and class matrices
def dat_to_featmat(dat, word_map, word_idx_map):
    M = len(dat)
    N = len(word_idx_map)
    X = np.zeros((M, N))
    Y = np.zeros(M)

    idx = 0
    wordToId = {}

    # Go through each row in dataset
    for i, row in enumerate(dat):
        for word in row.desc:
            # If word is insignificant word
            # replace with significant word
            if word in word_map:
                word = word_map[word]

            # Find index on feature matrix
            idx = word_idx_map[word]

            # Increase count
            X[i, idx] += 1

        if row.city:
            Y[i] = row.city

    return (X, Y)

def train(X, Y):
    pass

def classify(X, model):
    pass

def calc_error(Y, Y_hat):
    pass

def write_results(fname, Y):
    with open('../' + fname, 'w') as f:
        writer = csv.writer(f)
        for city in Y:
            writer.writerow([city, math.floor(city / 1000)])

if __name__ == "__main__":
    # execute only if run as a script
    main()
