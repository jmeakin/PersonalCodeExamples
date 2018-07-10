import os
from google.cloud import storage
import simplejson as json
import pandas as pd
from fuzzywuzzy import process, fuzz

# set environment in Jupyter notebook
os.environ["GOOGLE_APPLICATION_CREDENTIALS"]="C:/Users/jmeakin/Desktop/HDA Project/Service Account Key/My First Project-2d07c9a62734.json"
print(os.environ['GOOGLE_APPLICATION_CREDENTIALS']) 

#https://google-cloud-python.readthedocs.io/en/latest/bigquery/usage.html
#https://google-cloud-python.readthedocs.io/en/latest/bigquery/usage.html#querying-data
from google.cloud import bigquery
bigquery_client = bigquery.Client()


sql = """
    SELECT npi, addresses.city, addresses.zip, addresses.phone, addresses.state, addresses.address, addresses.address_2
    FROM `healthy-keyword-159121.AirHealth2018.provider`, UNNEST(addresses) as addresses
    WHERE addresses is not NULL
    GROUP BY npi, addresses.city, addresses.zip, addresses.phone, addresses.state, addresses.address, addresses.address_2
    #### REMOVE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    #LIMIT 10000
    #### Remove: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
"""
addresses = bigquery_client.query(sql).to_dataframe()
addresses.head()

# Remove punctuatuon from collumns
for i in addresses.columns:
    for char in [',',';','|','\\','/','.','-','(',')',':','"','#','&',"'"]:
        addresses[i] = addresses[i].map(lambda x: str(x).replace(char,''))
        addresses[i] = addresses[i].map(lambda x: str(x).title())
        addresses[i] = addresses[i].map(lambda x: str(x).strip())
# make upper, remove spaces, and remove "Nones"
addresses['state'] = addresses['state'].map(lambda x: str(x).upper())
addresses['phone'] = addresses['phone'].map(lambda x: str(x).replace(' ',''))
#addresses['address_2'] = addresses['address_2'].map(lambda x: str(x).replace('None',''))

# see what it looks like when address has no number, but address 2 does
#browseaddress = addresses[addresses['address_2'].map(lambda x: any(i.isdigit() for i in x)==True)]
#browseaddress = browseaddress[browseaddress['address'].map(lambda x: any(i.isdigit() for i in x)==False)]
#browseaddress = browseaddress[browseaddress['address'].map(lambda x: str(x).startswith('One')==False)]
#browseaddress.to_excel('C:/Users/jmeakin/Desktop/HDA Project/Addresses/Idea1.xlsx')

# Swap rows where no numbers in address, but numbers in addrss 2
def swapfn(x):
	if any(i.isdigit() for i in x['address_2']) and not any(i.isdigit() for i in x['address']) and not str(x['address']).startswith('One'):
		return x['address_2']
	else:
		return x['address']
addresses['address'] = addresses.apply(lambda x: swapfn(x), axis=1)
#addresses['address'] = addresses.map(swapfn, axis=1)

# combine columns & make all upper to match with pre-geo-coded data 
addresses['unique_address'] = addresses['address']+","+addresses['city']+","+addresses['state']+","+addresses['zip'].map(lambda x: str(x))
addresses['unique_address'] = addresses['unique_address'].map(lambda x: str(x).upper())

# Create a list of de-duplicated addresses
deduped_address = addresses.drop_duplicates(subset='unique_address')
deduped_address['tempzip'] = deduped_address['unique_address'].map(lambda x: str(x).split(',')[-1])
deduped_address['unique_address'] = deduped_address.apply(lambda x: str(x['unique_address']).replace(','+str(x['tempzip']),''), axis=1)

def fixzip(x):
	if len(x['zip'])>=5:
		return x['zip']
	if len(x['zip'])==4:
		return '0'+x['zip']
	if len(x['zip'])==3:
		return '00'+x['zip']
	if len(x['zip'])==2:
		return '000'+x['zip']
	if len(x['zip'])==1:
		return '0000'+x['zip']

deduped_address['zip'] = deduped_address.apply(lambda x: fixzip(x), axis=1) 
deduped_address = deduped_address[['unique_address','zip']]

# Import pre-geo-coded addreses
pre_coded_addresses = pd.read_csv('C:/Users/jmeakin/Desktop/HDA Project/Addresses/geocoded_addresses_total_v2.txt', sep='\t')
pre_coded_addresses = pre_coded_addresses.dropna(subset=['lat', 'long'])

for char in [';','|','\\','/','.','-','(',')',':','"','#','&',"'"]:
	pre_coded_addresses['address'] = pre_coded_addresses['address'].map(lambda x: str(x).replace(char,''))
pre_coded_addresses['address'] = pre_coded_addresses['address'].map(lambda x: str(x).strip())

pre_coded_addresses = pre_coded_addresses.drop_duplicates(subset='address')

# extract Zip Frop pre-coded address:
pre_coded_addresses['zip'] = pre_coded_addresses['address'].map(lambda x: x.split(',')[-1])

# Create Final address to match and fix zip:
pre_coded_addresses['tempzip'] = pre_coded_addresses['address'].map(lambda x: str(x).split(',')[-1])
pre_coded_addresses['address'] = pre_coded_addresses.apply(lambda x: str(x['address']).replace(','+str(x['tempzip']),''), axis=1)
pre_coded_addresses = pre_coded_addresses[['address','zip','lat','long']]
pre_coded_addresses['zip'] = pre_coded_addresses.apply(lambda x: fixzip(x), axis=1) 


#### Remove: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#addresses = addresses.sample(1000)
#deduped_address = deduped_address[deduped_address['unique_address'].map(lambda x: str(x).startswith('98') or str(x).startswith('99') or str(x).startswith('100'))]
#deduped_address.sort_values(by=['unique_address','zip'], inplace=True)
#deduped_address = deduped_address.reset_index(drop=True)
#deduped_address = deduped_address[0:1000]

#pre_coded_addresses = pre_coded_addresses[pre_coded_addresses['address'].map(lambda x: str(x).startswith('98') or str(x).startswith('99') or str(x).startswith('100'))]
#pre_coded_addresses.sort_values(by=["address"], inplace=True)
#pre_coded_addresses = pre_coded_addresses.reset_index(drop=True)
#pre_coded_addresses = pre_coded_addresses[0:1000]
#### Remove: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Check Un-fuzzy merge
combined = pd.merge(deduped_address, pre_coded_addresses, how='outer', left_on =['unique_address','zip'], right_on=['address','zip'],indicator=True, validate='one_to_one')
combined.head()
combined['_merge'].value_counts()

######################### Resources
# http://chairnerd.seatgeek.com/fuzzywuzzy-fuzzy-string-matching-in-python/
# http://blog.keyrus.co.uk/fuzzy_matching_101_part_i.html

# Deduplicate Using Fuzzy
#process.extractOne('john', ['james','jim','jonathan'])


pre_coded_addresses['stnum'] = pre_coded_addresses['address'].map(lambda x: x.split(' ')[0])
deduped_address['stnum'] = deduped_address['unique_address'].map(lambda x: x.split(' ')[0])

#def get_matching_zip(df, zipcode):
#	return list(df[df['zip']==zipcode]['address'])

def get_matching_zip_and_stnum(df, zipcode,stnum):
	return list(df[(df['zip']==zipcode) & (df['stnum']==stnum)]['address'])

def fuzzy_match(x, choices, scorer, cutoff):
    return process.extractOne(x, choices=choices, scorer=scorer, score_cutoff=cutoff)
#deduped_address['newfield'] = deduped_address.loc[:, 'unique_address'].apply(fuzzy_match, args=(pre_coded_addresses.loc[:, 'address'], fuzz.ratio, 90))
#deduped_address['newfield'] = deduped_address.apply(lambda x: fuzzy_match(x['unique_address'], get_matching_zip(pre_coded_addresses,x['zip']), fuzz.ratio, 85), axis=1)
deduped_address['newfield'] = deduped_address.apply(lambda x: fuzzy_match(x['unique_address'], get_matching_zip_and_stnum(pre_coded_addresses,x['zip'], x['stnum']), fuzz.ratio, 85), axis=1)



deduped_address[['match_address', 'match_val']] = deduped_address['newfield'].apply(pd.Series)


print(len(deduped_address))
combined = pd.merge(deduped_address, pre_coded_addresses, how='outer', left_on =['match_address','zip'], right_on=['address','zip'],indicator=True, validate='many_to_one')
#combined.head()
#combined['_merge'].value_counts()
#combine2 = combined[combined['_merge']=='both']
combined.to_csv('C:/Users/jmeakin/Desktop/HDA Project/Addresses/staging.csv')