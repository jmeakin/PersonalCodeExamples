import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
import glob
import os


list_of_files = glob.glob("H:/share/Parent Messaging Impact Study/Restricted Data/7. SSO Uploads/Detailed Outreach Summary/By District/DCPS*")
latest_file1 = max(list_of_files, key=os.path.getctime)
latest_filename1=latest_file1.replace("H:/share/Parent Messaging Impact Study/Restricted Data/7. SSO Uploads/Detailed Outreach Summary/By District\\","")

list_of_files = glob.glob("H:/share/Parent Messaging Impact Study/Restricted Data/7. SSO Uploads/Detailed Outreach Summary/By District/Portland*")
latest_file2 = max(list_of_files, key=os.path.getctime)
latest_filename2=latest_file2.replace("H:/share/Parent Messaging Impact Study/Restricted Data/7. SSO Uploads/Detailed Outreach Summary/By District\\","")

list_of_files = glob.glob("H:/share/Parent Messaging Impact Study/Restricted Data/7. SSO Uploads/Detailed Outreach Summary/By District/Shelby*")
latest_file3 = max(list_of_files, key=os.path.getctime)
latest_filename3=latest_file3.replace("H:/share/Parent Messaging Impact Study/Restricted Data/7. SSO Uploads/Detailed Outreach Summary/By District\\","")

list_of_files = glob.glob("H:/share/Parent Messaging Impact Study/Restricted Data/7. SSO Uploads/Detailed Outreach Summary/By District/Springfield*")
latest_file4 = max(list_of_files, key=os.path.getctime)
latest_filename4=latest_file4.replace("H:/share/Parent Messaging Impact Study/Restricted Data/7. SSO Uploads/Detailed Outreach Summary/By District\\","")


list_of_files = glob.glob("H:/share/Parent Messaging Impact Study/Restricted Data/7. SSO Uploads/Detailed Outreach Summary/Outreach Summary Detail*")
latest_file5 = max(list_of_files, key=os.path.getctime)
latest_filename5=latest_file5.replace("H:/share/Parent Messaging Impact Study/Restricted Data/7. SSO Uploads/Detailed Outreach Summary\\","")



def SendNotificaiton ():
	
	fromaddr = "ampstudy.notifications@gmail.com"
	msg = MIMEMultipart()
	 
	msg['From'] = fromaddr
	#msg['To'] = "jmeakin@air.org"
	msg['To'] = "akurki@air.org,sbrown@air.org, jmeakin@air.org, mscardaville@air.org, dseidel@air.org, mweingarten@air.org, mcrowley@air.org"
	msg['Subject'] = "SSO Outreach Summary"
	 
	body = "Hi,\n\nPlease see attached for overall SSO-Outreach completion rates (Outreach Summary Detail...) as well as color coded individual district sheets. \n \nCheers, \nJohn"

	
	msg.attach(MIMEText(body, 'plain'))
	filename5 = latest_filename5
	attachment5 = open(latest_file5, "rb")
	part = MIMEBase('application', 'octet-stream')
	part.set_payload((attachment5).read())
	encoders.encode_base64(part)
	part.add_header('Content-Disposition', "attachment; filename= %s" % filename5)
	msg.attach(part)

	msg.attach(MIMEText(body, 'plain'))
	filename1 = latest_filename1
	attachment1 = open(latest_file1, "rb")
	part = MIMEBase('application', 'octet-stream')
	part.set_payload((attachment1).read())
	encoders.encode_base64(part)
	part.add_header('Content-Disposition', "attachment; filename= %s" % filename1)
	msg.attach(part)

	msg.attach(MIMEText(body, 'plain'))
	filename2 = latest_filename2
	attachment2 = open(latest_file2, "rb")
	part = MIMEBase('application', 'octet-stream')
	part.set_payload((attachment2).read())
	encoders.encode_base64(part)
	part.add_header('Content-Disposition', "attachment; filename= %s" % filename2)
	msg.attach(part)

	msg.attach(MIMEText(body, 'plain'))
	filename3 = latest_filename3
	attachment3 = open(latest_file3, "rb")
	part = MIMEBase('application', 'octet-stream')
	part.set_payload((attachment3).read())
	encoders.encode_base64(part)
	part.add_header('Content-Disposition', "attachment; filename= %s" % filename3)
	msg.attach(part)


	msg.attach(MIMEText(body, 'plain'))
	filename4 = latest_filename4
	attachment4 = open(latest_file4, "rb")
	part = MIMEBase('application', 'octet-stream')
	part.set_payload((attachment4).read())
	encoders.encode_base64(part)
	part.add_header('Content-Disposition', "attachment; filename= %s" % filename4)
	msg.attach(part)

	 
	server = smtplib.SMTP('smtp.gmail.com', 587)
	server.starttls()
	server.login(fromaddr, "AMP1234567")
	text = msg.as_string()
	server.sendmail(fromaddr, msg["To"].split(","), text)
	server.quit()

SendNotificaiton()
