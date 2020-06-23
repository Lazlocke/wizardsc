del etc.vfs
del /q etc\mod_vfs
copy etc\orig_vfs etc\mod_vfs
tools\image2iph.exe etc\mod_png png etc\mod_vfs
tools\vfs_build.exe etc\mod_vfs etc.vfs
