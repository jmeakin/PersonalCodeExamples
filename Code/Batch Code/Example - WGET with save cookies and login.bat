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

wget -q --no-check-certificate -N --keep-session-cookies --save-cookies cookies.txt --post-data "username=air-jmeakin&password=Jmeak91686&customerUrl=airstudy&redirectUri=https://asp.schoolmessenger.com/airstudy/index.php?" https://authem.schoolmessenger.com/customer/airstudy/login
wget -q --no-check-certificate -N --load-cookies cookies.txt --keep-session-cookies --save-cookies cookies.txt https://asp.schoolmessenger.com/airstudy/blockedphone.php?csv -O "\\dc1fs\DC1EHD\share\Parent Messaging Impact Study\Restricted Data\2. Fidelity Data\5. Block Numbers\Current List Of Blocked Numbers\BlockedNumbers_%mydate%.csv"
wget -q --no-check-certificate -N --load-cookies cookies.txt --keep-session-cookies --save-cookies cookies.txt https://asp.schoolmessenger.com/airstudy/index.php?logout=1

@popd
