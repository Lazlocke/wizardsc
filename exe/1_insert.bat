del error.txt
del /q ins\*
copy orig\* ins



tools\fasm code\wizard-patch.asm wizard.exe
tools\fasm code\ags-patch.asm Ags.dll
del /q replacetext.dll
copy tools\replacetext.dll replacetext.dll

echo trans\0005DFBC.txt >> error.txt
tools\atlas wizard.exe trans\0005DFBC.txt >> error.txt