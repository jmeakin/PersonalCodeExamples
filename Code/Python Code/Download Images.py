import pandas as pd
import getpass
import urllib.request
import urllib.parse

user = getpass.getuser()
rootdir = 'C:/Users/'+user+'/inSync Share/FuelEd-AIR Data/'
img_file = 'LearnosityQuestionImages.csv'

images = pd.read_csv(rootdir+img_file)
images.head()

# Drop Dups
print(len(images))
images.drop_duplicates(keep='first')
print(len(images))

#images = images[1:100]

#  Counter For Duplicated Problem/Question/StepNunmber (not at all pythonic, do not copy)
images.sort_values(by=['ProblemId','QuestionId','StepNumber'], inplace=True)
images.reset_index(inplace=True)
images['label'] = images.ProblemId.astype(str).str.cat(images.QuestionId.astype(str), sep='_').str.cat(images.StepNumber.astype(str), sep='_')
images['dupcount'] = None
images['dupcount'][0] = 1
for i in range(1,len(images)):
	if images['label'][i]==images['label'][i-1]:
		images['dupcount'][i]=images['dupcount'][i-1]+1
	else:
		images['dupcount'][i]=1

#from IPython.display import display, HTML
#display(HTML(images.to_html()))

sendto = '//tx1cifs/tx1data/Austin Share/Detectors Of Engagement IES Goal 1/Secure Study Data/Learn Bop Data/Images/'

for i in range(0,len(images)):
	try:
		url = str(images.iloc[i]['PicUrl']).replace(" ", "%20")
		name1 = images.iloc[i]['label']
		name2 = " ("+str(images.iloc[i]['dupcount'])+").jpg"
		photoname = name1+name2
		urllib.request.urlretrieve(url, sendto+photoname)
	except:
		name1 = images.iloc[i]['label']
		name2 = " ("+str(images.iloc[i]['dupcount'])+").txt"
		photoname = name1+name2
		failed = pd.DataFrame()
		failed.to_csv(sendto+photoname)


# Test
#url = str(images.iloc[1]['PicUrl']).replace(" ", "%20")
#urllib.request.urlretrieve(url, sendto+name)

