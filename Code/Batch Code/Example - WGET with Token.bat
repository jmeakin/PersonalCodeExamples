@pushd %~dp0
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


@popd