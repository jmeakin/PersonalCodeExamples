import os
from google.cloud import storage
import simplejson as json
import pandas as pd

#####################################################
# Speficy Year:
year = "2016"
#####################################################


##################################################### Bucket #####################################################
bucket = 'air-health'
if year =="2018":
    prefix = '2018/provider_json/'
elif year =="2017":
    prefix = 'provider_json/'
elif year =="2016":
    prefix = '2016/new_line/'
##################################################### Table To Save Locally #####################################################
outputfile = 'all_%s_provider_data'
outputfile = outputfile%(year)

# set environment in Jupyter notebook
os.environ["GOOGLE_APPLICATION_CREDENTIALS"]="C:/Users/jmeakin/Desktop/HDA Project/Service Account Key/My First Project-2d07c9a62734.json"
print(os.environ['GOOGLE_APPLICATION_CREDENTIALS']) 

# identify client & storage bucket
bucket_name = bucket
storage_client = storage.Client()
bucket = storage_client.get_bucket(bucket_name)

# loop through each blob and grab first row of each (take NPI & PlanID)
#count total
total =0
for b in bucket.list_blobs(delimiter='/',prefix=prefix):
	total = total+1
total

blobs = bucket.list_blobs(delimiter='/',prefix=prefix)
providerjsontable = pd.DataFrame()
iteration = 0
for blob in blobs:
	try:
		# decode string to get rid of "b' and \m"
		forjson = blob.download_as_string().decode("utf-8")
		# Take First Valid NPI
		npi = None
		counter = 1
		while npi == None or npi=='':
			# take second element in split of entire stirng (this equals the first row of Jsonfile)
			first_good_row = forjson.split('{"npi":')[counter]
			# add back on the string (in theory this should work with \\n, but doesnt because of b')
			first_good_row = '{"npi":'+first_good_row
			# create dictionary from json file
			mydict = json.loads(first_good_row)
			# Take NPI from dictionary
			npi = mydict['npi']
			counter = counter +1
		# Plans is a list within the dictionary (list of one dictionary)
		plans = mydict['plans']
		otheriddict = plans[0]
		# take plan id from dictiary within plans list (list of dictionaries)
		plan_id = otheriddict['plan_id']
		# grab file name
		filename = str(blob.name)

		# Store values in dataframe
		dataframe = pd.DataFrame(columns=['npi', 'plan_id','filename'])
		dataframe.loc[0] = 0
		dataframe['npi']=npi
		dataframe['plan_id'] = plan_id
		dataframe['filename']=filename
		# append to master
		providerjsontable = pd.concat([providerjsontable, dataframe], ignore_index=True)
	except:
		filename = str(blob.name)
		dataframe = pd.DataFrame(columns=['failed', 'filename'])
		dataframe.loc[0] = 0
		dataframe['filename']=filename
		dataframe['failed']= 1
		providerjsontable = pd.concat([providerjsontable, dataframe], ignore_index=True)
	iteration = iteration+1
	print(iteration,'of',total,'complete')

providerjsontable.to_csv('C:/Users/jmeakin/Desktop/HDA Project/Downloads/'+outputfile+'.csv')
providerjsontable.head()