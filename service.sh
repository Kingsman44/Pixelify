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
chmod 0755 $sqlite3

TARGET_LOGGING=1
temp=""

pm_enable() {
    pm enable $1 >/dev/null 2>&1
    log "Enabling $1"
}

log() {
    date=$(date +%y/%m/%d)
    tim=$(date +%H:%M:%S)
    temp="$temp
$date $tim: $@"
}

set_prop() {
    setprop "$1" "$2"
    log "Setting prop $1 to $2"
}

bootlooped() {
    echo -n >>$MODDIR/disable
    log "- Bootloop detected"
    #echo "$temp" >> /sdcard/Pixelify/logs.txt
    #logcat -d >> /sdcard/Pixelify/boot_logs.txt
    rip="$(logcat -d)"
    rm -rf $MODDIR/boot_logs.txt
    echo "$rip" >>$MODDIR/boot_logs.txt
    cp -Tf $MODDIR/boot_logs.txt /sdcard/Pixelify/boot_logs.txt
    #echo "$rip" >> /sdcard/Pixelify/boot_logs.txt
    sleep .5
    reboot
}

check() {
    VALUEA="$1"
    VALUEB="$2"
    RESULT=false
    for i in $VALUEA; do
        for j in $VALUEB; do
            [ "$i" == "$j" ] && RESULT=true
        done
    done
    $RESULT
}

set_device_config() {
    while read p; do
        if [ ! -z "$(echo $p)" ]; then
            if [ "$(echo $p | head -c 1)" != "#" ]; then
                name="$(echo $p | cut -d= -f1)"
                namespace="$(echo $name | cut -d/ -f1)"
                key="$(echo $name | cut -d/ -f2)"
                value="$(echo $p | cut -d= -f2)"
                device_config put $namespace $key $value
            fi
        fi
    done <$MODDIR/deviceconfig.txt
}

mkdir -p /sdcard/Pixelify

log "Service Started"

# Call Screening
cp -Tf $MODDIR/com.google.android.dialer /data/data/com.google.android.dialer/files/phenotype/com.google.android.dialer

# Wellbeing
pm_enable com.google.android.apps.wellbeing/com.google.android.apps.wellbeing.walkingdetection.ui.WalkingDetectionActivity

# Temporary Workaround for Precise Location
device_config put privacy location_accuracy_enabled true

if [ $(grep CallScreen $MODDIR/var.prop | cut -d'=' -f2) -eq 1 ]; then
    mkdir -p /data/data/com.google.android.dialer/files/phenotype
    cp -Tf $MODDIR/com.google.android.dialer /data/data/com.google.android.dialer/files/phenotype/com.google.android.dialer
    chmod 500 /data/data/com.google.android.dialer/files/phenotype
    am force-stop com.google.android.dialer
fi

if [ $(grep Live $MODDIR/var.prop | cut -d'=' -f2) -eq 1 ]; then
    pm enable -n com.google.pixel.livewallpaper/com.google.pixel.livewallpaper.pokemon.wallpapers.PokemonWallpaper -a android.intent.action.MAIN
fi

pm enable -n com.google.android.settings.intelligence/com.google.android.settings.intelligence.modules.battery.impl.usage.BootBroadcastReceiver -a android.intent.action.MAIN
pm enable -n com.google.android.settings.intelligence/com.google.android.settings.intelligence.modules.battery.impl.usage.DataInjectorReceiver -a android.intent.action.MAIN
pm enable -n com.google.android.settings.intelligence/com.google.android.settings.intelligence.modules.batterywidget.impl.BatteryWidgetBootBroadcastReceiver -a android.intent.action.MAIN
pm enable -n com.google.android.settings.intelligence/com.google.android.settings.intelligence.modules.batterywidget.impl.BatteryWidgetUpdateReceiver -a android.intent.action.MAIN
pm enable -n com.google.android.settings.intelligence/com.google.android.settings.intelligence.modules.battery.impl.usage.PeriodicJobReceiver -a android.intent.action.MAIN
sleep .5
pm enable -n com.google.android.settings.intelligence/com.google.android.settings.intelligence.modules.batterywidget.impl.BatteryAppWidgetProvider -a android.intent.action.MAIN

am force-stop com.google.android.settings.intelligence

#HuskyDG@github's bootloop preventer
MAIN_ZYGOTE_NICENAME=zygote
MAIN_SYSUI_NICENAME=com.android.systemui

CPU_ABI=$(getprop ro.product.cpu.api)
[ "$CPU_ABI" = "arm64-v8a" -o "$CPU_ABI" = "x86_64" ] && MAIN_ZYGOTE_NICENAME=zygote64

# Wait for zygote to start
sleep 5
ZYGOTE_PID1=$(pidof "$MAIN_ZYGOTE_NICENAME")
echo "1z is $ZYGOTE_PID1"
device_config put privacy location_accuracy_enabled true

# Wait for SystemUI to start
sleep 10
SYSUI_PID1=$(pidof "$MAIN_SYSUI_NICENAME")
echo "1s is $SYSUI_PID1"
device_config put privacy location_accuracy_enabled true

sleep 15
ZYGOTE_PID2=$(pidof "$MAIN_ZYGOTE_NICENAME")
SYSUI_PID2=$(pidof "$MAIN_SYSUI_NICENAME")
echo "2z is $ZYGOTE_PID2"
echo "2s is $SYSUI_PID2"
device_config put privacy location_accuracy_enabled true
cp -Tf $MODDIR/com.google.android.dialer /data/data/com.google.android.dialer/files/phenotype/com.google.android.dialer

if check "$ZYGOTE_PID1" "$ZYGOTE_PID2"; then
    echo "No zygote error on step 1, ok!"
else
    echo "Error on zygote step 1 but continue just to make sure..."
fi

if check "$SYSUI_PID1" "$SYSUI_PID2"; then
    echo "No SystemUI error on step 1, ok!"
else
    echo "Error on SystemUI step 1 but continue just to make sure..."
fi

sleep 30
ZYGOTE_PID3=$(pidof "$MAIN_ZYGOTE_NICENAME")
SYSUI_PID3=$(pidof "$MAIN_SYSUI_NICENAME")
echo "3z is $ZYGOTE_PID3"
echo "3s is $SYSUI_PID3"
device_config put privacy location_accuracy_enabled true
cp -Tf $MODDIR/com.google.android.dialer /data/data/com.google.android.dialer/files/phenotype/com.google.android.dialer
am force-stop com.google.android.dialer

if check "$ZYGOTE_PID2" "$ZYGOTE_PID3"; then
    echo "No zygote error on step 2, ok!"
else
    echo "Error on zygote step 2 as well"
    echo "Boot loop detected! Starting rescue script..."
    bootlooped
fi

if check "$SYSUI_PID2" "$SYSUI_PID3"; then
    echo "No SystemUI error on step 2, ok!"
else
    echo "Error on SystemUI step 2 as well"
    echo "Boot loop detected! Starting rescue script..."
    bootlooped
fi

# Set device config
set_device_config

# Temporary Workaround for Precise Location
device_config put privacy location_accuracy_enabled true

sleep 30
device_config put privacy location_accuracy_enabled true

sleep 30
device_config put privacy location_accuracy_enabled true

sleep 30
device_config put privacy location_accuracy_enabled true

sleep 30
device_config put privacy location_accuracy_enabled true

sleep 30
device_config put privacy location_accuracy_enabled true

log "Service Finished"
echo "$temp" >>/sdcard/Pixelify/logs.txt
