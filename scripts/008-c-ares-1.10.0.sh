#!/bin/sh
# c-ares.sh by Spork Schivago

CARES="c-ares-1.10.0"

## Download the source
wget --continue http://c-ares.haxx.se/download/${CARES}.tar.gz

## Remove the directory and uncompress our files
rm -Rf ${CARES} && tar -zxvf ${CARES}.tar.gz && cd ${CARES} && mkdir build-ppu

## Patch the source code if a patch file exists.
if [ -f ../../patches/${CARES}.patch ]; then
	echo "Patching ${CARES}"
	cat ../../patches/${CARES}.patch | patch -p1
fi

## Enter the build directory
cd build-ppu

## Configure the build
CFLAGS="-g -O3 -Wall -mcpu=cell -mminimal-toc" \
CPPFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include" \
CXXFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include" \
LDFLAGS="-L${PSL1GHT}/ppu/lib -L${PS3DEV}/portlibs/ppu/lib" \
LIBS="-lnet -lsysmodule" \
PKG_CONFIG_LIBDIR="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
PKG_CONFIG_PATH="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
PKG_CONFIG="pkg-config --static" \
../configure --prefix="${PS3DEV}/portlibs/ppu" --host=powerpc64-ps3-elf

## Make and install
${MAKE:-make} all && ${MAKE:-make} install
