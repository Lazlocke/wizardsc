del extra.vfs
del /q extra\mod_vfs
copy extra\orig_vfs extra\mod_vfs
tools\image2iph.exe extra\mod_bmp bmp extra\mod_vfs
tools\vfs_build.exe extra\mod_vfs extra.vfs
