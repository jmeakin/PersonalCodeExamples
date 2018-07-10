import pysftp
import os
from os import listdir
from os.path import isfile, join
import datetime
from datetime import date, timedelta
import shutil

# Define File Path
path = '//dc1fs/DC1EHD/share/Parent Messaging Impact Study/Restricted Data/2. Fidelity Data/4. District Data In Messenger/Daily Shelby Adjustment Folder/2. Current Data (Updates Daily)/'

# Create Archive Folder For All Files
yesterday = date.today() - timedelta(1)
stringyesterday = str(yesterday.strftime('%m%d%y'))
os.mkdir(path+stringyesterday)

# Move Files To Archive
onlyfiles1 = [f for f in listdir(path) if isfile(join(path, f))]
for files in onlyfiles1:
    shutil.move(path+files, path+stringyesterday)

# Download All Files From Shelby SFTP (Preserve Local Save Time/Date)
cinfo = {'host':'ftp.swiftwavenetwork.com', 'username':'air-scsk12', 'password':'rDYCMnHKccxHfwv6XAd3', 'port':9922}
with pysftp.Connection(**cinfo) as sftp:
    sftp.get_d('/home/air-scsk12/', '//dc1fs/DC1EHD/share/Parent Messaging Impact Study/Restricted Data/2. Fidelity Data/4. District Data In Messenger/Daily Shelby Adjustment Folder/2. Current Data (Updates Daily)', preserve_mtime=True)
# One File Needs To Be Fixed Because It's Missing Extension
os.rename(path+'SMAMPStuAttendance7PM',path+'SMAMPStuAttendance7PM.csv')

# Define Function To Modify File Names Based On Their Save Time
def modification_date(filename):
    t = os.path.getmtime(filename)
    return datetime.datetime.fromtimestamp(t)

# Rename Files Based On Their Save Date (Needed Becasue "dirlist" Command In Stata Not Compatible With UNC Paths)
onlyfiles = [f for f in listdir(path) if isfile(join(path, f))]
for file in onlyfiles:
    print(file)
    d = modification_date(path+file)
    base=os.path.splitext(file)[0]
    print(base)
    stringdate = str(d)
    reamevalue = stringdate[:10]
    os.rename(path+file,path+base+"_"+reamevalue+".csv")

