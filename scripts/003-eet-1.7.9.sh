#!/bin/sh
# eet.sh by Spork Schivago

EET="eet-1.7.9"

wget --continue http://download.enlightenment.org/releases/${EET}.tar.bz2

## Remove the directory and uncompress our files
rm -Rf ${EET} && tar -xvjf ${EET}.tar.bz2 && cd ${EET} && mkdir build-ppu

## Patch the source code if a patch file exists.
if [ -f ../../patches/${EET}.patch ]; then
	echo "Patching ${EET}"
	cat ../../patches/${EET}.patch | patch -p1
fi

## Run Autogen
echo -ne "Running autogen on ${EET}, please wait : "
NOCONFIGURE=1 ./autogen.sh >../build-logs/autogen_${EET}.log  2>&1 || \
	(echo "Error!" && \
	(tail ../build-logs/autogen_${EET}.log || true) && \
	echo -ne "\n\nSee autogen_${EET}.log in the build-logs directory for details.\n" && \
	exit 1)
	echo "Done"

## Enter the build directory
cd build-ppu

## Configure the build
CPPFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include " \
CFLAGS="-g -O3 -Wall -mminimal-toc" \
CXXFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include" \
LDFLAGS="-L${PSL1GHT}/ppu/lib -L${PS3DEV}/portlibs/ppu/lib" \
PKG_CONFIG_LIBDIR="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
PKG_CONFIG_PATH="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
PKG_CONFIG="pkg-config --static" \
../configure --prefix="${PS3DEV}/portlibs/ppu" --host=powerpc64-ps3-elf

## Make and install
${MAKE-make} all && ${MAKE-make} install
