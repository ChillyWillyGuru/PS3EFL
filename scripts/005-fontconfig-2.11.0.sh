#!/bin/sh
# fontconfig.sh by Spork Schivago

FONTCONFIG="fontconfig-2.11.0"

## Download the source
wget --continue http://freedesktop.org/software/fontconfig/release/${FONTCONFIG}.tar.bz2

## Remove the directory and uncompress our files
rm -Rf ${FONTCONFIG} && tar -jxvf ${FONTCONFIG}.tar.bz2 && cd ${FONTCONFIG} && mkdir build-ppu

## Patch the source code if a patch file exists.
if [ -f ../../patches/${FONTCONFIG}.patch ]; then
	echo "Patching ${FONTCONFIG}"
	cat ../../patches/${FONTCONFIG}.patch | patch -p1
fi

## Enter the build directory
cd build-ppu

## Configure the build
CFLAGS="-g -O3 -Wall" \
CPPFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include" \
CXXFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include" \
LDFLAGS="-L${PSL1GHT}/ppu/lib -L${PS3DEV}/portlibs/ppu/lib" \
LIBS="-lescape -lnet -lsysmodule -liberty -lpng" \
PKG_CONFIG_LIBDIR="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
PKG_CONFIG_PATH="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
PKG_CONFIG="pkg-config --static" \
../configure --prefix="${PS3DEV}/portlibs/ppu" --host=powerpc64-ps3-elf \
--disable-docs --with-arch=powerpc64

## Make and install
${MAKE:-make} all && ${MAKE:-make} install
