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

#https://google-cloud-python.readthedocs.io/en/latest/bigquery/usage.html
#https://google-cloud-python.readthedocs.io/en/latest/bigquery/usage.html#querying-data
from google.cloud import bigquery
bigquery_client = bigquery.Client()
datasets = bigquery_client.list_datasets()
project = bigquery_client.project

##################################################### Table To Upload (After Manualy Cleaned Cases) #####################################################
yearfile = 'all_%s_provider_data_manual_input.csv'
yearfile = yearfile%(year)
#####################################################  Tabe Uploaded TO BQ (What It's Called In BQ) #####################################################
table_id = '%s_qc_provider_table'
table_id = table_id%(year)
##################################################### New table that is created based on Merge #####################################################
table_id2 = '%s_conflicts'
table_id2 = table_id2%(year)

if year =="2018":
    table_id3 = 'AirHealth2018.provider'
elif year =="2017":
    table_id3 = 'AirHealth.provider_retry'
elif year =="2016":
    table_id3 = 'AirHealth2016.provider'


# Upload Table
filename = 'C:/Users/jmeakin/Desktop/HDA Project/Downloads/'+yearfile
rawfileupload = pd.read_csv(filename)
rawfileupload = rawfileupload[['failed','filename','npi','plan_id']]
dataset_id = 'Staging.%s'
dataset_id = dataset_id%(table_id)
project = bigquery_client.project
rawfileupload.to_gbq(dataset_id, project, if_exists='replace')

# Create A New Table With Query
query = """
SELECT filename, a.npi AS a_npi, a.plan_id AS a_plan_id,b.npi AS b_npi, b.plan_id AS b_plan_id
FROM (SELECT filename, cast(NPI AS STRING) AS npi, plan_id FROM `healthy-keyword-159121.Staging.%s`)  AS a
LEFT JOIN  
(SELECT npi, plans.plan_id AS plan_id FROM `healthy-keyword-159121.%s`, UNNEST(plans) AS plans) AS b
ON a.npi = b.npi
AND a.plan_id = b.plan_id
WHERE b.npi IS null
"""
fmtqry = query%(table_id,table_id3)
finalframe = bigquery_client.query(fmtqry).to_dataframe()
finalframe.head()

dataset_id2 = 'Staging.%s'
dataset_id2 = dataset_id2%(table_id2)
finalframe.to_gbq(dataset_id2, project, if_exists='replace')

