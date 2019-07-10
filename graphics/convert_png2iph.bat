for /r %%v in (chip\mod_png\*.png) do tools\PNGtoIPH.exe "%%v"
move chip\mod_png\*.iph chip\mod_iph

for /r %%v in (etc\mod_png\*.png) do tools\PNGtoIPH.exe "%%v"
move etc\mod_png\*.iph etc\mod_iph


tools\ALDExplorer2