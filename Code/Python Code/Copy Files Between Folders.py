import os
import pandas as pd
from shutil import copyfile
import time

fromloc = '//tx1cifs/tx1data/Austin Share/Detectors Of Engagement IES Goal 1/Secure Study Data/Learn Bop Data/Images/'
toloc = '//tx1cifs/tx1data/Austin Share/Detectors Of Engagement IES Goal 1/Secure Study Data/Learn Bop Data/Unique Images/'
idfile ='//tx1cifs/tx1data/Austin Share/Detectors Of Engagement IES Goal 1/Secure Study Data/Learn Bop Data/PhotoDuplicates.xlsx'


# load list of unique files
uniques = pd.read_excel(idfile)
uniques = uniques[1]
uniques = uniques.tolist()

#uniques = uniques[1:100]
#print(len(uniques))

start = time.time()
iteration = 0
for photo in uniques:
	copyfile(fromloc+photo+'.jpg',toloc+photo+'.jpg')
	print("total time taken this loop: ", time.time() - start)
	iteration = iteration+1
	print(iteration)