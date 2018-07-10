import pandas as pd
import getpass
from bs4 import BeautifulSoup

user = getpass.getuser()
rootdir = 'C:/Users/'+user+'/inSync Share/FuelEd-AIR Data/'
quest_file = 'LearnosityQuestions.csv'

questions = pd.read_csv(rootdir+quest_file)
print(len(questions))
questions.head()

def cleanhtml(x):
	try:
		soup=BeautifulSoup(x, "lxml")
		raw = soup.get_text()
	except:
		raw = 'Parsing Error'
	return raw
questions['CleanQuestion'] = questions['QuestionText'].apply(cleanhtml)
#questions['CleanQuestion'] = questions['QuestionText'].apply(lambda x : BeautifulSoup(x, 'lxml').get_text())
outloc = '//tx1cifs/tx1data/Austin Share/Detectors Of Engagement IES Goal 1/Secure Study Data/Learn Bop Data/Questions/'
outfile = 'CleanLearnosityQuestions.csv'
questions.to_csv(outloc+outfile)


''' Non-Pythonic Method
questions['CleanQuestion'] = questions['QuestionText']
for i in range(0,len(questions)):
	try:
		htmltext = questions.iloc[i]['QuestionText']
		soup=BeautifulSoup(htmltext, "lxml")
		raw = soup.get_text()
		questions['CleanQuestion'][i] = raw
	except:
		questions['CleanQuestion'][i] = 'Parsing Error'

outloc = '//tx1cifs/tx1data/Austin Share/Detectors Of Engagement IES Goal 1/Secure Study Data/Learn Bop Data/Questions/'
outfile = 'CleanLearnosityQuestions.csv'
questions.tocsv(outloc+outfile)