#!/bin/bash

TOPDIR=`pwd`
OUTPUT=$TOPDIR/kernel-gt-i9100-arighi.tar
CONFIG=$TOPDIR/linux-gt-i9100/.config
SRC_INITRAMFS=$TOPDIR/initramfs-gt-i9100
TMP_INITRAMFS=/tmp/initramfs
MAKE_OPTS=

# get custom kernel
if [ ! -d $TOPDIR/linux-gt-i9100 ]; then
	git clone git://github.com/arighi/linux-gt-i9100.git || exit 1
fi

# get custom initrmfs
if [ ! -e $TOPDIR/initramfs-gt-i9100 ]; then
	git clone git://github.com/arighi/initramfs-gt-i9100.git || exit 1
fi

# configure the kernel
cd $TOPDIR/linux-gt-i9100
if [ ! -e $CONFIG ]; then
	make ARCH=arm CROSS_COMPILE=arm-none-eabi- c1_rev02_defconfig
fi

# make modules
make ARCH=arm CROSS_COMPILE=arm-none-eabi- modules_prepare
make ARCH=arm CROSS_COMPILE=arm-none-eabi- modules

# generate initramfs
if [ -e $SRC_INITRAMFS ]; then
	rm -rf $TMP_INITRAMFS $TMP_INITRAMFS.cpio

	rsync -avHS --exclude=.gitignore --exclude=.git \
			$SRC_INITRAMFS/ $TMP_INITRAMFS/
	find -name '*.ko' -exec cp -av {} $TMP_INITRAMFS/lib/modules/ \;

	cd $TMP_INITRAMFS
	find | fakeroot cpio -H newc -o > $TMP_INITRAMFS.cpio 2>/dev/null
	ls -lh $TMP_INITRAMFS.cpio
	cd -

	MAKE_OPTS="$MAKE_OPTS CONFIG_INITRAMFS_SOURCE=$TMP_INITRAMFS.cpio"
fi

# make kernel
make ARCH=arm CROSS_COMPILE=arm-none-eabi- $MAKE_OPTS

# cleanup temporary stuff
rm -rf $TMP_INITRAMFS $TMP_INITRAMFS.cpio

# prepare kernel to be flashed by Odin
rm -f $OUTPUT
cd arch/arm/boot
tar cf $OUTPUT zImage && ls -lh $OUTPUT
