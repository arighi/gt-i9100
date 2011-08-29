#!/bin/bash

cd linux-gt-i9100/arch/arm/boot
ls -lh zImage

adb push zImage /data/local/tmp || exit 1
adb shell "dd if=/data/local/tmp/zImage of=/dev/block/mmcblk0p5" || exit 1
adb shell "sync; reboot"
