del up.vfs
del /q up\mod_vfs
copy up\orig_vfs up\mod_vfs
tools\image2iph.exe up\mod_png png up\mod_vfs
tools\arc_conv.exe --pack vfs101 up\mod_vfs up.vfs
