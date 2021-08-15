#!/bin/sh
echo "break when mounting root in boot process"
echo "------------------------------"
grep -q "break=mountroot" /boot/cmdline.txt || echo "$(cat /boot/cmdline.txt) break=mountroot" > /boot/cmdline.txt
