#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in late_start service mode

. $MODDIR/vars.sh
. $MODDIR/utils.sh

sqlite=$MODDIR/addon/sqlite3
chmod 0755 $sqlite
chmod 0755 $MODDIR/system/bin/pixelify

log() {
    date=$(date +%y/%m/%d)
    tim=$(date +%H:%M:%S)
    temp="$temp
$date $tim: $@"
}

TARGET_LOGGING=1
temp=""

pm_enable() {
    pm enable $1 >/dev/null 2>&1
    log "Enabling $1"
}

bootlooped() {
    echo -n >>$MODDIR/disable
    logcat -d >> $MODDIR/boot_logs.txt
    rm -rf /cache/.system_booting /data/unencrypted/.system_booting /metadata/.system_booting /persist/.system_booting /mnt/vendor/persist/.system_booting
    sleep .5
    reboot
}

#HuskyDG@github's bootloop preventer

# Wait for zygote starts
sleep 5
ZYGOTE_PID1=$(getprop init.svc_debug_pid.zygote)

sleep 15
ZYGOTE_PID2=$(getprop init.svc_debug_pid.zygote)

sleep 15
ZYGOTE_PID3=$(getprop init.svc_debug_pid.zygote)

# Check for BootLoop
log "Checking..."

if [ -z "$ZYGOTE_PID1" ]; then
   bootlooped
fi

if [ "$ZYGOTE_PID1" != "$ZYGOTE_PID2" -o "$ZYGOTE_PID2" != "$ZYGOTE_PID3" ]; then
   sleep 15
   ZYGOTE_PID4=$(getprop init.svc_debug_pid.zygote)
   if [ "$ZYGOTE_PID3" != "$ZYGOTE_PID4" ]; then
      bootlooped
   fi
fi