import pysftp as sftp
import time

def sftpDownload(remotefile, localfile, locpath):
    s = sftp.Connection(host="ftp.swiftwavenetwork.com", username="air-study", password="BPALisNUSu6NBpDEZTzc", port=9922)

    timestr = time.strftime("%Y%m%d")

    remotepath="/home/air-study/reports/"+remotefile+".csv"
    localpath=locpath+"/"+localfile+timestr+".csv"
    s.get(remotepath,localpath)
    s.close()


locp="//dc1fs/DC1EHD/share/Parent Messaging Impact Study/Restricted Data/1. Random Assignment/4. Opt Outs/Non-Auto Text Opt Outs/2. Response Downloads"
sftpDownload(remotefile="sms_inbound_log", localfile="sms_log", locpath=locp)


locp="//dc1fs/DC1EHD/share/Parent Messaging Impact Study/Restricted Data/1. Random Assignment/4. Opt Outs/Auto Opt Out"
sftpDownload(remotefile="optouts", localfile="optouts", locpath=locp)


locp="//dc1fs/DC1EHD/share/Parent Messaging Impact Study/Restricted Data/3. QC Schedules & Lists"
sftpDownload(remotefile="alllists", localfile="alllists", locpath=locp)
sftpDownload(remotefile="allmessages", localfile="allmessages", locpath=locp)
sftpDownload(remotefile="scheduled_broadcasts", localfile="scheduled_broadcasts", locpath=locp)


locp="//dc1fs/DC1EHD/share/Parent Messaging Impact Study/Restricted Data/2. Fidelity Data/6. SMS Results Log"
sftpDownload(remotefile="sms_results_log", localfile="sms_results_log", locpath=locp)


locp="//dc1fs/DC1EHD/share/Parent Messaging Impact Study/Restricted Data/2. Fidelity Data/7. Click Tracking"
sftpDownload(remotefile="trackingdata", localfile="trackingdata", locpath=locp)



import pysftp
cinfo = {'host':'ftp.swiftwavenetwork.com', 'username':'air-study', 'password':'BPALisNUSu6NBpDEZTzc', 'port':9922}
with pysftp.Connection(**cinfo) as sftp:
    sftp.get_d('/home/air-study/logs/', '//dc1fs/DC1EHD/share/Parent Messaging Impact Study/Task 7 Data Collection/Log Input Data/Log Data', preserve_mtime=True)

