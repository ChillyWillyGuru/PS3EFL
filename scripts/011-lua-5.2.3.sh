#!/bin/sh
# lua.sh by Spork Schivago

LUA=lua-5.2.3

## Download the source
wget --continue http://www.lua.org/ftp/${LUA}.tar.gz

## Remove the directory and uncompress our files
rm -Rf ${LUA} && tar -zxvf ${LUA}.tar.gz && cd ${LUA}

## Patch the source code if a patch file exists.
if [ -f ../../patches/${LUA}.patch ]; then
	echo "Patching ${LUA}"
	cat ../../patches/${LUA}.patch | patch -p1
fi

## Compile lua.
${MAKE:-make} ps3 INSTALL_TOP="${PS3DEV}/portlibs/ppu"
${MAKE:-make} INSTALL_TOP="$PS3DEV/portlibs/ppu" install
cp etc/lua.pc $PS3DEV/portlibs/ppu/lib/pkgconfig
sed -i -e "s#\${PS3DEV}#$PS3DEV/portlibs/ppu#" ${PS3DEV}/portlibs/ppu/lib/pkgconfig/lua.pc
