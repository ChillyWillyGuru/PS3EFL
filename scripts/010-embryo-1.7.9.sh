#!/bin/sh
# embryo.sh by Spork Schivago

EMBRYO="embryo-1.7.9"

## Download the source
wget --continue http://download.enlightenment.org/releases/${EMBRYO}.tar.bz2

## Remove the directory and uncompress our files
rm -Rf ${EMBRYO} && tar -xvjf ${EMBRYO}.tar.bz2 && cd ${EMBRYO} && mkdir build-ppu

## Patch the source code if a patch file exists.
if [ -f ../../patches/${EMBRYO}.patch ]; then
	echo "Patching ${EMBRYO}"
	cat ../../patches/${EMBRYO}.patch | patch -p1
fi

## Run Autogen
echo -ne "Running autogen on ${EMBRYO}, please wait : "
NOCONFIGURE=1 ./autogen.sh >../build-logs/autogen_${EMBRYO}.log  2>&1 || \
	(echo "Error!" && \
	(tail ../build-logs/autogen_${EMBRYO}.log || true) && \
	echo -ne "\n\nSee autogen_${EMBRYO}.log in the build-logs directory for details.\n" && \
	exit 1)
	echo "Done"

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
${MAKE:-make} all && ${MAKE:-make} install
