import pysftp as sftp


### Upload All Files To Shelby SFTP (Preserve Local Save Time/Date)
##cinfo = {'host':'ftp.swiftwavenetwork.com', 'username':'air-scsk12', 'password':'rDYCMnHKccxHfwv6XAd3', 'port':9922}
##with pysftp.Connection(**cinfo) as sftp:
##    sftp.put_d('/home/air-scsk12/', '//dc1fs/DC1EHD/share/Parent Messaging Impact Study/Restricted Data/2. Fidelity Data/4. District Data In Messenger/Daily Shelby Adjustment Folder/2. Current Data (Updates Daily)', preserve_mtime=True)
### One File Needs To Be Fixed Because It's Missing Extension



def sftpUpload():
    s = sftp.Connection(host="ftp.swiftwavenetwork.com", username="air-scsk12", password="rDYCMnHKccxHfwv6XAd3", port=9922)
    remotepath="/home/air-scsk12/Shelby_Attendance_Upload.csv"
    localpath="//dc1fs/DC1EHD/share/Parent Messaging Impact Study/Restricted Data/2. Fidelity Data/4. District Data In Messenger/Daily Shelby Adjustment Folder/3. For Upload To Shelby SFTP/Shelby_Attendance_Upload.csv"
    s.put(localpath,remotepath, preserve_mtime=True)
    s.close()

sftpUpload()


