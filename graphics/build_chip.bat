del chip.vfs
del /q chip\mod_vfs
copy chip\orig_vfs chip\mod_vfs
tools\image2iph.exe chip\mod_png png chip\mod_vfs
tools\arc_conv.exe --pack vfs101 chip\mod_vfs chip.vfs
