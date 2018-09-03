#!/bin/sh
# used in https://cattlepi.com/2018/08/28/hacking-bootcode.html
echo "setting up the GPU to use the minimum ammount of memory"
echo "------------------------------"
CONFIG_TXT=/boot/config.txt

# we check to see if the configuration we are targeting is already there
grep -q ^gpu_mem=16$ $CONFIG_TXT
if [ $? -ne 0 ]; then
    # we remove all the lines that have gpu_mem in them
    grep -v gpu_mem $CONFIG_TXT > $CONFIG_TXT".new"
    echo "gpu_mem=16" >> $CONFIG_TXT".new"
    # atomically swap the old config with the new one
    mv $CONFIG_TXT".new" $CONFIG_TXT
    # reboot - as this is picked up on boot
    echo "configuration updated. rebooting"
    umount /boot
    sleep 5
    echo b >/proc/sysrq-trigger
fi
echo "done"
