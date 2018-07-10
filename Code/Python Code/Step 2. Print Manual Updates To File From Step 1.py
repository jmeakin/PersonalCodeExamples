import os
from google.cloud import storage
import simplejson as json
import pandas as pd

#####################################################
# Speficy Year:
year = "2016"
#####################################################


# set environment in Jupyter notebook
os.environ["GOOGLE_APPLICATION_CREDENTIALS"]="C:/Users/jmeakin/Desktop/HDA Project/Service Account Key/My First Project-2d07c9a62734.json"
print(os.environ['GOOGLE_APPLICATION_CREDENTIALS']) 

yearfile = 'all_%s_provider_data.csv'
yearfile = yearfile%(year)

path ='C:/Users/jmeakin/Desktop/HDA Project/Downloads/'
providercheck = pd.read_csv(path+yearfile)
providercheck = providercheck[providercheck['failed']==1]

badfiles = providercheck['filename'].tolist()
badfiles = badfiles[0:100]

# identify client & storage bucket
bucket_name = 'air-health'
storage_client = storage.Client()
bucket = storage_client.get_bucket(bucket_name)

for bfile in badfiles:
	blob = bucket.get_blob(bfile)
	stringjson = blob.download_as_string().decode("utf-8")
	# blank space for whether a numeric NPI Is found
	checknumeric = ''
	# Counter set up to record which split was reached
	counter = 1
	while checknumeric.isdigit() == False:
		if counter<len(stringjson.split('npi')):
			# if the counter is less than the total number of npi strings found, take the current subset following NPI
			# note, counter will increase for each time this fails (e.g. an NPI does not have a number)
			first_good_row = stringjson.split('npi')[counter]
			#make a little smaller
			first_good_row1 = first_good_row.split('"plan_id"')[0]
			first_good_row2 = first_good_row.split('"plan_id"')[1]
			start_npi=None
			end_npi=None
			for i in range(1,len(first_good_row1)):
				if first_good_row1[i-1].isdigit() == False and first_good_row1[i].isdigit()==True:
					start_npi=i
				if first_good_row1[i-1].isdigit() == True and first_good_row1[i].isdigit()==False:
					end_npi=i






			checknumeric = first_good_row[8:12]
			counter = counter+1
		elif counter == len(stringjson.split('npi')) and len(stringjson)>50:
			first_good_row = 'SEARCHED ---'+bfile+' no npi listed'
			break
		else:
			first_good_row = 'ERROR  ---'+bfile+' has no npi column'
			break
	print('INFO',bfile)
	print(first_good_row)
	print(counter-1)
print('Done')