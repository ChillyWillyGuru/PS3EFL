#!/bin/sh
# chipmunk.sh by Spork Schivago

CHIP_MAJOR="Chipmunk-6.x"
CHIPMUNK="Chipmunk-6.2.1"

## Download the source
wget --continue http://chipmunk-physics.net/release/${CHIP_MAJOR}/${CHIPMUNK}.tgz

## Remove the directory and uncompress our files
rm -Rf ${CHIPMUNK} && tar -zxvf ${CHIPMUNK}.tgz && cd ${CHIPMUNK} && mkdir build-ppu

## Patch the source code if a patch file exists.
if [ -f ../../patches/${CHIPMUNK}.patch ]; then
	echo "Patching ${CHIPMUNK}"
	cat ../../patches/${CHIPMUNK}.patch | patch -p1
fi

## Enter the build directory
cd build-ppu

## We must run cmake for Chipmunk before we configure
cmake -DCMAKE_INSTALL_PREFIX=${PS3DEV}/portlibs/ppu/ \
-DBUILD_SHARED=OFF -DBUILD_DEMOS=OFF \
-DCMAKE_AR=${PS3DEV}/ppu/bin/powerpc64-ps3-elf-ar \
-DCMAKE_TOOLCHAIN_FILE=$(pwd)/../Toolchain-ps3.cmake ..

## Make and install
${MAKE:-make} all && ${MAKE:-make} install
