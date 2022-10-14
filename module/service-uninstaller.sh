#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in late_start service mode

sqlite=/data/adb/modules/PixelifyUninstaller/addon/sqlite3
chmod 0755 $sqlite

gms=/data/data/com.google.android.gms/databases/phenotype.db
gser=/data/data/com.google.android.gsf/databases/gservices.db

dis="com.google.android.gms/com.google.android.gms.update.phone.PopupDialog"

update="com.android.vending/com.google.android.finsky.systemupdate.SystemUpdateSettingsContentProvider
com.android.vending/com.google.android.finsky.systemupdateactivity.SettingsSecurityEntryPoint
com.android.vending/com.google.android.finsky.systemupdateactivity.SystemUpdateActivity
com.google.android.gms/com.google.android.gms.update.phone.PopupDialog
com.google.android.gms/com.google.android.gms.update.OtaSuggestionSummaryProvider
com.google.android.gms/com.google.android.gms.update.SystemUpdateActivity
com.google.android.gms/com.google.android.gms.update.SystemUpdateGcmTaskService
com.google.android.gms/com.google.android.gms.update.SystemUpdateService
com.google.android.apps.wellbeing/com.google.android.apps.wellbeing.sleepinsights.ui.SleepInsightsActivity
com.google.android.apps.wellbeing/com.google.android.apps.wellbeing.sleepinsights.ui.dailyinsights.SleepInsightsDailyCardsActivity
com.google.android.apps.wellbeing/com.google.android.apps.wellbeing.coughandsnore.consent.ui.CoughAndSnoreConsentActivity"

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

# Wait for the boot
while true; do
    boot=$(getprop sys.boot_completed)
    if [ "$boot" -eq 1 ]; then
        sleep 5
        break
    fi
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
    rm -rf chmod 0755 /data/data/com.google.android.dialer/files/phenotype/*

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

    echo "- Uninstalled Completed" >>/sdcard/Pixelify/logs.txt

    # Remove Unistaller itself
    rm -rf /data/adb/modules/PixelifyUninstaller
fi

# copy bootlogs to Pixelify folder if bootloop happened.
[ -f /data/adb/modules/Pixelify/boot_logs.txt ] && rm -rf /sdcard/Pixelify/boot_logs.txt && mv /data/adb/modules/Pixelify/boot_logs.txt /sdcard/Pixelify/boot_logs.txt

for i in $dis; do
    pm disable $i
done

for i in $update; do
    pm enable $i
done

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
settings put global settings_enable_clear_calling true
set_device_config
# sleep 30
# [ $(device_config get privacy location_accuracy_enabled) != "true" ] && sleep 1 && set_device_config
