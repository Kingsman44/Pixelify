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
    log "- Bootloop detected"
    #echo "$temp" >> /sdcard/Pixelify/logs.txt
    #logcat -d >> /sdcard/Pixelify/boot_logs.txt
    rip="$(logcat -d)"
    rm -rf $MODDIR/boot_logs.txt
    echo "$(getprop)" >>MODDIR/boot_logs.txt
    echo "$rip" >>$MODDIR/boot_logs.txt
    cp -Tf $MODDIR/boot_logs.txt /sdcard/Pixelify/boot_logs.txt
    #echo "$rip" >> /sdcard/Pixelify/boot_logs.txt
    sleep .5
    reboot
}

check() {
    TEXT1="$1"
    TEXT2="$2"
    result=false
    for i in $TEXT1; do
        for j in $TEXT2; do
            [ "$i" == "$j" ] && result=true
        done
    done
    $result
}

#HuskyDG@github's bootloop preventer

# Wait for zygote starts
sleep 5

MAIN_ZYGOTE_NICENAME=zygote
CPU_ABI=$(getprop ro.product.cpu.api)
[ "$CPU_ABI" = "arm64-v8a" -o "$CPU_ABI" = "x86_64" ] && MAIN_ZYGOTE_NICENAME=zygote64

ZYGOTE_PID1=$(pidof "$MAIN_ZYGOTE_NICENAME")
sleep 15
ZYGOTE_PID2=$(pidof "$MAIN_ZYGOTE_NICENAME")
sleep 15
ZYGOTE_PID3=$(pidof "$MAIN_ZYGOTE_NICENAME")

PIDS=0

if check "$ZYGOTE_PID1" "$ZYGOTE_PID2" && check "$ZYGOTE_PID2" "$ZYGOTE_PID3"; then
    if [ -z "$ZYGOTE_PID1" ] && [ "$(getprop init.svc.bootanim)" != "stopped" ]; then
        bootlooped
    else
        PIDS=1
    fi
fi

if [ $PIDS -eq 0 ]; then
    sleep 15
    ZYGOTE_PID4=$(pidof "$MAIN_ZYGOTE_NICENAME")
    if check "$ZYGOTE_PID3" "$ZYGOTE_PID4"; then
        # Set device config
        set_device_config
    elif [ "$(getprop init.svc.bootanim)" != "stopped" ]; then
        bootlooped
    fi
fi