@pushd %~dp0

REM - Run Stata Programs To Download Necessary Data
set statapath=NULL
if "%username%"=="jmeakin" set statapath=C:\Program Files (x86)\Stata15\StataMP-64.exe
if "%username%"=="sbrown" set statapath="" 
if "%username%"=="mweingarten" set statapath=\\DC1VSTATA001\Stata14\StataMP-64.exe
if "%statapath%"=="NULL" set /p statapath= 1.Right Click Your Stata Desktop Shortcut 2. Select Prpoerties (Should Open To The Shortcut Tab) 3.Copy The Target Here Then Hit Enter:

"%statapath%" /e do "\\dc1fs\DC1EHD\share\Parent Messaging Impact Study\Restricted Data\Programs\Scheduled Jobs (Do Not Rename)\Clean Daily District Messenger Uploads.do"
"%statapath%" /e do "\\dc1fs\DC1EHD\share\Parent Messaging Impact Study\Restricted Data\Programs\Scheduled Jobs (Do Not Rename)\Identify Issues In Daily Messenger Uploads From Districts.do"

REM - Pull Latest SSO Log
set mm=%date:~4,2%
set dd=%date:~7,2%
set yyyy=%date:~10,4%
if "%mm%" == "01" set mm=Jan
if "%mm%" == "02" set mm=Feb
if "%mm%" == "03" set mm=Mar
if "%mm%" == "04" set mm=Apr
if "%mm%" == "05" set mm=May
if "%mm%" == "06" set mm=Jun
if "%mm%" == "07" set mm=Jul
if "%mm%" == "08" set mm=Aug
if "%mm%" == "09" set mm=Sep
if "%mm%" == "10" set mm=Oct
if "%mm%" == "11" set mm=Nov
if "%mm%" == "12" set mm=Dec
set mydate=%dd% %mm% %yyyy%
wget https://amp.schoolmessenger.com/api/reports/messagingInfo?token=iRhMxJRbFVGjdHpavLKQm_522UeJ68 -O "\\dc1fs\DC1EHD\share\Parent Messaging Impact Study\Restricted Data\2. Fidelity Data\8. SSO Logs\SSOLog_%mydate%.csv"




set statapath=NULL
if "%username%"=="jmeakin" set statapath=C:\Program Files (x86)\Stata15\StataMP-64.exe
if "%username%"=="sbrown" set statapath="" 
if "%username%"=="mweingarten" set statapath=\\DC1VSTATA001\Stata14\StataMP-64.exe
if "%statapath%"=="NULL" set /p statapath= 1.Right Click Your Stata Desktop Shortcut 2. Select Prpoerties (Should Open To The Shortcut Tab) 3.Copy The Target Here Then Hit Enter:
"%statapath%" /e do "\\dc1fs\DC1EHD\share\Parent Messaging Impact Study\Restricted Data\Programs\Scheduled Jobs (Do Not Rename)\Detailed SSO Summary.do"
"%statapath%" /e do "\\dc1fs\DC1EHD\share\Parent Messaging Impact Study\Restricted Data\Programs\Scheduled Jobs (Do Not Rename)\Log 1 Response Rates.do"
"%statapath%" /e do "\\dc1fs\DC1EHD\share\Parent Messaging Impact Study\Restricted Data\Programs\Scheduled Jobs (Do Not Rename)\Log 2 Response Rates.do"
"%statapath%" /e do "\\dc1fs\DC1EHD\share\Parent Messaging Impact Study\Restricted Data\Programs\Scheduled Jobs (Do Not Rename)\Log 3 Response Rates.do"
"%statapath%" /e do "\\dc1fs\DC1EHD\share\Parent Messaging Impact Study\Restricted Data\Programs\Scheduled Jobs (Do Not Rename)\Message Sent Daily Summary.do"




md "C:\Users\%username%\Desktop\Temp_AMP_PYTHON_MORNING"
copy "\\dc1fs\DC1EHD\share\Parent Messaging Impact Study\Restricted Data\Programs\Scheduled Jobs (Do Not Rename)\Email Message Sent Logs.py" "C:\Users\%username%\Desktop\Temp_AMP_PYTHON_MORNING"
REM copy "\\dc1fs\DC1EHD\share\Parent Messaging Impact Study\Restricted Data\Programs\Scheduled Jobs (Do Not Rename)\Email Log Summary.py" "C:\Users\%username%\Desktop\Temp_AMP_PYTHON_MORNING"
REM copy "\\dc1fs\DC1EHD\share\Parent Messaging Impact Study\Restricted Data\Programs\Scheduled Jobs (Do Not Rename)\Email 5 SSO Attachments.py" "C:\Users\%username%\Desktop\Temp_AMP_PYTHON_MORNING"

set pypath=NULL
if "%username%"=="jmeakin" set pypath=C:\Users\jmeakin\AppData\Local\Programs\Python\Python35-32
if "%username%"=="sbrown" set pypath="" 
if "%username%"=="mweingarten" set pypath=C:\Users\mweingarten\AppData\Local\Programs\Python\Python36-32
if "%pypath%"=="NULL" set /p pypath=Where is Python Installed (e.g. mine is  "C:\Users\jmeakin\AppData\Local\Programs\Python\Python35-32")? Copy Here Then Hit Enter: 

REM "%pypath%\python.exe"  "C:\Users\%username%\Desktop\Temp_AMP_PYTHON_MORNING\Email 5 SSO Attachments.py"
REM "%pypath%\python.exe"  "C:\Users\%username%\Desktop\Temp_AMP_PYTHON_MORNING\Email Log Summary.py"
"%pypath%\python.exe"  "C:\Users\%username%\Desktop\Temp_AMP_PYTHON_MORNING\Email Message Sent Logs.py"

REM del "C:\Users\%username%\Desktop\Temp_AMP_PYTHON_MORNING\Email 5 SSO Attachments.py"
REM del "C:\Users\%username%\Desktop\Temp_AMP_PYTHON_MORNING\Email Log Summary.py"
del "C:\Users\%username%\Desktop\Temp_AMP_PYTHON_MORNING\Email Message Sent Logs.py"
rd "C:\Users\%username%\Desktop\Temp_AMP_PYTHON_MORNING"


@popd

