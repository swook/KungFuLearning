#! /usr/bin/python2

import csv
import json
import math
import operator
import string

import numpy as np
from sklearn.neighbors import KNeighborsClassifier, RadiusNeighborsClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.naive_bayes import MultinomialNB
from sklearn.feature_extraction.text import HashingVectorizer
from sklearn.svm import LinearSVC
from sklearn.feature_extraction.text import TfidfVectorizer 
 
from collections import Counter
from itertools import chain

from preprocess import import_data

def main():
    # Import training dataset and generate feature matrix
    (word_map, word_idx_map) = import_wordmap()

#    # Import datasets
#    (T, Y) = dat_to_featmat(import_data('training.csv'),   word_map, word_idx_map)
#    (V, _) = dat_to_featmat(import_data('validation.csv'), word_map, word_idx_map)
#    (F, _) = dat_to_featmat(import_data('testing.csv'),    word_map, word_idx_map)
#
#    # Print diagnostics
#    print 'Total no. of words in all datasets: %d' % (len(word_map) + len(word_idx_map))
#    print 'Reduced down to %d words.\n' % len(word_idx_map)
#    print 'T: %s x %s' % T.shape
#    print 'V: %s x %s' % V.shape
#    print 'F: %s x %s\n' % F.shape
    DT = import_data('training.csv') 
    (ST,Y) = dat_to_featstring(DT, word_map)
    DV = import_data('validation.csv')
    (SV,_) = dat_to_featstring(DV, word_map)
    T = featstring_to_charMatrix(ST)
    V = featstring_to_charMatrix(SV)
    print ST
      
#    vectorizer=HashingVectorizer()
#    vectorizer=TfidfVectorizer()
#    T=vectorizer.fit_transform(ST)
#    V=vectorizer.transform(SV)

    # Create K-nearest neighbors classifier
    neigh = KNeighborsClassifier(n_neighbors=10)
#    neigh = RadiusNeighborsClassifier(radius=6)
    neigh.fit(T, Y) # Fit to classifier
    print 'Training complete\n'

#    # Create Decision Tree classifier
#    tree = DecisionTreeClassifier()
#    tree.fit(T, Y) # Fit to classifier
#    print 'Training complete\n'
#    
	# Create Naive Bayes Classifier  
#    clf = MultinomialNB()
#    clf.fit(T,Y) # Fit to classifier
#    print 'Training complete\n'

    # Create svm classifier
#    clf = LinearSVC()
#    clf.fit(T,Y)
#    print 'Training complete\n'

    #model = train(T, Y)
    #Y_hat = classify(T, model)
    #err = calc_error(Y, Y_hat)
    #print err

    Y_hat = neigh.predict(V)
#    Y_hat = tree.predict(V)
#    Y_hat = clf.predict(V)
    write_results('predictions_V.txt', Y_hat)
    print Y_hat								


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

def dat_to_featstring(dat, word_map):
	M = len(dat)
	Y = np.zeros(M)
	S = []
	# Go through each row in dataset
	for i, row in enumerate(dat):
		name=""
		for word in row.desc:
			# If word is insignificant word
			# replace with significant word
			if word in word_map:
				word = word_map[word]

			# Increase count
			word=str(word)
#			S[i].append(word)
			name+=" "+ word
		if row.city:
			Y[i] = row.city
		S.append(name)	
	return (S, Y)

def featstring_to_charMatrix(S):
	M = len(S)
	alphabet = list(string.ascii_lowercase+string.digits)
	print alphabet
	N = len(alphabet)
	Mat = np.zeros((M,N))
	for i in xrange(M):
		name = S[i]
#		chars = list(name)
		for j in xrange(N) : 
			char=alphabet[j]
			Mat[i,j]=name.count(char)
	return Mat

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
            lst = [int(city),int(math.floor(city / 1000))]
            writer.writerow(lst)

if __name__ == "__main__":
    # execute only if run as a script
    main()
