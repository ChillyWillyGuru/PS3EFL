#!/bin/sh
# elementary.sh by Spork Schivago

ELEMENTARY="elementary-1.7.9"
EDJE_CC="`which edje_cc`"
EET="`which eet`"

## Download the source
wget --continue http://download.enlightenment.org/releases/${ELEMENTARY}.tar.bz2

## Remove the directory and uncompress our files
rm -Rf ${ELEMENTARY} && tar -xvjf ${ELEMENTARY}.tar.bz2 && cd ${ELEMENTARY} && mkdir build-ppu

## Patch the source code if a patch file exists.
if [ -f ../../patches/${ELEMENTARY}.patch ]; then
	echo "Patching ${ELEMENTARY}"
	cat ../../patches/${ELEMENTARY}.patch | patch -p1
fi

## Run Autogen
echo -ne "Running autogen on ${ELEMENTARY}, please wait : "
NOCONFIGURE=1 ./autogen.sh >../build-logs/autogen_${ELEMENTARY}.log  2>&1 || \
	(echo "Error!" && \
	(tail ../build-logs/autogen_${ELEMENTARY}.log || true) && \
	echo -ne "\n\nSee autogen_${ELEMENTARY}.log in the build-logs directory for details.\n" && \
	exit 1)
	echo "Done"

## Enter the build directory
cd build-ppu

## Make our build.sh script executable and copy it to the build directory
chmod +x ../build.sh && mv ../build.sh .

## Configure the build
CFLAGS="-g -O3 -Wall -mminimal-toc" \
CPPFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include" \
CXXFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include" \
LDFLAGS="-L${PSL1GHT}/ppu/lib -L${PS3DEV}/portlibs/ppu/lib" \
PKG_CONFIG_LIBDIR="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
PKG_CONFIG_PATH="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
PKG_CONFIG="pkg-config --static" \
../configure --prefix="${PS3DEV}/portlibs/ppu" --host=powerpc64-ps3-elf \
	--disable-quick-launch --disable-edbus --disable-efreet \
	--with-eet-eet=${EET} --with-edje-cc=${EDJE_CC}

## Make and install
${MAKE:-make} all && ${MAKE:-make} install && ./build.sh
