#!/bin/sh
# eskiss.sh by Spork Schivago

ESKISS="eskiss"
ESKISS_DATADIR="/dev_hdd0/game/ESKISS_00/USRDIR/"
EDJE_CC="`type -p edje_cc`"

## Download ESKISS via git.
## This is a bit unsafe because I cannot find the revision and 
## in the future, the code might change to much and break
## the compilation of ESKISS

rm -Rf ${ESKISS} && git clone git://git.enlightenment.org/games/${ESKISS}.git

## Remove the directory and uncompress our files
cd ${ESKISS} && mkdir build-ppu

## Run Autogen
echo -ne "Running autogen on ${ESKISS}, please wait : "
NOCONFIGURE=1 ./autogen.sh >../build-logs/autogen_${ESKISS}.log  2>&1 || \
	(echo "Error!" && \
	(tail ../build-logs/autogen_${ESKISS}.log || true) && \
	echo -ne "\n\nSee autogen_${ESKISS}.log in the build-logs directory for details.\n" && \
	exit 1)
	echo "Done"

## Patch the source code if a patch file exists.
if [ -f ../../patches/${ESKISS}.patch ]; then
	echo "Patching ${ESKISS}"
	cat ../../patches/${ESKISS}.patch | patch -p1
fi

if [ -f ./build_pkg.sh ]; then
	echo "Making build_pkg.sh executable...";
	chmod +x ./build_pkg.sh
fi
## Enter the build directory
cd build-ppu

## Configure the build
CFLAGS="-g -O3 -Wall -mminimal-toc" \
CPPFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include" \
LDFLAGS="-L${PSL1GHT}/ppu/lib -L${PS3DEV}/portlibs/ppu/lib" \
LIBS="-ltiff" \
PKG_CONFIG_LIBDIR="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
PKG_CONFIG_PATH="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
PKG_CONFIG="pkg-config --static" \
../configure --prefix="${PS3DEV}/portlibs/ppu" --host=powerpc64-ps3-elf \
--datadir=${ESKISS_DATADIR} --with-edje-cc=${EDJE_CC} \
--libdir=${PS3DEV}/portlibs/ppu/lib \
--includedir=${PS3DEV}/portlibs/ppu/include

## Make and install
${MAKE:-make} all && ../build_pkg.sh
