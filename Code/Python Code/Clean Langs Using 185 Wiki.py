import pandas as pd
import time
import numpy as np
from google.cloud import storage
import os

# Grab list of languages from web
LNK='https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes'
table = pd.read_html(LNK,flavor = 'bs4')
# Extract correct html table from all downloaded
langtable=table[1]

# Grab the correct language and abbreviation columns
langtable = langtable.rename(columns={2: 'Lang', 6: 'LangAbr'})
langtable = langtable[['Lang','LangAbr']]

# make all text upper case & drop index row
langtable['Lang'] = langtable['Lang'].map(lambda x: str(x).upper())
langtable['LangAbr'] = langtable['LangAbr'].map(lambda x: str(x).upper())
langtable = langtable[1:]

# there are still a few parenthetical references, in additon some languages have severl spellings based on commas. Fix this
langtable = langtable['Lang'].str.split('(', expand=True).join(langtable)
langtable = langtable[[0,'LangAbr']]
langtable = langtable.rename(columns={0: 'Lang'})
langtable = langtable['Lang'].str.split(',', expand=True).join(langtable)
langtable.drop(columns=['Lang'], inplace=True)

# Bit Of Extra Cleaning:
langtable = langtable[langtable['LangAbr'].isin(['CHU'])==False]
langtable = langtable[langtable['LangAbr'].isin(['NOB'])==False]
langtable = langtable[langtable['LangAbr'].isin(['NNO'])==False]
langtable = langtable[langtable['LangAbr'].isin(['ENG'])==False]

for i in langtable.columns:
    langtable[i] = langtable[i].map(lambda x: str(x).replace("LANGUAGES",""))
    langtable[i] = langtable[i].map(lambda x: str(x).strip())

#from IPython.display import display, HTML
#display(HTML(langtable.to_html()))


# set environment in Jupyter notebook
os.environ["GOOGLE_APPLICATION_CREDENTIALS"]="C:/Users/jmeakin/Desktop/HDA Project/Service Account Key/My First Project-2d07c9a62734.json"
print(os.environ['GOOGLE_APPLICATION_CREDENTIALS']) 
from google.cloud import bigquery
bigquery_client = bigquery.Client()
# https://cloud.google.com/bigquery/docs/reference/standard-sql/migrating-from-legacy-sql
sql = """
    SELECT npi, languages 
    FROM `healthy-keyword-159121.AirHealth2018.provider`, UNNEST(languages) as languages
    WHERE languages is not null and languages != "English"      
    GROUP BY npi, languages
"""
basefile = bigquery_client.query(sql).to_dataframe()

# Import raw data (will be pulled striagit from Big Query, but for now use Christina's download)
#fromdb = "H:/share/Data Analytics/Chris Working Files/NPI_language_2018.csv"
#basefile = pd.read_csv(fromdb)
basefile['languages'] = basefile['languages'].map(lambda x: str(x).upper())
# Drop useless/uninformative language data 
basefile = basefile.dropna(subset=['languages'])
basefile = basefile[basefile['languages'].isin(['NAN'])==False]
basefile = basefile[basefile['languages'].isin([''])==False]
basefile = basefile[basefile['languages'].isin(['NOT ASSIGNED'])==False]

#basefile['npi']=basefile['npi'].apply(lambda x: x if pd.isnull(x) else str(int(x)))
basefile = basefile[basefile['npi'] != basefile['languages']]
#basefile['npi']=basefile['npi'].apply(lambda x: x if pd.isnull(x) else int(x))


# Split Data into larget and smaller than 25 rows (saves memry and time with reshape)
basefile['languages1']=basefile['languages'].apply(lambda x: x if len(x)>=25 else np.nan)
basefile['languages2']=basefile['languages'].apply(lambda x: x if len(x)<25 else np.nan)

# make dataframe with long strings
databasefile1=basefile.dropna(subset=['languages1'], how='any')
databasefile1=databasefile1[['npi','languages']]
print(len(databasefile1))

# make dataframe with short strings
databasefile2=basefile.dropna(subset=['languages2'], how='any')
databasefile2=databasefile2[['npi','languages']]
#databasefile2=databasefile2[0:1000]
print(len(databasefile2))


df_list = [databasefile1, databasefile2]

finaldata = pd.DataFrame()
for databasefile in df_list:
    # create new empty dataframe to fill
    start = time.time()
    iteration = 0
    new_dataframe = pd.DataFrame()
    for i in range(0,len(databasefile)):
        # take i'th row of data frame
        row = databasefile.iloc[i]
        # conver to list (but just to have as string)
        rowlist = row.values.tolist()
        # the second entry in that row is the language value (first entry is npi)
        langs = [rowlist[0]]
        # foreach language in master list, check to see if that language appears in the row
        for i in langtable.columns:
            for j in range(0,len(langtable)):
                if str(langtable[i].iloc[j]) in str(rowlist):
                    langs.append(langtable[0].iloc[j])            
        langs = set(langs)
        langs = list(langs)
        langs = sorted(langs, key=str, reverse=False) 
        newframe = pd.DataFrame(langs).T
        new_dataframe = pd.concat([new_dataframe, newframe], ignore_index=True)
        print("total time taken this loop: ", time.time() - start)
        iteration = iteration+1
        print(iteration)


    new_dataframe = new_dataframe.add_prefix('lang_')
    new_dataframe = new_dataframe.rename(columns={'lang_0': 'npi'})

    # Create additional ID for reshae (dropped later)
    filter_col = [col for col in new_dataframe if str(col).startswith('lang_')]

    new_dataframe['id2'] = new_dataframe[filter_col].astype(str).values.sum(axis=1)
    new_dataframe = new_dataframe.drop_duplicates(keep='first')
    long_lang = pd.wide_to_long(new_dataframe, ["lang_"], i=['npi','id2'], j="Language")

    long_lang.reset_index(inplace=True)
    long_lang = long_lang[['npi','lang_']]
    long_lang = long_lang.dropna(subset=['lang_'])
    long_lang = long_lang.rename(columns={'lang_': 'Language'})
    finaldata = pd.concat([finaldata, long_lang], ignore_index=True)

print(len(finaldata))

finaldata.to_csv('C:/Users/jmeakin/Desktop/HDA Project/HDA_LANGS_NEW.csv')


cleanlangs = pd.read_csv('C:/Users/jmeakin/Desktop/HDA Project/HDA_LANGS_NEW.csv')
#cleanlist = cleanlangs['Language'].value_counts()
cleanlist = cleanlangs.groupby([ 'Language']).size().to_frame().reset_index()
cleanlist.to_csv('C:/Users/jmeakin/Desktop/HDA Project/CleanLang_New.csv')


# Note: conda install pandas-gbq --channel conda-forge
#project = bigquery_client.project
#TABLE.to_gbq('Entity.NPI_languages_2018', project, if_exists='replace')