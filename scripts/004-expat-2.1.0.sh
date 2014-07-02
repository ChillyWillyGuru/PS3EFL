#!/bin/sh
# expat.sh by Spork Schivago

VER="2.1.0"
EXPAT="expat-${VER}"

## Download the source
wget --continue http://sourceforge.net/projects/expat/files/expat/${VER}/${EXPAT}.tar.gz/download -O ${EXPAT}.tar.gz

## Remove the directory and uncompress our files
rm -Rf ${EXPAT} && tar -zxvf ${EXPAT}.tar.gz && cd ${EXPAT} && mkdir build-ppu

## Patch the source code if a patch file exists.
if [ -f ../../patches/${EXPAT}.patch ]; then
	echo "Patching ${EXPAT}"
	cat ../../patches/${EXPAT}.patch | patch -p1
fi

## Enter the build directory
cd build-ppu

## Configure the build
CFLAGS="-g -O3 -Wall -mminimal-toc" \
CPPFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include" \
CXXFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include" \
LDFLAGS="-L${PSL1GHT}/ppu/lib -L${PS3DEV}/portlibs/ppu/lib" \
PKG_CONFIG_LIBDIR="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
PKG_CONFIG_PATH="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
PKG_CONFIG="pkg-config --static" \
../configure --prefix="${PS3DEV}/portlibs/ppu" --host=powerpc64-ps3-elf

## Make and install
${MAKE-make} all && ${MAKE-make} install
