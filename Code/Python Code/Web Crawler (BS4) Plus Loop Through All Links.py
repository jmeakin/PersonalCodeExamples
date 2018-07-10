
from bs4 import BeautifulSoup
import urllib.request
from urllib.request import urlopen
import re
import pandas as pd

html_page = urllib.request.urlopen("https://ncteachingconditions.org/results")
soup = BeautifulSoup(html_page, "lxml")
links = []
 
for link in soup.findAll('a', attrs={'href': re.compile("")}):
    links.append(link.get('href'))

clean_link = []
for link in links:
    if link.startswith("/results/report/"):
        clean_link.append(link)

#print(clean_link)
        

'''
for link in links :
    print(link.split("/")[-2:])
    save="_".join(link.split("/")[-2:])
    print(save)
'''


for link in clean_link :
    try:
        print(link)
        LNK="https://ncteachingconditions.org"+link
        save1="_".join(link.split("/")[-2:])
        save="//dc1fs/dc1ehd/share/NBPTS SEED Evaluation/Goal 0 study - part 2 (Concentration study)/School Climate Surveys/North Carolina/"+save1+".csv"
        table = pd.read_html(LNK)
        df=table[0]
        df.to_csv(save, sep=',')
    except:
        print("failed"+link)

