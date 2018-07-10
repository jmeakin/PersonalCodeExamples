import os
from google.cloud import storage
import simplejson as json
import pandas as pd

# set environment in Jupyter notebook
os.environ["GOOGLE_APPLICATION_CREDENTIALS"]="C:/Users/jmeakin/Desktop/HDA Project/Service Account Key/My First Project-2d07c9a62734.json"
print(os.environ['GOOGLE_APPLICATION_CREDENTIALS']) 

#https://google-cloud-python.readthedocs.io/en/latest/bigquery/usage.html
#https://google-cloud-python.readthedocs.io/en/latest/bigquery/usage.html#querying-data
from google.cloud import bigquery
bigquery_client = bigquery.Client()

# https://cloud.google.com/bigquery/docs/reference/standard-sql/migrating-from-legacy-sql
sql = """
    SELECT npi, gender 
    FROM `healthy-keyword-159121.AirHealth2018.provider`
    WHERE (gender is not null or gender !="" ) and type = "INDIVIDUAL"      
"""
gendtable = bigquery_client.query(sql).to_dataframe()
# Drop Useless Rows
gendtable = gendtable[gendtable['npi'].isin([''])==False]
gendtable = gendtable.dropna(subset=['npi'])
gendtable = gendtable[gendtable['gender'].isin([''])==False]
gendtable = gendtable[gendtable['gender'].map(lambda x: str(x).upper())!='NULL']


# Create Counts Of NPI abd Gender
npigencounts = gendtable.groupby([ 'npi','gender']).size().to_frame().reset_index()
# Merge to Data To drop dups
new_gendtable = pd.merge(gendtable, npigencounts, how='outer', on=['npi','gender'], indicator=True, validate='many_to_one')
new_gendtable['_merge'].value_counts()
#observe = gendtable[gendtable['_merge'].isin(['left_only'])==True]

new_gendtable = new_gendtable[['npi','gender',0]]
new_gendtable = new_gendtable.drop_duplicates(keep='first')
new_gendtable = new_gendtable[['npi','gender']]

npicounts = new_gendtable.groupby([ 'npi']).size().to_frame().reset_index()
new_gendtable2 = pd.merge(new_gendtable, npicounts, how='outer', on=['npi'], indicator=True, validate='many_to_one')
new_gendtable2['_merge'].value_counts()
print(new_gendtable2[0].value_counts())

# Final Table Getting Uploaded To BQ
new_gendtable2 = new_gendtable2[['npi','gender']]


# Note: conda install pandas-gbq --channel conda-forge
project = bigquery_client.project
new_gendtable2.to_gbq('Entity.NPI_gender_2018', project, if_exists='replace')
















