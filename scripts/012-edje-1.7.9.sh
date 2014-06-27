#!/bin/sh
# edje.sh by Spork Schivago

EDJE="edje-1.7.9"

## Download the source
wget --continue http://download.enlightenment.org/releases/${EDJE}.tar.bz2

## Remove the directory and uncompress our files
rm -Rf ${EDJE} && tar -xvjf ${EDJE}.tar.bz2 && cd ${EDJE} && mkdir build-ppu

## Patch the source code if a patch file exists.
if [ -f ../../patches/${EDJE}.patch ]; then
	echo "Patching ${EDJE}"
	cat ../../patches/${EDJE}.patch | patch -p1
fi

## Run Autogen
echo -ne "Running autogen on ${EDJE}, please wait : "
NOCONFIGURE=1 ./autogen.sh >& ../build-logs/autogen_${EDJE}.log  || \
	(echo "Error!" && \
	(tail ../build-logs/autogen_${EDJE}.log || true) && \
	echo -ne "\n\nSee autogen_${EDJE}.log in the build-logs directory for details.\n" && \
	exit 1)
	echo "Done"

## Enter the build directory
cd build-ppu

## Configure the build
CFLAGS="-g -O3 -Wall -mcpu=cell -mminimal-toc" \
CPPFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include" \
CXXFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include" \
LDFLAGS="-L${PSL1GHT}/ppu/lib -L${PS3DEV}/portlibs/ppu/lib" \
PKG_CONFIG_LIBDIR="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
PKG_CONFIG_PATH="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
PKG_CONFIG="pkg-config --static" \
../configure --prefix="${PS3DEV}/portlibs/ppu" --host=powerpc64-ps3-elf \
	--disable-edje-player --disable-edje-inspector \
	--disable-edje-external-inspector --disable-edje-cc \
	--disable-edje-decc --disable-edje-recc

## Make and install
${MAKE:-make} all && ${MAKE:-make} install
