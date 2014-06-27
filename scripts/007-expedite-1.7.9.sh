#!/bin/sh
# expedite.sh by Spork Schivago
shopt -s expand_aliases

EXPEDITE="expedite-1.7.9"
EXPEDITE_DATADIR="/dev_hdd0/game/EXPEDITE_/USRDIR"

## Download the source.
wget --continue http://download.enlightenment.org/releases/${EXPEDITE}.tar.bz2

## Remove the directory and uncompress our files
rm -Rf ${EXPEDITE} && tar -xvjf ${EXPEDITE}.tar.bz2 && cd ${EXPEDITE} && mkdir build-ppu

## Patch the source code if a patch file exists.
if [ -f ../../patches/${EXPEDITE}.patch ]; then
	echo "Patching ${EXPEDITE}"
	cat ../../patches/${EXPEDITE}.patch | patch -p1
fi

## Enter the build directory
cd build-ppu

## Configure the build
CFLAGS="-g -O3 -Wall -mcpu=cell -mminimal-toc" \
CPPFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include" \
CXXFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include" \
LDFLAGS="-L${PSL1GHT}/ppu/lib -L${PS3DEV}/portlibs/ppu/lib" \
LIBS="-ltiff -lm -ljpeg -lz" \
PKG_CONFIG_LIBDIR="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
PKG_CONFIG_PATH="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
PKG_CONFIG="pkg-config --static" \
../configure --prefix="${PS3DEV}/portlibs/ppu" --host=powerpc64-ps3-elf --datadir=${EXPEDITE_DATADIR}

## Make and install
${MAKE:-make} all && ${MAKE:-make} pkg
