#!/bin/sh
# escape.sh by Spork Schivago

ESCAPE="escape"

## Remove the svn escape dir and redownload it
rm -Rf ${ESCAPE} && svn checkout https://github.com/kakaroto/e17/trunk/${ESCAPE}

## Create the build directory
mkdir ${ESCAPE}/build-ppu && cd ${ESCAPE}

## Patch the source code if a patch file exists.
if [ -f ../../patches/${ESCAPE}.patch ]; then
	echo "Patching ${ESCAPE}"
	cat ../../patches/${ESCAPE}.patch | patch -p1
fi

## Run Autogen
echo -ne "Running autogen on ${ESCAPE}, please wait : "
NOCONFIGURE=1 ./autogen.sh >../build-logs/autogen_${ESCAPE}.log 2>&1 || \
	(echo "Error!" && \
	(tail ../build-logs/autogen_${ESCAPE}.log || true) && \
	echo -ne "\n\nSee autogen_${ESCAPE}.log for details.\n" && \
	exit 1)

## Enter the build directory
cd build-ppu

## Configure the build.
	AR="powerpc64-ps3-elf-ar" \
	CC="powerpc64-ps3-elf-gcc"\
	RANLIB="powerpc64-ps3-elf-ranlib" \
	CFLAGS="-g -O3 -Wall -mminimal-toc" \
	CPPFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include" \
	CXXFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include" \
	LDFLAGS="-L${PSL1GHT}/ppu/lib -L${PS3DEV}/portlibs/ppu/lib" \
	PKG_CONFIG_LIBDIR="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
	PKG_CONFIG_PATH="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
	PKG_CONFIG="pkg-config --static" \
	../configure --prefix="${PS3DEV}/portlibs/ppu" --host=powerpc64-ps3-elf 

## Make and install
${MAKE-make} clean all && ${MAKE-make} install
