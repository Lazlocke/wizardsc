del error.txt
del /q ins\*
copy orig\* ins

echo trans\0005DFBC.txt >> error.txt
tools\atlas ins\wizard.exe trans\0005DFBC.txt >> error.txt

tools\fasm code\wizard-patch.asm wizard.exe
tools\fasm code\ags-patch.asm Ags.dll
del /q replacetext.dll
copy tools\replacetext.dll replacetext.dll