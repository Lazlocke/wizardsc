del chip.vfs
del /q chip\mod_vfs
copy chip\orig_vfs chip\mod_vfs
tools\image2iph.exe chip\mod_png png chip\mod_vfs
tools\vfs_build.exe chip\mod_vfs chip.vfs
