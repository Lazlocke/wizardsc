del etc.vfs
del /q etc\mod_vfs
copy etc\orig_vfs etc\mod_vfs
tools\image2iph.exe etc\mod_png png etc\mod_vfs
tools\arc_conv.exe --pack vfs101 etc\mod_vfs etc.vfs
