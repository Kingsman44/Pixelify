#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}
MODPATH=$MODDIR

. $MODDIR/vars.sh
. $MODDIR/utils.sh

MAINDIR=/data/adb/modules/Pixelify
# This script will be executed in late_start service mode

sqlite=/data/adb/modules/PixelifyUninstaller/addon/sqlite3
chmod 0755 $sqlite

gms=/data/data/com.google.android.gms/databases/phenotype.db
gser=/data/data/com.google.android.gsf/databases/gservices.db

disable="com.google.android.gms/com.google.android.gms.update.phone.PopupDialog"

update="com.google.android.apps.wellbeing/com.google.android.apps.wellbeing.sleepinsights.ui.SleepInsightsActivity
com.google.android.apps.wellbeing/com.google.android.apps.wellbeing.sleepinsights.ui.dailyinsights.SleepInsightsDailyCardsActivity
com.google.android.apps.wellbeing/com.google.android.apps.wellbeing.coughandsnore.consent.ui.CoughAndSnoreConsentActivity"

flaglogfile=$MODDIR/flag_log.txt

set_device_config() {
    while read p; do
        if [ ! -z "$(echo $p)" ]; then
            if [ "$(echo $p | head -c 1)" != "#" ]; then
                name="$(echo $p | cut -d= -f1)"
                namespace="$(echo $name | cut -d/ -f1)"
                key="$(echo $name | cut -d/ -f2)"
                value="$(echo $p | cut -d= -f2)"
                device_config put $namespace $key $value
                # setprop persist.device_config.$namespace.$key $value
            fi
        fi
    done <$MODDIR/deviceconfig.txt
}

update_sql() {
    for folder in "flag_boolVal" "flag_stringVal" "flag_intVal" "flag_floatVal" "flag_bin"; do
        if [ -d $MODPATH/$folder ]; then
            type="$(echo $folder | cut -d_ -f2)"
            names=$(ls $MODPATH/$folder)
            for name in $names; do
                flags=$(ls $MODPATH/$folder/$name)
                for flag in $flags; do
                    value="$(cat $MODPATH/$folder/$name/$flag)"
                    rm -rf $MODPATH/$folder/$name/$flag
                    db_edit "$name" "$type" "$value" "$flag"
                done
                if [ -z "$(ls $MODPATH/$folder/$name)" ]; then
                    rm -rf $MODPATH/$folder/$name
                fi
            done
            if [ -z "$(ls $MODPATH/$folder)" ]; then
                rm -rf $MODPATH/$folder
            fi
        fi
    done
}

log() {
    date=$(date +%y/%m/%d)
    tim=$(date +%H:%M:%S)
    echo "$@"
    temp="$temp
$date $tim: $@"
}

set_prop() {
    setprop "$1" "$2"
    log "Setting prop $1 to $2"
}

bool_patch() {
    file=$2
    if [ -f $file ]; then
        line=$(grep $1 $2 | grep false | cut -c 16- | cut -d' ' -f1)
        for i in $line; do
            val_false='value="false"'
            val_true='value="true"'
            write="${i} $val_true"
            find="${i} $val_false"
            log "Setting bool $(echo $i | cut -d'"' -f2) to True"
            sed -i -e "s/${find}/${write}/g" $file
        done
    fi
}

bool_patch_false() {
    file=$2
    if [ -f $file ]; then
        line=$(grep $1 $2 | grep false | cut -c 14- | cut -d' ' -f1)
        for i in $line; do
            val_false='value="true"'
            val_true='value="false"'
            write="${i} $val_true"
            find="${i} $val_false"
            log "Setting bool $i to False"
            sed -i -e "s/${find}/${write}/g" $file
        done
    fi
}

string_patch() {
    file=$3
    if [ -f $file ]; then
        str1=$(grep $1 $3 | grep string | cut -c 14- | cut -d'>' -f1)
        for i in $str1; do
            str2=$(grep $i $3 | grep string | cut -c 14- | cut -d'<' -f1)
            add="$i>$2"
            if [ ! "$add" == "$str2" ]; then
                log "Setting string $i to $2"
                sed -i -e "s/${str2}/${add}/g" $file
            fi
        done
    fi
}

long_patch() {
    file=$3
    if [ -f $file ]; then
        lon=$(grep $1 $3 | grep long | cut -c 17- | cut -d'"' -f1)
        for i in $lon; do
            str=$(grep $i $3 | grep long | cut -c 17- | cut -d'"' -f1-2)
            str1=$(grep $i $3 | grep long | cut -c 17- | cut -d'"' -f1-3)
            add="$str\"$2"
            if [ ! "$add" == "$str1" ]; then
                log "Setting string $i to $2"
                sed -i -e "s/${str1}/${add}/g" $file
            fi
        done
    fi
}

TARGET_LOGGING=1
temp=""

pm_enable() {
    pm enable $1 >/dev/null 2>&1
    log "Enabling $1"
}

loop_count=0

# Wait for the boot
while true; do
    boot=$(getprop sys.boot_completed)
    if [ "$boot" -eq 1 ] && [ -d /data/data ]; then
        sleep 5
        log " Boot completed"
        break
    fi
    if [ $loop_count -gt 30 ]; then
        log " ! Boot time exceeded"
        break
    fi
    sleep 5
    loop_count=$((loop_count + 1))
done

# Uninstall if Pixelify is not detected.
if [ ! -d /data/adb/modules/Pixelify ]; then
    #Remove XML patches and let app to regenrate without them.
    rm -rf /data/data/com.google.android.dialer/shared_prefs/dialer_phenotype_flags.xml
    rm -rf /data/data/com.google.android.inputmethod.latin/shared_prefs/flag_value.xml
    rm -rf /data/data/com.google.android.inputmethod.latin/shared_prefs/flag_override.xml
    rm -rf /data/data/com.google.android.apps.fitness/shared_prefs/growthkit_phenotype_prefs.xml
    rm -rf /data/data/com.google.android.googlequicksearchbox/shared_prefs/GEL.GSAPrefs.xml
    rm -rf /data/data/com.google.android.apps.turbo/shared_prefs/phenotypeFlags.xml

    #Remove Pixelify version store data
    rm -rf /data/pixelify

    #Remove callscreening patch
    chmod 0755 /data/data/com.google.android.dialer/files/phenotype
    rm -rf /data/data/com.google.android.dialer/files/phenotype/*

    #Remove GMS patches
    $sqlite $gms "DELETE FROM FlagOverrides"
    $sqlite $gser "DELETE FROM overrides"

    # Fixes Nexus Launcher gone
    rm -rf /data/system/package_cache/*

    # Uninstall packages of they are not system app.
    [ -z $(pm list packages -s | grep com.google.android.as) ] && pm uninstall com.google.android.as
    [ -z $(pm list packages -s | grep com.google.pixel.livewallpaper) ] && pm uninstall com.google.pixel.livewallpaper

    # Disable Pickachu Wallpaper if device on Pixel 4 or XL
    [[ "$(getprop ro.product.vendor.model)" != "Pixel 4" || "$(getprop ro.product.vendor.model)" != "Pixel 4 XL" ]] && pm disable -n com.google.pixel.livewallpaper/com.google.pixel.livewallpaper.pokemon.wallpapers.PokemonWallpaper -a android.intent.action.MAIN

    log "- Uninstalled Completed"

    # Remove Unistaller itself
    rm -rf /data/adb/modules/PixelifyUninstaller
else
    mkdir -p /sdcard/Pixelify

    log "Service Started"

    # @anirudhgupta109 github
    # avoid breaking encryption, set shipping level to 32 for devices >=33 to allow for software attestation.
    if [[ "$(getprop ro.product.first_api_level)" -ge 33 ]]; then
        resetprop ro.product.first_api_level 32
    fi

    # Call Screening
    #cp -Tf $MAINDIR/com.google.android.dialer /data/data/com.google.android.dialer/files/phenotype/com.google.android.dialer
    # copy bootlogs to Pixelify folder if bootloop happened.
    [ -f /data/adb/modules/Pixelify/boot_logs.txt ] && rm -rf /sdcard/Pixelify/boot_logs.txt && mv /data/adb/modules/Pixelify/boot_logs.txt /sdcard/Pixelify/boot_logs.txt

    for i in $disable; do
        pm disable $i
    done

    for i in $update; do
        pm enable $i
    done

    gacc="$(ls /data/data/com.google.android.gms/databases | grep portable_geller | cut -d_ -f3)"
    db_edit_bin com.google.android.googlequicksearchbox 5470 $GOOGLEBIN

    # if [ $(grep CallScreen $MAINDIR/var.prop | cut -d'=' -f2) -eq 1 ]; then
    #     mkdir -p /data/data/com.google.android.dialer/files/phenotype
    #     cp -Tf $MAINDIR/com.google.android.dialer /data/data/com.google.android.dialer/files/phenotype/com.google.android.dialer
    #     chmod 500 /data/data/com.google.android.dialer/files/phenotype
    #     am force-stop com.google.android.dialer
    # fi

    if [ $(grep Live $MAINDIR/var.prop | cut -d'=' -f2) -eq 1 ]; then
        pm enable -n com.google.pixel.livewallpaper/com.google.pixel.livewallpaper.pokemon.wallpapers.PokemonWallpaper -a android.intent.action.MAIN
    fi

    pm enable -n com.google.android.settings.intelligence/com.google.android.settings.intelligence.modules.battery.impl.usage.BootBroadcastReceiver -a android.intent.action.MAIN
    pm enable -n com.google.android.settings.intelligence/com.google.android.settings.intelligence.modules.battery.impl.usage.DataInjectorReceiver -a android.intent.action.MAIN
    pm enable -n com.google.android.settings.intelligence/com.google.android.settings.intelligence.modules.batterywidget.impl.BatteryWidgetBootBroadcastReceiver -a android.intent.action.MAIN
    pm enable -n com.google.android.settings.intelligence/com.google.android.settings.intelligence.modules.batterywidget.impl.BatteryWidgetUpdateReceiver -a android.intent.action.MAIN
    pm enable -n com.google.android.settings.intelligence/com.google.android.settings.intelligence.modules.battery.impl.usage.PeriodicJobReceiver -a android.intent.action.MAIN
    sleep .5
    pm enable -n com.google.android.settings.intelligence/com.google.android.settings.intelligence.modules.batterywidget.impl.BatteryAppWidgetProvider -a android.intent.action.MAIN
    pm enable com.google.android.googlequicksearchbox/com.google.android.apps.search.assistant.surfaces.dictation.service.endpoint.AssistantDictationService
    am broadcast -a grpc.io.action.BIND -n com.google.android.googlequicksearchbox/com.google.android.apps.search.assistant.surfaces.dictation.service.endpoint.AssistantDictationService
    am force-stop com.google.android.settings.intelligence

    settings put global settings_enable_clear_calling true
    settings put secure show_qr_code_scanner_setting true
    set_device_config

    update_sql

    patch_gboard
    am force-stop com.google.android.dialer com.google.android.inputmethod.latin

    # Google Photos
    db_edit com.google.android.apps.photos boolVal 1 "45389969" "45429858" "45377931" "45430953" "45417067" "45413465"
    #Audio Eraser, Magic Editor
    db_edit com.google.android.apps.photos boolVal 1 "45417606" "45421373"
    # Fix for tools not installed, new magic eraser
    db_edit com.google.android.apps.photos boolVal 0 "45425404" "45398451" "45422612"
    db_edit com.google.android.apps.photos extensionVal "45415301" "$AUDIO_ERASER"
    db_edit com.google.android.apps.photos extensionVal "45420912" "$MAGIC_EDITOR"
    db_edit com.google.android.apps.photos extensionVal "45422509" "$ME3"
    db_edit com.google.android.apps.photos extensionVal "45416982" "$BESTTAKE"
    db_edit com.google.android.apps.photos extensionVal "3015" "$GPHOTOS"
    db_edit com.google.android.apps.photos extensionVal "45378073" "$ERASER"

    loop_count=0

    # Wait for the boot
    while true; do
        if [ -f $PHOTOS_PREF ]; then
            sleep 5
            pref_patch 45417606 true boolean $PHOTOS_PREF
            pref_patch 45421373 true boolean $PHOTOS_PREF
            pref_patch 45425404 false boolean $PHOTOS_PREF
            pref_patch 45398451 false boolean $PHOTOS_PREF
            pref_patch 45422612 false boolean $PHOTOS_PREF
            break
        fi
        if [ $loop_count -gt 5 ]; then
            log " ! Boot time exceeded"
            break
        fi
        sleep 5
        loop_count=$((loop_count + 1))
    done

    LOS_FIX=0
    if [ $API -eq 33 ]; then
        for i in "ro.lineage.device" "ro.crdroid.version" "ro.rice.version" "ro.miui.ui.version.code"; do
            if [ ! -z "$(getprop $i)" ]; then
                LOS_FIX=1
                break
            fi
        done
    fi
    if [ -f $MODDIR/first ]; then
        if [ -d /data/data/com.google.android.apps.nexuslauncher ]; then
            #pm install $MODDIR/system/**/priv-app/WallpaperPickerGoogleRelease/WallpaperPickerGoogleRelease.apk
            pl_fix
        fi
        rm -rf $MODDIR/first
    fi
fi

# loop=0
# while true; do
#     set_device_config
#     # Run loop for 10mins
#     if [ $loop -ge 600 ]; then
#         break
#     fi
#     sleep 1
#     loop=$((loop + 1))
# done
# sleep 30
# [ $(device_config get privacy location_accuracy_enabled) != "true" ] && sleep 1 && set_device_config

log "Service Finished"
echo "$temp" >>/sdcard/Pixelify/logs.txt
