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
SELECT npi, specialty 
FROM `healthy-keyword-159121.AirHealth2018.provider`, UNNEST(specialty) as specialty
WHERE (specialty IS NOT null or specialty !="")
GROUP BY npi, specialty 
"""
query = bigquery_client.query(sql).to_dataframe()
len(query)

# Drop Rows Where NPI In Specialty
specialtable = query[query['npi'] != query['specialty']]

# Fix delimiters, split columns and shape wide: 
# make Upper
specialtable['specialty'] = specialtable['specialty'].map(lambda x: str(x).upper())
# fix delimiters
for char in [',',';','|','\\','/','.']:
    specialtable['specialty'] = specialtable['specialty'].map(lambda x: str(x).replace(char,'_'))

# Make Columns
#specialtable = specialtable['specialty'].str.split('_', expand=True).join(specialtable)
specialtable = specialtable['specialty'].str.split('_', expand=True).add_prefix('Specialty_').join(specialtable)
specialtable = specialtable.drop_duplicates()
long_specialtable = pd.wide_to_long(specialtable, ["Specialty_"], i=['npi','specialty'], j="SpecialtyNum").reset_index()
long_specialtable = long_specialtable.dropna(subset=['Specialty_'])

# drop ininformative rows
long_specialtable['Specialty_'] =  long_specialtable['Specialty_'].map(lambda x: str(x).strip())
long_specialtable = long_specialtable[long_specialtable['Specialty_'] !=""]



specialtable['Specialty_'].value_counts()
speclist = long_specialtable['Specialty_'].tolist()
speclist = set(speclist)









