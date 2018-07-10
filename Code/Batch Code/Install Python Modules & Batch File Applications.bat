@ echo off
@pushd %~dp0
echo "Install Python Modules - Pycrypto, Paramiko, & Pysftp 2.8"
set /p pippath=What is the parent folder where Python is installed on your computer (e.g. mine is  "C:\Users\jmeakin\AppData\Local\Programs\Python\Python35-32")? Copy Here Then Hit Enter: 
cd "%pippath%/Scripts"
pip install crypto
pip install paramiko
copy "\\tx1cifs\tx1data\Austin Share\Parent Messaging Impact Study\Executables & Scripts\pysftp.py" "%pippath%/Lib"


echo "Install Executables"
set /p windowspath=Where would you like your executables? (If you don't have a preference please use "C:\Windows\System32") Copy Here Then Hit Enter: 

cd "%windowspath%"
copy "\\tx1cifs\tx1data\Austin Share\Parent Messaging Impact Study\Executables & Scripts\wget.exe" "%windowspath%"
copy "\\tx1cifs\tx1data\Austin Share\Parent Messaging Impact Study\Executables & Scripts\7z.exe" "%windowspath%" 
copy "\\tx1cifs\tx1data\Austin Share\Parent Messaging Impact Study\Executables & Scripts\7-zip.dll" "%windowspath%"
copy "\\tx1cifs\tx1data\Austin Share\Parent Messaging Impact Study\Executables & Scripts\7-zip32.dll" "%windowspath%"
copy "\\tx1cifs\tx1data\Austin Share\Parent Messaging Impact Study\Executables & Scripts\7z.dll" "%windowspath%"

@popd
pause

