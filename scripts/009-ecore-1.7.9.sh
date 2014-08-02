#!/bin/sh
# ecore.sh by Spork Schivago

ECORE="ecore-1.7.9"

## Download the source
wget --continue http://download.enlightenment.org/releases/${ECORE}.tar.bz2

## Remove the directory and uncompress our files
rm -Rf ${ECORE} && tar -xvjf ${ECORE}.tar.bz2 && cd ${ECORE} && mkdir build-ppu

## Patch the source code if a patch file exists.
if [ -f ../../patches/${ECORE}.patch ]; then
	echo "Patching ${ECORE}"
	cat ../../patches/${ECORE}.patch | patch -p1
fi

## Run Autogen
echo -ne "Running autogen on ${ECORE}, please wait : "
NOCONFIGURE=1 ./autogen.sh >../build-logs/autogen_${ECORE}.log  2>&1 || \
	(echo "Error!" && \
	(tail ../build-logs/autogen_${ECORE}.log || true) && \
	echo -ne "\n\nSee autogen_${ECORE}.log in the build-logs directory for details.\n" && \
	exit 1)
	echo "Done"

## Enter the build directory
cd build-ppu

## Configure the build
CPPFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include -I${PS3DEV}/portlibs/ppu/include/escape-0" \
CFLAGS="-g -O3 -Wall -mminimal-toc" \
CXXFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include" \
LDFLAGS="-L${PSL1GHT}/ppu/lib -L${PS3DEV}/portlibs/ppu/lib" \
PKG_CONFIG_LIBDIR="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
PKG_CONFIG_PATH="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
PKG_CONFIG="pkg-config --static" \
../configure --prefix="${PS3DEV}/portlibs/ppu" --host=powerpc64-ps3-elf \
	--disable-ecore-x --disable-ecore-ipc \
	--enable-ecore-sdl --enable-ecore-psl1ght --enable-ecore-evas-psl1ght \
	--enable-ecore-evas-gl-psl1ght --enable-ecore-con --enable-cares \
	--enable-option-checking

## Make and install
${MAKE:-make} all && ${MAKE:-make} install
