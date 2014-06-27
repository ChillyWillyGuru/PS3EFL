#!/bin/sh
# evas.sh by Spork Schivago

EVAS="evas-1.7.9"

## Download the source.
wget --continue http://download.enlightenment.org/releases/${EVAS}.tar.bz2

## Remove the directory and uncompress our files
rm -Rf ${EVAS} && tar -xvjf ${EVAS}.tar.bz2 && cd ${EVAS} && mkdir build-ppu

## Patch the source code if a patch file exists.
if [ -f ../../patches/${EVAS}.patch ]; then
	echo "Patching ${EVAS}"
	cat ../../patches/${EVAS}.patch | patch -p1
fi

## Run Autogen
echo -ne "Running autogen on ${EVAS}, please wait : "
NOCONFIGURE=1 ./autogen.sh >& ../build-logs/autogen_${EVAS}.log  || \
	(echo "Error!" && \
	(tail ../build-logs/autogen_${EVAS}.log || true) && \
	echo -ne "\n\nSee autogen_${EVAS}.log in the build-logs directory for details.\n" && \
	exit 1)
	echo "Done"

## Enter the build directory
cd build-ppu

## Configure the build
CFLAGS="-g -O3 -Wall -mcpu=cell -mminimal-toc" \
CPPFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include -D_POSIX_THREADS" \
CXXFLAGS="-I${PSL1GHT}/ppu/include -I${PS3DEV}/portlibs/ppu/include" \
LDFLAGS="-L${PSL1GHT}/ppu/lib -L${PS3DEV}/portlibs/ppu/lib" \
LIBS="-ljpeg -lz -lm" \
PKG_CONFIG_LIBDIR="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
PKG_CONFIG_PATH="${PS3DEV}/portlibs/ppu/lib/pkgconfig" \
PKG_CONFIG="pkg-config --static" \
../configure --prefix="${PS3DEV}/portlibs/ppu" --host=powerpc64-ps3-elf \
	--disable-async-events --disable-async-preload \
	--enable-software-sdl=static --enable-software-16-sdl=static \
	--disable-shared --enable-buffer=static --enable-image-loader-eet=static \
	--enable-font-loader-eet --enable-image-loader-gif=static \
	--enable-image-loader-jpeg=static  --enable-image-loader-png=static \
	 --enable-image-loader-tiff=static --enable-image-loader-bmp=static \
	--enable-image-loader-xpm=static  --enable-image-loader-psd=static \
	--enable-image-loader-pmaps=static  --enable-image-loader-ico=static \
	--enable-image-loader-wbmp=static --enable-image-loader-tga=static \
	--enable-static-software-generic --enable-static-software-16 \
	--enable-psl1ght=static --enable-fontconfig

## Make and install
${MAKE:-make} all && ${MAKE:-make} install
