#!/bin/sh
# eina.sh by Spork Schivago

EINA="eina-1.7.9"

wget --continue http://download.enlightenment.org/releases/${EINA}.tar.bz2

## Remove the directory and uncompress our files
rm -Rf ${EINA} && tar -xvjf ${EINA}.tar.bz2 && cd ${EINA} && mkdir build-ppu

## Patch the source code if a patch file exists.
if [ -f ../../patches/${EINA}.patch ]; then
	echo "Patching ${EINA}"
	cat ../../patches/${EINA}.patch | patch -p1
fi

## Run Autogen
echo -ne "Running autogen on ${EINA}, please wait : "
NOCONFIGURE=1 ./autogen.sh >& ../build-logs/autogen_${EINA}.log  || \
 	(echo "Error!" && \
 	(tail ../build-logs/autogen_${EINA}.log || true) && \
 	echo -ne "\n\nSee autogen_${EINA}.log in the build-logs directory for details.\n" && \
 	exit 1)
 	echo "Done"

## Enter the build directory
# This prevents it from compiling for some reason...
# cd build-ppu

## Configure the build
CPPFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include -I${PS3DEV}/portlibs/ppu/include/escape-0" \
CFLAGS="-g -O3 -Wall -mcpu=cell -mminimal-toc"  \
CXXFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include" \
LDFLAGS="-L${PSL1GHT}/ppu/lib -L${PS3DEV}/portlibs/ppu/lib" \
PKG_CONFIG_PATH="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
PKG_CONFIG="pkg-config --static" \
./configure --prefix="${PS3DEV}/portlibs/ppu" --host=powerpc64-ps3-elf

${MAKE-make} all && ${MAKE-make} install
