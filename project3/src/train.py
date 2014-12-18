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
from sklearn.svm import SVC
from sklearn.feature_extraction.text import TfidfVectorizer 
from sklearn import cross_validation
from sklearn.metrics import make_scorer
from sklearn.cluster import MiniBatchKMeans
 
from collections import Counter
from itertools import chain

from preprocess import import_data

def main():
    # Import training dataset and generate feature matrix
    (word_map, word_idx_map) = import_wordmap()

#    # Import datasets
    (T, Y) = dat_to_featmat(import_data('training.csv'),   word_map, word_idx_map)
    (V, _) = dat_to_featmat(import_data('validation.csv'), word_map, word_idx_map)
#    (F, _) = dat_to_featmat(import_data('testing.csv'),    word_map, word_idx_map)
#
#    # Print diagnostics
#    print 'Total no. of words in all datasets: %d' % (len(word_map) + len(word_idx_map))
#    print 'Reduced down to %d words.\n' % len(word_idx_map)

    DT = import_data('training.csv') 
    (ST,Y) = dat_to_featstring(DT, word_map)
    Y_country = np.floor(Y / 1000);
    DV = import_data('validation.csv')
    (SV,_) = dat_to_featstring(DV, word_map)
    T = featstring_to_charMatrix(ST)
    V = featstring_to_charMatrix(SV)

#    vectorizer = TfidfVectorizer()	
#    T = vectorizer.fit_transform(ST)
#    V = vectorizer.transform(SV)
    del DT,ST,DV,SV,word_map,word_idx_map
    # Create K-nearest neighbors classifier
    clf = SVC()
#    print Y
#    write_results('Y_org.txt', Y)

#    Y = correct_y(T,Y)
#    write_results('Y_changed.txt', Y)

	# Create Naive Bayes Classifier  
    #clf = MultinomialNB()

    # Fit to Classifier
    clf.fit(T,Y_country) 
    print 'Training complete\n'

	# Estimate error with crossvalidation
#    score=crossValidation(T,Y,clf)
    Y_country_hat = np.zeros(32300)	
    # Calculate predictions
    for i in xrange(32300):
       print '%s\r' % ' '*20,
       print '   ' , i*100/32300, 
       Y_country_hat[i] = clf.predict(V[i])
    Y_hat = classifyPerCountry(T,V,Y,Y_country_hat)
    write_results('predictions_V_new.txt', Y_hat)
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

def correct_y(X,Y):
	# Correct wrongly assigned ZIP codes
	print "Correcting wrong ZIP codes..."
	[N, Nfeats]=X.shape
	NZIP=857
	# use K-means clustering to make it faster
	cluster=MiniBatchKMeans(NZIP,init_size=2000,max_iter=500)
	cluster_distance = cluster.fit_transform(X)
	cluster_values = cluster.predict(X)
	clstr=np.zeros((N,2))
	min_dist=1000*np.ones(NZIP)
	Y_min=np.zeros(NZIP)
	# clstr contains for each line cluster and cluster distance to center
	for i in xrange(N):
		idx = int(cluster_values[i])	
		clstr[i][0]=idx
		clstr[i][1]=cluster_distance[i][idx]
		if (clstr[i][1]<min_dist[idx]) :
			min_dist[idx]=clstr[i][1]
			Y_min[idx]=Y[i]
	counter=0
	for i in xrange(N):
		idx = int(clstr[i][0])
		if ((clstr[i][1]<1.5) & (int(Y[i]/1000)==int(Y_min[idx]/1000))) :	
			Y[i]= Y_min[idx]
			counter+=1
	print "%s ZIP codes corrected.", counter
	return(Y)

def dat_to_featstring(dat, word_map):
	print "Creating new string Matrix..."
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
	print "Creating character feature Matrix..."
	M = len(S)
	alphabet = list(string.ascii_lowercase+string.digits)
#	print alphabet
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

def calcError(clf,X,Y):
	# format has to be function(clf,X,Y) for the crossvalidation
	Yhat=clf.predict(X)
	Yhat_country = Yhat/1000
	Yhat_city = Yhat%1000
	Y_country = Y/1000
	Y_city = Y%1000
	unequal_city=np.in1d(Y_city,Yhat_city,invert=True)
	unequal_country=np.in1d(Y_country,Yhat_country,invert=True)
	perr = sum(unequal_city)+0.25*sum(unequal_country)
	# scale error to be comparable with the one on the whole validaion set
	perr *= (32220/len(X)) 
	return perr

def crossValidation(X,Y,clf):
	print "Cross-validation..."
	[N, Nfeats]=X.shape
	# No. of subsets
#	K = int(math.sqrt(N))
	K = 3
	
	# Do cross validation using calcError function 
	scores = cross_validation.cross_val_score(clf, X, Y, cv=K, scoring=calcError)
	print "Error: %0.2f (+/- %0.2f)" % (scores.mean(), scores.std() / 2)
	return scores
	
def write_results(fname, Y):
    with open('../' + fname, 'w') as f:
        writer = csv.writer(f)
        for city in Y:
            lst = [int(city),int(math.floor(city / 1000))]
            writer.writerow(lst)
def classifyPerCountry(T,V,Y,Y_country_hat):
	Y_country = np.floor(Y / 1000)
	print "\nClassifying per Country"
	Y_city = Y 
	country_codes = list(set(Y_country))
	nCountryCodes = len(country_codes)
	Y_hat = np.zeros(len(Y_country_hat))
	for i in xrange(nCountryCodes):
		print '%s\r' % ' '*20,
		print '   ' , i*100/nCountryCodes,
#		clf = MultinomialNB(0.5)
		clf = SVC()
		country_idx = np.in1d(Y_country,country_codes[i])
		country_idx_sparse = country_idx.nonzero()[0]
		T_country = T[country_idx_sparse,:]
		Y_cityPerCountry = Y_city[country_idx]
		unique_Y_cityPerCountry=list(set(Y_cityPerCountry))
		predict_idx = np.in1d(Y_country_hat,country_codes[i])
		predict_idx_sparse = predict_idx.nonzero()[0]
		if len(unique_Y_cityPerCountry)==1 :
			Y_hat[predict_idx] = unique_Y_cityPerCountry
			continue
		clf.fit(T_country,Y_cityPerCountry)
		if sum(predict_idx) > 1:
			Y_cityPerCountry_hat = clf.predict(V[predict_idx_sparse,:])
			Y_hat[predict_idx] = Y_cityPerCountry_hat
	print "\n"
	return Y_hat
if __name__ == "__main__":
    # execute only if run as a script
    main()
