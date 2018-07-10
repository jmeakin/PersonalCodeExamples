import pysftp
import os
from os import listdir
from os.path import isfile, join
import datetime
from datetime import date, timedelta
import shutil
from IPython.display import display, HTML

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
import glob
import os
import time

import pandas as pd
import numpy as np

import sys
sys.path.append("//tx1cifs/tx1data/Austin Share/CLI ScaleUp Grant/Python Functions")
from Merge_Like_Stata import MergeLikeStata as mstata


# Download All Files From Shelby SFTP (Preserve Local Save Time/Date)
cinfo = {'host':'ftp.swiftwavenetwork.com', 'username':'air-study', 'password':'BPALisNUSu6NBpDEZTzc', 'port':9922}
with pysftp.Connection(**cinfo) as sftp:
    sftp.get_d('/home/air-study/CLIStudy/', '//tx1cifs/tx1data/Austin Share/CLI ScaleUp Grant/Year 2/Data Collection - Teachers/Raw Survey Data', preserve_mtime=True)


# List all files in above path
list_of_files = glob.glob("//tx1cifs/tx1data/Austin Share/CLI ScaleUp Grant/Year 2/Data Collection - Teachers/Raw Survey Data/*")

# create empty dataframe
surveys = pd.DataFrame()
for f in list_of_files:
    # Only grab a file that is from today (i.e. if file time is greater than today's time minus 12 hours ago)
    if os.path.getmtime(f)>time.time()-60*60*24:
        #print(f)
        dataframe = pd.read_csv(f)
        dataframe = dataframe[['Email', 'Started', 'Completed']]
        #dataframe.head()
        surveys = pd.concat([surveys, dataframe], ignore_index=True)
surveys['Email'] = surveys['Email'].map(lambda x: str(x).strip())

#Check Spaces
'''
surveys['Email2'] = surveys['Email'].map(lambda x: str(x).strip())
surveys['compare'] = surveys.apply(lambda x: 1 if x['Email2']!=x['Email'] else 0, axis=1)
Browse = surveys[surveys.compare == 1]
display(HTML(Browse.to_html()))
'''

Tracker = pd.read_excel('//Dc1fs/dc1ehd/share/CLI i3 ScaleUp/3 Data Collection/Teachers/3. Spring 2018 Teacher Survey/Teacher lists/Year 2 Master Teacher Tracker 27 Apr 2018.xlsx')
Tracker = Tracker[['Email', 'Grade','District' , 'Treatment_1718','TeacherStatus_Y1_Y2']]
Tracker = Tracker.dropna(axis=0, subset=['Email'],how='all')
Tracker['Email'] = Tracker['Email'].map(lambda x: str(x).strip())

Survey_Track = mstata.stata_merge(Tracker,surveys,['Email'],'1:1')

'''
Browse = Survey_Track[Survey_Track._merge == "1 - Using Only"]
display(HTML(Browse.to_html()))
'''

Survey_Track['Survey Complete'] =  Survey_Track.apply(lambda x: 1 if pd.notnull(x['Completed']) else 0, axis = 1)

# First Create Archive
from datetime import date, timedelta
import shutil

archivepath = '//Dc1fs/dc1ehd/share/CLI i3 ScaleUp/3 Data Collection/Teachers/3. Spring 2018 Teacher Survey/Teacher lists/Archive/'
currentpath = '//Dc1fs/dc1ehd/share/CLI i3 ScaleUp/3 Data Collection/Teachers/3. Spring 2018 Teacher Survey/Teacher lists/'
archdate = str(date.today().strftime('%m%d%y'))
shutil.copyfile(currentpath+'Year 2 Master Teacher Tracker 27 Apr 2018.xlsx', archivepath+'Year 2 Master Teacher Tracker - '+archdate+'.xlsx')

# Update Tracker
  #1 Keep Complete Rows
Update = Survey_Track.loc[Survey_Track['Survey Complete'] == 1]
  #2 Keep Only Email And Complete Column
Update = Update[['Email','Survey Complete']]
  #3 Load File Sitting On Share
ToUpdate = pd.read_excel('//Dc1fs/dc1ehd/share/CLI i3 ScaleUp/3 Data Collection/Teachers/3. Spring 2018 Teacher Survey/Teacher lists/Year 2 Master Teacher Tracker 27 Apr 2018.xlsx')
  #4 Drop Current Complete Variable
ToUpdate = ToUpdate.drop(['Survey Complete'], axis=1)
  #5 Trim Email 
ToUpdate['Email'] = ToUpdate['Email'].map(lambda x: str(x).strip())
  # Create An Export Frame Of Current 0/1 "Survey Complete Status" Merged In With Original Data - Need To Merge In Case Sorted On Share
Export = mstata.stata_merge(ToUpdate,Update,['Email'],'1:1')
Export = Export.drop(['_merge'], axis=1)
# Make New Value 0/1
Export['Survey Complete'] = Export['Survey Complete'].fillna(value=0)
Export['Survey Complete'] = Export['Survey Complete'].astype(int)
display(HTML(Export.to_html()))


# Use openpyxl To Load Sheet & Export Only The [Survey Complete] Column Into The 16th Place, Preserving Rest Of Sheet
from openpyxl import load_workbook 
file = '//Dc1fs/dc1ehd/share/CLI i3 ScaleUp/3 Data Collection/Teachers/3. Spring 2018 Teacher Survey/Teacher lists/Year 2 Master Teacher Tracker 27 Apr 2018.xlsx'
book = load_workbook(file)
writer = pd.ExcelWriter(file, engine='openpyxl') 
writer.book = book
writer.sheets = dict((ws.title, ws) for ws in book.worksheets)
Export['Survey Complete'].to_excel(writer, sheet_name="Teachers", startcol=16, index=False)
writer.save()
# https://stackoverflow.com/questions/43425944/pandas-fromat-column-multiple-sheets?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
# http://xlsxwriter.readthedocs.io/format.html
# https://stackoverflow.com/questions/20219254/how-to-write-to-an-existing-excel-file-without-overwriting-data-using-pandas

# Tables
NumTable1 = Survey_Track.groupby(['District','Treatment_1718']).sum()['Survey Complete'].to_frame(name = 'Completion Rates').reset_index().pivot_table(index=['Treatment_1718'], columns=['District'], margins=True, aggfunc=np.sum)
#Table1 = Table1.round(decimals=2)
#display(HTML(NumTable1.to_html()))
DenomTable1 = Survey_Track.groupby(['District','Treatment_1718']).count()['Survey Complete'].to_frame(name = 'Completion Rates').reset_index().pivot_table(index=['Treatment_1718'], columns=['District'], margins=True, aggfunc=np.sum)
#Table1 = Table1.round(decimals=2)
#display(HTML(DenomTable1.to_html()))

Table1 = NumTable1/DenomTable1
#display(HTML(Table1.to_html()))
Table1Html = Table1.style.format("{:.1%}").set_table_attributes('table border="1"').set_properties(**{'text-align': 'left'}).render()
#display(HTML(Table1Html))



NumTable2 = Survey_Track.groupby(['District','TeacherStatus_Y1_Y2']).sum()['Survey Complete'].to_frame(name = 'Completion Rates').reset_index().pivot_table(index=['TeacherStatus_Y1_Y2'], columns=['District'], margins=True, aggfunc=np.sum)
#Table1 = Table1.round(decimals=2)
#display(HTML(NumTable2.to_html()))
DenomTable2 = Survey_Track.groupby(['District','TeacherStatus_Y1_Y2']).count()['Survey Complete'].to_frame(name = 'Completion Rates').reset_index().pivot_table(index=['TeacherStatus_Y1_Y2'], columns=['District'], margins=True, aggfunc=np.sum)
#Table1 = Table1.round(decimals=2)
#display(HTML(DenomTable2.to_html()))

Table2 = NumTable2/DenomTable2
#display(HTML(Table2.to_html()))
Table2Html = Table2.style.format("{:.1%}").set_table_attributes('table border="1"').set_properties(**{'text-align': 'left'}).render()
#display(HTML(Table2Html))


text = """\
<html>
  <head></head>
  <body>
    <p>Hi!<br><br>
       Below are tables describing the survey completion rates <br><br>
       The Year 2 Master Teacher Tracker located Here: "H:\share\CLI i3 ScaleUp\3 Data Collection\Teachers\3. Spring 2018 Teacher Survey\Teacher lists" has been updated to reflect the current completion status. <br><br>
       In case of an error, an archived file with the current data has been created and is here: "H:\share\CLI i3 ScaleUp\3 Data Collection\Teachers\3. Spring 2018 Teacher Survey\Teacher lists\Archive" <br><br>
       Cheers!, <br><br>
       John 
    </p>
  </body>
</html>
"""

htmltables = text
htmltables += Table1Html
htmltables += "<br><br>"
htmltables += Table2Html
htmltables += "<br><br>"

# Email
list_of_files = glob.glob('//tx1cifs/tx1data/Austin Share/CLI ScaleUp Grant/Year 2/Data Collection - Students/GRADE Tracking/Summaries/*')
latest_file = max(list_of_files, key=os.path.getctime)
latest_filename=latest_file.replace("//tx1cifs/tx1data/Austin Share/CLI ScaleUp Grant/Year 2/Data Collection - Students/GRADE Tracking/Summaries\\","")

def SendNotificaiton ():

    msg = MIMEMultipart("alternative", None, [MIMEText(htmltables,'html')])
    msg['From'] = "cliscaleup@gmail.com"
    #msg['To'] = "jmeakin@air.org"
    msg['To'] = "ntucker-bradway@air.org,dmsmith@air.org, jmeakin@air.org, kdrummond@air.org"
    msg['Subject'] = "Survey Completion Rates"

    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.starttls()
    server.login("cliscaleup@gmail.com", "CLIstudy4ever!")
    text = msg.as_string()
    server.sendmail("cliscaleup@gmail.com", msg["To"].split(","), text)
    server.quit()

SendNotificaiton()







