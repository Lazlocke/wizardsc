del error.txt
del /q ins\*
copy orig\* ins

echo trans\0005DFBC.txt >> error.txt
tools\atlas ins\wizard.exe trans\0005DFBC.txt >> error.txt