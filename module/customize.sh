#!/system/bin/sh

# run Pixelify Functions and Variables
. $MODPATH/vars.sh || abort
. $MODPATH/utils.sh || abort

alias keycheck="$MODPATH/addon/keycheck"
sqlite=$MODPATH/addon/sqlite3
VOL_KEYS="$(grep 'DEVICE_USES_VOLUME_KEY=' $MODPATH/module.prop | cut -d= -f2)"

chmod 0755 $sqlite

[ -z "$MAGISKTMP" ] && MAGISKTMP=/sbin

# Fetch Zygisk is enabled or not from magisk database
zygisk_enabled="$(magisk --sqlite "SELECT value FROM settings WHERE (key='zygisk')")"

# Update Riru Path
if [ "$MAGISK_VER_CODE" -ge 21000 ]; then
    MAGISK_CURRENT_RIRU_MODULE_PATH=$(magisk --path)/.magisk/modules/riru-core
else
    MAGISK_CURRENT_RIRU_MODULE_PATH=/sbin/.magisk/modules/riru-core
fi

# Set Riru util_functions path
if [ -f $MAGISK_CURRENT_RIRU_MODULE_PATH/util_functions.sh ]; then
    riru_path=$MAGISK_CURRENT_RIRU_MODULE_PATH/util_functions.sh
elif [ -f /data/adb/riru/util_functions.sh ]; then
    riru_path=$MAGISK_CURRENT_RIRU_MODULE_PATH/util_functions.sh
else
    riru_path=""
fi

# Set Installation type: Normal, Zygsik, Riru
if [ "$KSU" == true ]; then
    ui_print "- Root App: KSU"
    if [ -d '/data/adb/modules/zygisksu' ]; then
        # ZygiskSU is installed.
        # Set the module type to ZygsikSU
        MODULE_TYPE=2
        ui_print "- Installation Type: Zygisk"
    else
        # ZygiskSU is not installed.
        # Set the module type to normal installation
        MODULE_TYPE=1
        ui_print "- Installation Type: normal installation"
    fi
else
    ui_print "- Root App: Magisk"
    if [ ! -z $riru_path ]; then
        # Riru is installed.
        # Check if Zygisk is enabled.
        if [ "$zygisk_enabled" == "value=1" ]; then
            # Set the module type to Zygsik
            MODULE_TYPE=2
            ui_print "! Riru Installed but disabled"
            ui_print "- Switching to zygisk mode"
            ui_print ""
            ui_print "- Installation Type: Zygisk"
        else
            # Riru is disabled.
            ui_print "- Load $MAGISK_CURRENT_RIRU_MODULE_PATH/util_functions.sh"
            # Load the Riru utility functions.
            . $riru_path
            # Check the installation type.
            check_install_type
        fi
    else
        # Riru is not installed.
        # Check if Magisk is at least version 24000.
        if [ "$MAGISK_VER_CODE" -ge 24000 ]; then
            # Magisk is at least version 24000.
            # Set the module type to 2.
            MODULE_TYPE=2
            ui_print "- Installation Type: Zygisk"
            # Check if zygsik is enabled.
            if [ "$zygisk_enabled" != "value=1" ]; then
                # Riru is not enabled.
                ui_print "! Please enable zygisk in magisk"
            fi
        else
            # Magisk is not at least version 24000.
            # Set the module type normal installation
            MODULE_TYPE=1
            ui_print "- Installation Type: normal installation"
        fi
    fi
fi

# Update Library according to installation type
if [ $MODULE_TYPE -eq 2 ]; then
    # The module is using Zygisk.
    # Move the Zygisk libraries to the `zygisk` directory in the module path.
    mv "$ZYGISK_LIB_PATH" "$MODPATH/zygisk"
elif [ $MODULE_TYPE -eq 3 ]; then
    # The module is using Riru.
    # Enforce installation from the Magisk app.
    enforce_install_from_magisk_app
    # Detect the API level and architecture.
    api_level_arch_detect
    # Create the `riru` directory in the module path.
    mkdir "$MODPATH/riru"
    # Check the 32-bit ABI.
    if [ "$ABI32" == "armeabi-v7a" ]; then
        # The module is using the 32-bit ARM ABI.
        # Move the 32-bit ARM library to the `lib` directory in the `riru` directory.
        mv -f "$RIRU_LIB_PATH/armeabi-v7a" "$MODPATH/riru/lib"
        # Check if the module is using the 64-bit ARM ABI.
        if [ "$IS64BIT" = true ]; then
            # The module is using the 64-bit ARM ABI.
            # Move the 64-bit ARM library to the `lib64` directory in the `riru` directory.
            mv -f "$RIRU_LIB_PATH/arm64-v8a" "$MODPATH/riru/lib64"
        fi
    else
        # The module is using the 32-bit x86 ABI.
        # Move the 32-bit x86 library to the `lib` directory in the `riru` directory.
        mv -f "$RIRU_LIB_PATH/x86" "$MODPATH/riru/lib"
        # Check if the module is using the 64-bit x86 ABI.
        if [ "$IS64BIT" = true ]; then
            # The module is using the 64-bit x86 ABI.
            # Move the 64-bit x86 library to the `lib64` directory in the `riru` directory.
            mv -f "$RIRU_LIB_PATH/x86_64" "$MODPATH/riru/lib64"
        fi
    fi
fi

# Exit for Unsupported Android Versions (Required Nougat+)
if [ $API -le 23 ]; then
    ui_print " x Minimum requirements doesn't meet"
    ui_print " x Android version: 7.0+"
    exit 1
fi

# Remove Extra Library
rm -rf $MODPATH/lib

#sql file
touch $MODPATH/flags.txt

# Check architecture
if [ "$ARCH" != "arm" ] && [ "$ARCH" != "arm64" ] && [ "$ARCH" != "x86" ] && [ "$ARCH" != "x64" ]; then
    abort " x Unsupported platform: $ARCH"
fi

# Check for internal spoofing is available when ro.xxx.device disables it.
for i in $overide_spoof; do
    if [ ! -z $i ]; then
        kkk="$(getprop $i)"
        if [ ! -z $kkk ] || [ "$kkk" == "redfin" ]; then
            exact_prop="$i"
            spoof_message="  Note: This may break ota update of your rom"
            KEEP_PIXEL_2021=1
            break
        fi
    fi
done

# Check for internal spoofing is available when it is detected with ro.xxx.device but ro.product.device disables it.
if [ -z $exact_prop ]; then
    for i in $device_spoof; do
        if [ ! -z $i ]; then
            kkk="$(getprop $i)"
            if [ ! -z $kkk ] || [ "$kkk" == "redfin" ]; then
                exact_prop="ro.product.device"
                spoof_message="  Note: This may cause issue to Google camera"
                KEEP_PIXEL_2021=1
                break
            fi
        fi
    done
fi

# Check for internal spoofing is available when it is detected with ro.xxx.device but org.pixelexperience.device disables it.
if [ -z $exact_prop ]; then
    for i in $pixel_spoof; do
        if [ ! -z $i ]; then
            kkk="$(getprop $i)"
            if [ ! -z $kkk ] || [ "$kkk" == "redfin" ]; then
                exact_prop="org.pixelexperience.device"
                break
            fi
        fi
    done
fi

# Roms which have Unlimited photos Featues, so that we could copy PIXEL_2021 without breaking Unilimited backup
if [ $KEEP_PIXEL_2021 -eq 0 ] && [ $API -eq 33 ]; then
    for i in $PIXEL_2021_ROMS; do
        if [ ! -z $i ]; then
            kkk="$(getprop $i)"
            if [ ! -z $kkk ]; then
                KEEP_PIXEL_2021=1
                break
            fi
        fi
    done
    if [ $KEEP_PIXEL_2021 -eq 0 ] && [ ! -z "$(getprop ro.custom.version | grep PixelOS)" ]; then
        KEEP_PIXEL_2021=1
    fi
fi

# if [ -z $exact_prop ]; then
#     case "$(getprop ro.custom.version)" in
#     PixelOS_*)
#         exact_prop="ro.custom.device"
#         ;;
#     esac
# fi

# Clean up old logs
rm -rf $logfile
rm -rf $flaglogfile

am force-stop com.android.vending

# Logs initial format
echo "=============
   Pixelify $(cat $MODPATH/module.prop | grep version= | cut -d= -f2)
   SDK version: $API
=============
---- Installation Logs Started ----
" >>$logfile

# extract system
tar -xf $MODPATH/files/system.tar.xz -C $MODPATH

# set permissions to executables
chmod 0755 $MODPATH/addon/*

# Check phones is a ONEPLUS device and requires crash fix
if [ -d /system_ext/oplus ] && [ $ROMTYPE == "oplus" ]; then
    REQ_FIX=1
fi

# Set variables indicating fixes for ROMS
if [ $API -ge 31 ] && [ $REQ_FIX -eq 1 ]; then
    TARGET_DEVICE_OP12=1
elif [ $API -ge 31 ] && [ $ROMTYPE == "oneui" ]; then
    TARGET_DEVICE_ONEUI=1
fi

# Fix for Pixel Launcher in Oneplus devices
if [ $TARGET_DEVICE_OP12 -eq 1 ] && [ $API -eq 33 ]; then
    LOS_FIX=1
fi

# Check internet is present of not
online
if [ $internet -eq 1 ]; then
    print "- Internet: Present"
else
    print "- Internet: Not Present"
fi

#Create Pixelify directory for saving backups and logs.
mkdir -p /sdcard/Pixelify

# create Pixelify data directory (It saves which options are choosen)
if [ ! -d $pix ]; then
    mkdir -p $pix
fi

# We start apps selection in apps_temp.txt (Fixes bug when installation failed so updated in the end to app.txt)
if [ -f $pix/app.txt ]; then
    rm -rf $pix/apps_temp.txt
    cp -f $pix/app.txt $pix/apps_temp.txt
else
    touch $pix/apps_temp.txt
fi

rm -rf $pix/app2.txt
touch $pix/app2.txt

# Set default Nga resources version
if [ $ENABLE_OSR -eq 1 ] || [ $DOES_NOT_REQ_SPEECH_PACK -eq 1 ]; then
    NGAVERSIONP=1.3
fi

# Fetch Security patch and Build Date of ROM
sec_patch=$(date -d $(getprop ro.build.version.security_patch) +%s)
build_date=$(getprop ro.build.date.utc)

# USE Recents fix Pixel Launcher for Android 13
if [ $API -eq 33 ]; then
    LOS_FIX=1
fi

# Set Does Pixel Launcher Requires new Package
if [ $API -eq 31 ]; then
    # Check if the security patch is greater than or equal to December 2021
    if [ $sec_patch -ge $(date -d 2021-12-01 +%s) ]; then
        PL_VERSION="dec_2021"
    fi
elif [ $API -eq 32 ]; then
    if [ $sec_patch -ge $(date -d 2022-06-01 +%s) ] || [ $build_date -ge $(date -d 2022-06-01 +%s) ]; then
        PL_VERSION="jun_2022"
    fi
elif [ $API -eq 33 ]; then
    if [ $sec_patch -ge $(date -d 2023-08-01 +%s) ] || [ $build_date -ge $(date -d 2023-08-01 +%s) ]; then
        PL_VERSION="aug_2023"
        LOS_FIX=0
    elif [ $sec_patch -ge $(date -d 2023-07-01 +%s) ] || [ $build_date -ge $(date -d 2023-07-01 +%s) ]; then
        PL_VERSION="jul_2023"
        LOS_FIX=0
    elif [ $sec_patch -ge $(date -d 2023-05-01 +%s) ] || [ $build_date -ge $(date -d 2023-05-01 +%s) ]; then
        PL_VERSION="may_2023"
    elif [ $sec_patch -ge $(date -d 2022-12-01 +%s) ] || [ $build_date -ge $(date -d 2022-12-01 +%s) ]; then
        PL_VERSION="dec_2022"
    fi
    if [ $sec_patch -ge $(date -d 2023-06-01 +%s) ] || [ $build_date -ge $(date -d 2023-06-01 +%s) ]; then
        REQ_NEW_WLP=1
    fi
fi

if [ $LOS_FIX -eq 1 ]; then
    PL_VERSION="los_$PL_VERSION"
fi

echo "- Pixel Launcher version required for sdk $API: $PL_VERSION" >>$logfile

#save device info in logs
echo "
- Device info -
Codename: $(getprop ro.product.vendor.name)
Model: $(getprop ro.product.vendor.model)
security patch: $sec_patch
Magisk version: $MAGISK_VER_CODE
 - Device info -
" >>$logfile

# Set version and size when Pixelify is launcher (used when device doesn't use internet)
if [ $API -eq 34 ]; then
    echo "Android version: 14" >>$logfile
    WNEED=1
    DPSIZE="33 Mb"
    WSIZE="6 Mb"
    PLSIZE="11 Mb"
    DPVERSIONP=1
    PLVERSIONP=1
elif [ $API -eq 33 ]; then
    echo "Android version: 13" >>$logfile
    WNEED=1
    DPSIZE="35 Mb"
    WSIZE="2.2 Mb"
    PLSIZE="11 Mb"
    DPVERSIONP=3.6
    PLVERSIONP=1
elif [ $API -eq 32 ]; then
    echo "Android version: 12.1 (12L)" >>$logfile
    WNEED=1
    DPSIZE="52 Mb"
    WSIZE="2.2 Mb"
    PLSIZE="11 Mb"
    DPVERSIONP=2.7
    if [ $NEW_PL -eq 1 ]; then
        PLVERSIONP=2.1
    else
        PLVERSIONP=1.3
    fi
    PLSIZE="11 Mb"
elif [ $API -eq 31 ]; then
    echo "Android version: 12 (S)" >>$logfile
    DPSIZE="52 Mb"
    DPVERSIONP=2.5
    WSIZE="2.0 Mb"
    WNEED=1
    if [ $NEW_JN_PL -eq 1 ]; then
        PLVERSIONP=1.4
    elif [ $NEW_PL -eq 1 ]; then
        PLVERSIONP=1.4
    else
        PLVERSIONP=1.3
    fi
    PLSIZE="11 Mb"
elif [ $API -eq 30 ]; then
    echo "Android version: 11 (R)" >>$logfile
    DPSIZE="20 Mb"
    DPVERSIONP=1.2
    WSIZE="2.1 Mb"
    WNEED=1
elif [ $API -eq 29 ]; then
    echo "Android version: 10 (Q)" >>$logfile
    WSIZE="3.6 Mb"
    DPSIZE="15 Mb"
    DPVERSIONP=1
    WNEED=1
elif [ $API -eq 28 ]; then
    echo "Android version: 9 (Pie)" >>$logfile
    WSIZE="1.6 Mb"
    DPSIZE="10 Mb"
    DPVERSIONP=1
    WNEED=1
fi
WLPVERSIONP=1
WLPSIZE="3 Mb"

# Fetch latest version
fetch_version

# Finally set version of offline package
set_version

# Fixes for Pixel 4 devices, it gets hang when Android System intelligence gets spoofed to another pixel
if [ "$(getprop ro.product.vendor.name)" == "coral" ] || [ "$(getprop ro.product.vendor.name)" == "flame" ]; then
    echo "- Pixel 4/XL Detected !" >>$logfile
    for i in $MODPATH/zygisk/* $MODPATH/riru/*/*; do
        sed -i -e "s/com.google.android.xx/com.google.android.as/g" $i
    done
fi

# Save version fetched in logs
echo "
- NGA version: $NGAVERSION
- Pixel Live Wallpapers version: $NGAVERSION
- Device Personalisation Services version: $DPVERSION
- Pixel Launcher ($API) version: $PLVERSION
" >>$logfile

# Set permisions
chmod -R 0755 $MODPATH/addon
chmod 0644 $MODPATH/files/*.xz

# Find the all accounts signed in Device
gacc="$("$sqlite" "$gms" "SELECT DISTINCT(user) FROM Flags WHERE user != '';")"

# Android lower than Q doesn't properly use product or system_ext partion, move it to system
if [ $API -le 28 ]; then
    cp -r $MODPATH/system/product/. $MODPATH/system
    cp -r $MODPATH/system/overlay/. $MODPATH/system/vendor/overlay
    cp -r $MODPATH/system/system_ext/. $MODPATH/system
    rm -rf $MODPATH/system/overlay
    rm -rf $MODPATH/system/product
    rm -rf $MODPATH/system/system_ext
    product=
else
    product=/product
fi

# create priv-app, app folders to copy in future
mkdir -p $MODPATH/system$product/priv-app
mkdir -p $MODPATH/system$product/app

# print basic device info
print ""
print "- Detected Arch: $ARCH"
print "- Detected SDK : $API"
RAM=$(grep MemTotal /proc/meminfo | tr -dc '0-9')
print "- Detected Ram: $RAM"
check_rom_type
print ""

# remove pinning of Google camera, as it is not recommended to use for device less than 6gb ram
if [ $RAM -le "6000000" ]; then
    rm -rf $MODPATH/system$product/etc/sysconfig/GoogleCamera_6gb_or_more_ram.xml
    echo " - Removing GoogleCamera_6gb_or_more_ram.xml as device has less than 6Gb Ram" >>$logfile
fi

DIALER1=$(find /system -name *Dialer.apk)
GOOGLE=$(find /system -name Velvet.apk)

# Remove Android System Intelligence app if installed
if [ $API -ge "28" ]; then
    if [ ! -z $(find /system -name DevicePerson* | grep -v "\.") ] && [ ! -z $(find /system -name DevicePerson* | grep -v "\.") ]; then
        DP1=$(find /system -name DevicePerson* | grep -v "\.")
        DP2=$(find /system -name Matchmaker* | grep -v "\.")
        DP="$DP1 $DP2"
    elif [ -z $(find /system -name DevicePerson* | grep -v "\.") ]; then
        DP=$(find /system -name Matchmaker* | grep -v "\.")
    else
        DP=$(find /system -name DevicePerson* | grep -v "\.")
    fi
fi

# Remove Google Health services
if [ $API -ge 28 ]; then
    TUR=$(find /system -name Turbo*.apk | grep -v overlay)
    REMOVE="$REMOVE $TUR"
fi

# set Config.prop location
if [ -f /sdcard/Pixelify/config.prop ]; then
    vk_loc="/sdcard/Pixelify/config.prop"
else
    vk_loc="$MODPATH/config.prop"
fi

# Have user option to skip vol keys
export TURN_OFF_SEL_VOL_PROMPT=0

# Setup Volume keys for installation
# Check if it is no-Vk zip
if [ "$VOL_KEYS" -eq 0 ]; then
    print "- Skipping Vol Keys -"
    if [ -f /sdcard/Pixelify/config.prop ]; then
        print ""
        print " Using config: $vk_loc"
        VKSEL=no_vksel
    else
        print "X Config not found installation"
        print "- Config is now placed at /sdcard/Pixelify/config.prop"
        mkdir -p /sdcard/Pixelify
        cp -f $vk_loc /sdcard/Pixelify/config.prop
        print "- Please configure it and reinstall pixelify"
        abort
    fi
else
    # Use keytest to assign method (chooseport or old)
    if keytest; then
        echo "- Using chooseport method for Volume keys" >>$logfile
        VKSEL=chooseport
    else
        VKSEL=chooseportold
        echo "- using chooseportold method for Volume Keys" >>$logfile
        print "  ! Legacy device detected! Using old keycheck method"
        print " "
        print "- Vol Key Programming -"
        print "  Press Vol Up Again:"
        $VKSEL "UP"
        print "  Press Vol Down"
        $VKSEL "DOWN"
    fi
fi

# Installtion
print ""
print "- Installing Pixelify Module"
print "- Extracting Files...."
print ""
print "- Please don't turn off screen between the installation"
print ""
echo "- Extracting Files ..." >>$logfile

# install Google Health services for Android Pie and Above
# if [ $API -ge 28 ]; then
#     tar -xf $MODPATH/files/tur.tar.xz -C $MODPATH/system$product/priv-app
# fi

# Allow users to use config with Volume key installation if config is placed
if [ -f /sdcard/Pixelify/config.prop ] && [ $VOL_KEYS -eq 1 ]; then
    print "  (Config detected)"
    print "  Do you want to use config for installation?"
    print "   Vol Up += Yes"
    print "   Vol Down += No"
    if $VKSEL; then
        VKSEL=no_vksel
        VOL_KEYS=0
    fi
fi

# Allow now to force enable network
FIRST_ONLINE_TIME=1

# Options menu to log
echo "$var_menu" >>$logfile

# Internal Spoofing
if [ ! -z $exact_prop ] && [ $API -ge 31 ] && [ $BETA_BUILD -eq 1 ]; then
    print "  Disclaimer: This Feature is in BETA"
    print "  This features is only intended to Quick Phrase."
    #print "  Disabling Internal Spoofing can break OTA Update (rom dependent)"
    print "  If it doesn't work properly then it causes issues to Google app"
    print "  If you are not aware of We wont recommended to enable it."
    print ""
    print "  Do you want to disable Internal spoofing of rom?"
    print "  Note: This may break ota update of your rom"
    print "   Vol Up += Yes"
    print "   Vol Down += No"
    no_vk "DISABLE_INTERNAL_SPOOFING"
    if $VKSEL; then
        echo " " >>$MODPATH/system.prop
        echo "$exact_prop=redfin" >>$MODPATH/system.prop
    fi
fi

# Google Photos Unlimited Backup Setup
if [ $TENSOR -eq 1 ]; then
    print "(TENSOR CHIPSET DETECTED)"
    print "  Do you want to enable Google Photos Unlimited Backup?"
    print "  Note: Photos unblur won't work and Magic eraser may work slower"
    print "   Vol Up += Yes"
    print "   Vol Down += No"
    no_vk "ENABLE_PHOTOS_UNLIMITED"
    if $VKSEL; then
        echo "- Enabling Unlimited storage in this Tensor chipset device" >>$logfile
        drop_sys
    else
        echo "- Disabling Unlimited storage in this Tensor chipset device" >>$logfile
        rm -rf $MODPATH/zygisk $MODPATH/zygisk_1
    fi

# If Installation mode is Zygisk or Riru, Drop PIXEL_EXPERIENCES to support unlimited storage
elif [ $MODULE_TYPE -eq 2 ] || [ $MODULE_TYPE -eq 3 ]; then
    echo "- Enabling Unlimited storage" >>$logfile
    drop_sys
else
    # As there is No option for Particular apps spooifng with zygsik or Riru, go with legacy one
    print "  Do you want to Spoof your device to Pixel 5/Pixel 6 Pro?"
    print "   Vol Up += Yes"
    print "   Vol Down += No"
    no_vk "ENABLE_PIXEL_SPOOFING"
    if $VKSEL; then
        PIXEL_SPOOF=1
        print " ---------"
        print "  Note: If your device has any problems with downloading in the Play Store, "
        print "  Please Select Pixel 6 Pro"
        print "---------"
        print ""
        print "  Select Spoof to Pixel 5 (recommended) or Pixel 6 Pro?"
        print "   Vol Up += Pixel 5"
        print "   Vol Down += Pixel 6 Pro (Google Photos Unlimited backup may not work properly)"
        no_vk "TARGET_USES_PIXEL5_SPOOF"
        if $VKSEL; then
            sed -i -e "s/Pixel 6 Pro/Pixel 5/g" $MODPATH/spoof.prop
        fi
        # Remove Pixel Experience 2021 to 2023
        KEEP_PIXEL_2021=0
        KEEP_PIXEL_2020=1
        drop_sys
        echo " - Spoofing device to $(grep ro.product.model $MODPATH/spoof.prop | cut -d'=' -f2) ( $(grep ro.product.device $MODPATH/spoof.prop | cut -d'=' -f2) )" >>$logfile
        cat $MODPATH/spoof.prop >>$MODPATH/system.prop
    else
        echo " - Ignoring spoofing device" >>$logfile
    fi
fi

# Disable Android System intelligence as there it already installed.
if [ ! -z $(pm list packages -s | grep com.google.android.as) ]; then
    echo " - Android System Intelligence is installed as system app" >>$logfile
    # Dont disable incase if Android System Intelligence gets system app via Pixelify (case when user installs Pixelify 2nd time)
    if [ -z $(cat $pix/apps_temp.txt | grep "dp-$API") ]; then
        if [ $API -eq 30 ] && [ ! -z $($MODPATH/addon/dumpsys package com.google.android.as | grep versionName | grep pixel5) ]; then
            echo " - Ignoring Android System Intelligence due to Pixel 5 version already installed" >>$logfile
            DPAS=0
        elif [ $API -le 29 ]; then
            DPAS=0
            echo " - Ignoring Android System Intelligence because it's already installed" >>$logfile
        fi
    fi
fi

# Android Oreo and below dont have Android System Intelligence
if [ $API -le 27 ]; then
    echo " - Disabling Android System Intelligence installation due to the api not supported" >>$logfile
    DPAS=0
fi

# For now disable Android System Intelligence of ONE Ui, as some bootloop reported before
if [ "$(getprop ro.product.vendor.manufacturer)" == "samsung" ]; then
    if [ ! -z "$(getprop ro.build.PDA)" ]; then
        echo " - Disabling Android System Intelligence installation on samsung devices" >>$logfile
        DPAS=0
    fi
fi

#[ -f /product/etc/firmware/music_detector.sound_model ] && rm -rf $MODPATH/system/etc/firmware && NOT_REQ_SOUND_PATCH=1

# Android System Intelligence installation
if [ $DPAS -eq 1 ]; then
    echo " - Installing Android System Intelligence" >>$logfile
    # If there is a backup, use it
    if [ -f /sdcard/Pixelify/backup/dp-$API.tar.xz ]; then
        echo " - Backup Detected for Android System Intelligence" >>$logfile
        REMOVE="$REMOVE $DP"
        # Check Backup is of latest version or not.
        if [ "$(cat /sdcard/Pixelify/version/dp-$API.txt)" != "$DPVERSION" ] || [ $SEND_DPS -eq 1 ] || [ ! -f /sdcard/Pixelify/version/dp-$API.txt ]; then
            echo " - New Version Detected for Android System Intelligence" >>$logfile
            echo " - Installed version: $(cat /sdcard/Pixelify/version/dp-$API.txt) , New Version: $DPVERSION " >>$logfile
            print "  (Network Connection Needed)"
            print "  New version Detected of Android System Intelligence"
            print "  Do you Want to update or use Old Backup?"
            print "  Version: $DPVERSION"
            print "  Size: $DPSIZE Mb"
            print ""
            print "   Vol Up += Update"
            print "   Vol Down += Use Old Backup"
            no_vk "UPDATE_DPS"
            if $VKSEL; then
                online
                # Download and Install Latest one
                if [ $internet -eq 1 ]; then
                    echo " - Downloading and installing new backup for Android System Intelligence" >>$logfile
                    cd $MODPATH/files
                    rm -rf /sdcard/Pixelify/backup/dp-$API.tar.xz /sdcard/Pixelify/backup/dp-net-$API.tar.xz /sdcard/Pixelify/version/dp.txt /sdcard/Pixelify/version/dp-$API.txt
                    # Fetch and download Android system Intelligence
                    if [ $API -eq 31 ] || [ $API -eq 32 ]; then
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/asi-new-31.tar.xz -o dp-$API.tar.xz &>/proc/self/fd/$OUTFD
                    elif [ $API -ge 33 ]; then
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/asis-new-$API.tar.xz -o dp-$API.tar.xz &>/proc/self/fd/$OUTFD
                    else
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/dp-$API.tar.xz -O &>/proc/self/fd/$OUTFD
                    fi
                    cp -f $MODPATH/files/dp-$API.tar.xz /sdcard/Pixelify/backup/dp-$API.tar.xz
                    echo "$DPVERSION" >>/sdcard/Pixelify/version/dp-$API.txt
                    cd /
                    print ""
                    print "- Creating Backup"
                else
                    print ""
                    print " ! No internet detected"
                    print ""
                    print "! Using Old backup for now."
                    echo " ! Using Old backup for Android System Intelligence due to no internet services" >>$logfile
                    print ""
                fi
            else
                echo " - Using Old backup for Android System Intelligence" >>$logfile
                print ""
            fi
        fi
        # Install Now now playing (option is disabled)
        #now_playing
        print "- Installing Android System Intelligence"
        print ""
        # Copy Android System Intelligence overlay to grant default permissions
        cp -f $MODPATH/files/PixelifyDPS.apk $MODPATH/system/product/overlay/PixelifyDPS.apk
        tar -xf /sdcard/Pixelify/backup/dp-$API.tar.xz -C $MODPATH/system$product/priv-app
        echo dp-$API >$pix/app2.txt
    else
        # Give option to user wether to download or not in case no backup is detected
        print ""
        echo " - No backup Detected for Android System Intelligence" >>$logfile
        print "  (Network Connection Needed)"
        print "  Do you want to install and Download Android System Intelligence?"
        print "  Size: $DPSIZE Mb"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        no_vk "ENABLE_DPS"
        if $VKSEL; then
            # Checker internet is available or not
            online
            if [ $internet -eq 1 ]; then
                print "- Downloading Android System Intelligence"
                echo " - Downloading and installing Android System Intelligence" >>$logfile
                print ""
                cd $MODPATH/files
                # Fetch and download Android System intelligence
                if [ $API -eq 31 ] || [ $API -eq 32 ]; then
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/asi-new-31.tar.xz -o dp-$API.tar.xz &>/proc/self/fd/$OUTFD
                elif [ $API -ge 33 ]; then
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/asis-new-$API.tar.xz -o dp-$API.tar.xz &>/proc/self/fd/$OUTFD
                else
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/dp-$API.tar.xz -O &>/proc/self/fd/$OUTFD
                fi
                cd /
                #now_playing
                print ""
                print "- Installing Android System Intelligence"
                # copy Android system intelligence overlay to give defualt permissions
                cp -f $MODPATH/files/PixelifyDPS.apk $MODPATH/system/product/overlay/PixelifyDPS.apk

                # Extract Android system Intelligence
                tar -xf $MODPATH/files/dp-$API.tar.xz -C $MODPATH/system$product/priv-app
                echo dp-$API >$pix/app2.txt

                # Remove System Android system Intelligence
                REMOVE="$REMOVE $DP"

                # Create backup
                print ""
                print "  Do you want to create backup of Android System Intelligence?"
                print "  so that you don't need redownload it every time."
                print "   Vol Up += Yes"
                print "   Vol Down += No"
                no_vk "BACKUP_DPS"
                if $VKSEL; then
                    echo " - Creating backup for Android System Intelligence" >>$logfile
                    print "- Creating Backup"
                    mkdir -p /sdcard/Pixelify/backup
                    rm -rf /sdcard/Pixelify/backup/dp-$API.tar.xz /sdcard/Pixelify/backup/dp-net-$API.tar.xz /sdcard/Pixelify/version/dp.txt /sdcard/Pixelify/version/dp-$API.txt
                    cp -f $MODPATH/files/dp-$API.tar.xz /sdcard/Pixelify/backup/dp-$API.tar.xz
                    print ""
                    mkdir /sdcard/Pixelify/version
                    echo "$DPVERSION" >>/sdcard/Pixelify/version/dp-$API.txt
                    print " - Done"
                fi
            else
                print " ! No internet detected"
                print ""
                print "- Skipping Android System Intelligence"
                print ""
                echo " - Skipping Android System Intelligence due to no internet services" >>$logfile
            fi
        fi
    fi
    # Install it as user app also along with system app (Android 12 had some crashes ony with system app)
    pm install $MODPATH/system/product/priv-app/DevicePersonalizationPrebuiltPixel*/*.apk &>/dev/null
    [ $API -ge 31 ] && pm install $MODPATH/system/product/priv-app/DeviceIntelligenceNetworkPrebuilt/*.apk &>/dev/null
    rm -rf $MODPATH/system/product/priv-app/asi_up.apk
else
    print ""
fi

# Google Photos App
gphotos8

# Google Dialer Feature installation

# Check Google dialer is installed or not
if [ -d /data/data/$DIALER ]; then
    print "  Do you want to install Google Dialer features?"
    print "   - Includes Call Screening, Call Recording, Hold for Me, Direct My Call"
    print "   (For all Countries)"
    print "    Vol Up += Yes"
    print "    Vol Down += No"
    no_vk "ENABLE_DIALER_FEATURES"
    if $VKSEL; then
        echo " - Installing Google Dialer features" >>$logfile

        # Enable it to let service.sh to know callscreening enabled
        sed -i -e "s/CallScreening=0/CallScreening=1/g" $MODPATH/var.prop
        print "- Enabling Call Screening & Hold for me & Direct My Call"
        print " "
        print "- Enabling Call Recording (Working is device dependent)"

        ui_print ""
        ui_print " Please Select Desired Call Screening language"
        ui_print "    Vol Up += Switch Language (change cursor position)"
        ui_print "    Vol Down +=  Select Language"
        ui_print ""

        # Give options for Call Screening language
        sleep 0.5
        lang=""
        ui_print "--------------------------------"
        ui_print " [1] English      [en]"
        ui_print " [2] Hindi        [hi-in] [BETA]"
        ui_print " [3] Japanese     [ja-JP]"
        ui_print " [4] French       [fr-FR]"
        ui_print " [5] German       [de-DE]"
        ui_print " [6] Italian      [it-IT]"
        ui_print " [7] Spanish      [es-ES]"
        ui_print "--------------------------------"

        ui_print ""
        ui_print "- Select your Desired langauge"
        ui_print ""

        SM=1
        if [ $VOL_KEYS -eq 1 ]; then
            SM=1
            TURN_OFF_SEL_VOL_PROMPT=1
            while true; do
                ui_print " Current cursor:  $SM"
                "$VKSEL" && SM="$((SM + 1))" || break
                [[ "$SM" -gt "7" ]] && SM=1
            done
        else
            SM=$(grep CALL_SCREENING_LANG= $vk_loc | cut -d= -f2)
            #print "$SM"
        fi

        # Detect country code from gsm.sim.operator.iso-country
        ISENG=0
        ISEN_US=0
        carr_coun_small="$(getprop gsm.sim.operator.iso-country)"
        if [ ! -z $(echo $carr_coun_small | grep ',') ]; then
            # if it is in format in,in then fetch first one
            carr_coun_small="$(getprop gsm.sim.operator.iso-country | cut -d, -f1)"
            if [ -z $carr_coun_small ]; then
                # if it is in format ,in then fetch first second one
                carr_coun_small="$(getprop gsm.sim.operator.iso-country | cut -d, -f2)"
            fi
        fi
        # if empty then then set to 'in'
        if [ -z $carr_coun_small ]; then
            echo " - Unable to detect Country using 'in' as default" >>$logfile
            carr_coun_small="in"
        fi
        echo " - Country code detected '$carr_coun_small'" >>$logfile

        # Patch the selected file in dialer
        sed -i -e "s/YY/${carr_coun_small}/g" $MODPATH/files/com.google.android.dialer
        P1="$(echo $carr_coun_small | xxd -p)"
        P1=${P1/0a/}
        P2=""
        case "$SM" in
        "1")
            P2="en"
            ISENG=1
            ;;
        "2")
            P2="hi-IN"
            lang="hi"
            ;;
        "3")
            P2="ja-JP"
            lang="ja"
            ;;
        "4")
            P2="fr-FR"
            lang="fr"
            ;;
        "5")
            P2="de-DE"
            lang="de"
            ;;
        "6")
            P2="it-IT"
            lang="it"
            ;;
        "7")
            P2="es-ES"
            lang="es"
            ;;
        esac

        ui_print ""
        ui_print " - Selected: $P2"
        ui_print ""

        # Options for english language
        if [ $ISENG -eq 1 ]; then
            ui_print ""
            ui_print " Please Select English Accent"
            ui_print "    Vol Up += Switch Language (change cursor position)"
            ui_print "    Vol Down +=  Select Language"
            ui_print ""

            sleep 0.5

            ui_print "--------------------------------"
            ui_print " [1] American     [en-US] "
            ui_print " [2] Indian       [en-IN] [BETA]"
            ui_print " [3] Australian   [en-AU]"
            ui_print " [4] Britain      [en-GB]"
            ui_print "--------------------------------"

            ui_print ""
            ui_print "- Select your Desired langauge:"

            if [ $VOL_KEYS -eq 1 ]; then
                SM=1
                TURN_OFF_SEL_VOL_PROMPT=1
                while true; do
                    ui_print " Current cursor:  $SM"
                    "$VKSEL" && SM="$((SM + 1))" || break
                    [[ "$SM" -gt "4" ]] && SM=1
                done
            else
                SM=$(grep ENGLISH_COUNTRY_ACCENT= $vk_loc | cut -d= -f2)
                #print "$SM"
            fi

            case "$SM" in
            "1")
                P2="en-US"
                ISEN_US=1
                ;;
            "2")
                P2="en-IN"
                lang="in"
                ;;
            "3")
                P2="en-AU"
                lang="au"
                ;;
            "4")
                P2="en-GB"
                lang="gb"
                ;;
            esac
            ui_print " - Selected: $P2 OPTION"
            ui_print ""
        fi

        # Patching starts
        TURN_OFF_SEL_VOL_PROMPT=0
        TT_LANG="$(echo $P2 | tr '[:upper:]' '[:lower:]')"
        echo " - Selected $P2 callscreening language" >>$logfile
        sed -i -e "s/UU-FF/${P2}/g" $MODPATH/files/com.google.android.dialer
        P2="$(echo $P2 | xxd -p)"
        P2=${P2/0a/}
        CSBIN=0a140a02${P1}120e0a0c0a05${P2}12030a0102
        #$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer'"
        if [ $ISEN_US -eq 1 ]; then
            print "  Do you want to enable automatic Call Screening"
            print "   Vol Up += Yes"
            print "   Vol Down += No"
            no_vk "AUTO_CALL_SCREENING"
            if $VKSEL; then
                db_edit com.google.android.dialer.directboot#com.google.android.dialer boolVal 1 45381881 45402581 45402583 45402584 45403203 45407941 45409770 45411345 45411686 45413174 45413174 45414216 45417169 45417223 45418519 45418578 45419570 45420396 45420648
                db_edit com.google.android.dialer.directboot#com.google.android.dialer boolVal 0 45411667
                db_edit com.google.android.dialer.directboot#com.google.android.dialer intVal 1 "45409315"
                db_edit com.google.android.dialer.directboot#com.google.android.dialer intVal 2 "45414559"
                #db_edit com.google.android.dialer.directboot#com.google.android.dialer stringVal "SPAM_FILTER_DISCLOSURE_17" 45399401
                #db_edit com.google.android.dialer.directboot#com.google.android.dialer stringVal "SPAM_FILTER_LEAVE_MESSAGE_DEFAULT_VARIANT" 45415110
                db_edit_bin com.google.android.dialer.directboot#com.google.android.dialer 45381883 $DOBBYCONFIG
                db_edit com.google.android.dialer.directboot#com.google.android.dialer extensionVal $DOBBYCONFIG 45381883 
                db_edit com.google.android.dialer boolVal 1 $CS_LANG
            else
                $sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot#com.google.android.dialer'"
            fi
            db_edit com.google.android.dialer boolVal 1 $CS_REV
        else
            db_edit com.google.android.dialer boolVal 1 $CS_LANG
        fi
        db_edit com.google.android.dialer floatVal "1.0" "G__call_screen_audio_stitching_downlink_volume_multiplier"
        db_edit com.google.android.dialer floatVal "0.6" "G__call_screen_audio_stitching_uplink_volume_multiplier"
        db_edit com.google.android.dialer intVal "1000" "G__embedding_generation_step_size"
        db_edit com.google.android.dialer boolVal 1 $CALL_SCREEN_FLAGS
        db_edit com.google.android.dialer boolVal 1 $DIALERFLAGS

        # $sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer' AND name='G__atlas_mdd_ph_config'"
        # $sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, extensionVal, committed) VALUES('com.google.android.dialer', '', 'G__atlas_mdd_ph_config', 0, x'$ATLASBIN', 0)"
        # $sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer' AND name='Xatu__lp_preferences'"
        # $sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, extensionVal, committed) VALUES('com.google.android.dialer', '', 'Xatu__lp_preferences', 0, x'$XATUBIN', 0)"
        # $sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer' AND name='atlas_enabled_business_number_country_codes'"
        # $sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, extensionVal, committed) VALUES('com.google.android.dialer', '', 'atlas_enabled_business_number_country_codes', 0, x'$ATSBIN', 0)"
        # db_edit_bin com.google.android.dialer G__atlas_mdd_ph_config $ATLASBIN
        # db_edit_bin com.google.android.dialer.directboot#com.google.android.dialer 45413189 $ATLASBIN
        # db_edit_bin com.google.android.dialer.directboot#com.google.android.dialer 45402582 $TKBIN
        # db_edit_bin com.google.android.dialer Xatu__lp_preferences $XATUBIN
        # db_edit_bin com.google.android.dialer atlas_enabled_business_number_country_codes $ATSBIN
        # db_edit_bin com.google.android.dialer.directboot#com.google.android.dialer 45413213 $ATSBIN
        # db_edit_bin com.google.android.dialer Revelio__supported_voices $REVBIN
        # [ $ISEN_US -eq 0 ] && db_edit_bin com.google.android.dialer CallScreenI18n__call_screen_i18n_config $CSBIN
        # db_edit_bin com.google.android.dialer G__tk_mdd_ph_config $TKBIN
        # db_edit_bin com.google.android.dialer model_download_group_config $XATUCONFIGBIN
        # db_edit_bin com.google.android.dialer.directboot#com.google.android.dialer 45417183 $XATUCONFIGBIN
        db_edit com.google.android.dialer extensionVal G__atlas_mdd_ph_config $ATLASBIN
        db_edit com.google.android.dialer.directboot#com.google.android.dialer extensionVal 45413189 $ATLASBIN
        db_edit com.google.android.dialer.directboot#com.google.android.dialer extensionVal 45402582 $TKBIN
        db_edit com.google.android.dialer extensionVal Xatu__lp_preferences $XATUBIN
        db_edit com.google.android.dialer extensionVal atlas_enabled_business_number_country_codes $ATSBIN
        db_edit com.google.android.dialer.directboot#com.google.android.dialer extensionVal 45413213 $ATSBIN
        db_edit com.google.android.dialer extensionVal Revelio__supported_voices $REVBIN
        [ $ISEN_US -eq 0 ] && db_edit com.google.android.dialer extensionVal CallScreenI18n__call_screen_i18n_config $CSBIN
        db_edit com.google.android.dialer extensionVal G__tk_mdd_ph_config $TKBIN
        db_edit com.google.android.dialer extensionVal model_download_group_config $XATUCONFIGBIN
        db_edit com.google.android.dialer.directboot#com.google.android.dialer extensionVal 45417183 $XATUCONFIGBIN
        # Patching Ends

        # Install language pack
        if [ ! -z $lang ]; then
            if [ -f /sdcard/Pixelify/backup/callscreen-$lang.tar.xz ]; then
                print "- Installing CallScreening $lang from backups"
                print ""
                mkdir -p $MODPATH/system/product/tts/google
                tar -xf /sdcard/Pixelify/backup/callscreen-$lang.tar.xz -C $MODPATH/system/product/tts/google
                #install TTS Pack
                if [ -d /data/user_de/0/com.google.android.tts ] && [[ $lang == "hi-IN" || $lang == "en-IN" ]]; then
                    TTS_LOC=/data/user_de/0/com.google.android.tts/files/superpacks/$TT_LANG
                    [ ! -d $TTS_LOC ] && mkdir -p $TTS_LOC
                    PACK_NAME="1#"
                    if [ -z "$(ls $TTS_LOC)" ]; then
                        cd $MODPATH/system/product/tts/google/$TT_LANG
                        for i in $(ls); do
                            j=${i/.zvoice/}
                            r="$(echo $j | tr -dc '0-9')"
                            PACK_NAME="$PACK_NAME$TT_LANG:$j;$r,"
                            mkdir -p $TTS_LOC/$j
                            unzip -q $i -d $TTS_LOC/$j
                        done
                        cd /
                        PACK_NAME=${PACK_NAME::-1}
                        SS="$("$sqlite" "/data/user_de/0/com.google.android.tts/databases/superpacks.db" "SELECT superpack_name FROM selected_packs")"
                        if [ -z $(echo "$SS" | grep $TT_LANG) ]; then
                            "$sqlite" "/data/user_de/0/com.google.android.tts/databases/superpacks.db" "INSERT INTO selected_packs(superpack_name, superpack_version, pack_list) VALUES('$TT_LANG', '$r', '$PACK_NAME')"
                        fi
                    fi
                fi
            else
                CRSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/callscreen-$lang.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
                print "  (Network Connection Needed)"
                print "  Do you want to Download Call Screening files for '$lang' language"
                print "  Size: $CRSIZE"
                print "   Vol Up += Yes"
                print "   Vol Down += No"
                no_vk "ADD_CALL_SCREENING_FILES"
                if $VKSEL; then
                    online
                    if [ $internet -eq 1 ]; then
                        echo " - Downloading CallScreening files for '$lang'" >>$logfile
                        print "  Downloading CallScreening files for '$lang'"
                        mkdir -p $MODPATH/system/product/tts/google
                        cd $MODPATH/files
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/callscreen-$lang.tar.xz -O &>/proc/self/fd/$OUTFD
                        cd /
                        tar -xf $MODPATH/files/callscreen-$lang.tar.xz -C $MODPATH/system/product/tts/google
                        #install TTS Pack
                        if [ -d /data/user_de/0/com.google.android.tts ] && [[ $lang == "hi-IN" || $lang == "en-IN" ]]; then
                            TTS_LOC=/data/user_de/0/com.google.android.tts/files/superpacks/$TT_LANG
                            [ ! -d $TTS_LOC ] && mkdir -p $TTS_LOC
                            PACK_NAME="1#"
                            if [ -z "$(ls $TTS_LOC)" ]; then
                                cd $MODPATH/system/product/tts/google/$TT_LANG
                                for i in $(ls); do
                                    j=${i/.zvoice/}
                                    r="$(echo $j | tr -dc '0-9')"
                                    PACK_NAME="$PACK_NAME$TT_LANG:$j;$r,"
                                    mkdir -p $TTS_LOC/$j
                                    unzip -q $i -d $TTS_LOC/$j
                                done
                                cd /
                                PACK_NAME=${PACK_NAME::-1}
                                SS="$("$sqlite" "/data/user_de/0/com.google.android.tts/databases/superpacks.db" "SELECT superpack_name FROM selected_packs")"
                                if [ -z $(echo "$SS" | grep $TT_LANG) ]; then
                                    "$sqlite" "/data/user_de/0/com.google.android.tts/databases/superpacks.db" "INSERT INTO selected_packs(superpack_name, superpack_version, pack_list) VALUES('$TT_LANG', '$r', '$PACK_NAME')"
                                fi
                            fi
                        fi
                        print ""
                        print "  Do you want to create backup of CallScreening files for '$lang'"
                        print "  so that you don't need redownload it every time."
                        print "   Vol Up += Yes"
                        print "   Vol Down += No"
                        no_vk "BACKUP_CALL_SCREENING_FILES"
                        if $VKSEL; then
                            echo " - Creating backup for CallScreening files for '$lang'" >>$logfile
                            print "- Creating Backup"
                            mkdir -p /sdcard/Pixelify/backup
                            rm -rf /sdcard/Pixelify/backup/callscreen-$lang.tar.xz
                            cp -f $MODPATH/files/callscreen-$lang.tar.xz /sdcard/Pixelify/backup/callscreen-$lang.tar.xz
                            print ""
                        fi
                    else
                        print " ! No internet detected"
                        print ""
                        print "- Skipping CallScreening Resources."
                        print ""
                        echo " - skipping CallScreening Resources due to no internet" >>$logfile
                    fi
                else
                    echo " - skipping CallScreening Resources" >>$logfile
                fi
            fi
        fi

        # Remove old prompt to replace to use within overlay
        rm -rf /data/data/com.google.android.dialer/files/callrecordingprompt/*
        mkdir -p /data/data/com.google.android.dialer/files/callrecordingprompt
        cp -r $MODPATH/files/callrec/* /data/data/com.google.android.dialer/files/callrecordingprompt

        # Updated patched com.google.android.dialer
        # mkdir -p /data/data/com.google.android.dialer/files/phenotype
        # chmod 0500 /data/data/com.google.android.dialer/files/phenotype
        # cp -Tf $MODPATH/files/$DIALER $MODPATH/$DIALER
        # chmod 0660 /data/data/com.google.android.dialer/files/phenotype/com.google.android.dialer
        # am force-stop $DIALER

        # make Google dialer as system app
        if [ -z $(pm list packages -s $DIALER) ] && [ ! -f /data/adb/modules/Pixelify/system/product/priv-app/GoogleDialer/GoogleDialer.apk ]; then
            print ""
            print "- Google Dialer is not installed as a system app !!"
            print "- Making Google Dialer a system app"
            echo " - Making Google Dialer a system app" >>$logfile
            print ""
            cp -r $app/com.google.android.dialer*/. $MODPATH/system$product/priv-app/GoogleDialer
            mv $MODPATH/system$product/priv-app/GoogleDialer/base.apk $MODPATH/system$product/priv-app/GoogleDialer/GoogleDialer.apk
            rm -rf $MODPATH/system$product/priv-app/GoogleDialer/oat
        # Remake google dialer as system app if Pixelify made it system app
        elif [ -f /data/adb/modules/Pixelify/system$product/priv-app/GoogleDialer/GoogleDialer.apk ]; then
            print ""
            print "- Google Dialer is not installed as a system app !!"
            print "- Making Google Dialer a system app"
            echo " - Making Google Dialer a system app" >>$logfile
            print ""
            cp -r $app/com.google.android.dialer*/. $MODPATH/system$product/priv-app/GoogleDialer
            mv $MODPATH/system$product/priv-app/GoogleDialer/base.apk $MODPATH/system$product/priv-app/GoogleDialer/GoogleDialer.apk
            rm -rf $MODPATH/system$product/priv-app/GoogleDialer/oat
        fi

        # Show option to remove Samsung dialer for OneUi users have android version greater than equal to Android S
        [ ! -z "$(getprop ro.oneui.version)" ] && [ $API -ge 31 ] && remove_samsung_dialer
    else
        # Remove Google dialer files if user doesn't want to enable it
        rm -rf $MODPATH/system$product/overlay/PixelifyGD.apk
        chmod 755 /data/data/com.google.android.dialer/files/phenotype
        sed -i -e "s/cp -Tf $MODDIR\/com.google.android.dialer/#cp -Tf $MODDIR\/com.google.android.dialer/g" $MODPATH/service.sh
        sed -i -e "s/chmod 500 \/data\/data\/com.google.android.dialer\/files\/phenotype/#chmod 500 \/data\/data\/com.google.android.dialer\/files\/phenotype/g" $MODPATH/service.sh
    fi
else
    # Remove Google dialer files if user doesn't want to enable it
    chmod 755 /data/data/com.google.android.dialer/files/phenotype
    sed -i -e "s/cp -Tf $MODDIR\/com.google.android.dialer/#cp -Tf $MODDIR\/com.google.android.dialer/g" $MODPATH/service.sh
    sed -i -e "s/chmod 500 \/data\/data\/com.google.android.dialer\/files\/phenotype/#chmod 500 \/data\/data\/com.google.android.dialer\/files\/phenotype/g" $MODPATH/service.sh
    rm -rf $MODPATH/system$product/overlay/PixelifyGD.apk
fi

# Next Generation assistant installation
if [ -d /data/data/com.google.android.googlequicksearchbox ] && [ $API -ge 29 ] && [ $TARGET_DEVICE_ONEUI -eq 0 ]; then
    print "  Google is installed."
    print "  Do you want to installed Next generation assistant?"
    print "   Vol Up += Yes"
    print "   Vol Down += No"
    no_vk "ENABLE_NGA"
    if $VKSEL; then
        echo " - Installing Next generation assistant" >>$logfile
        # Check backup is present ot not, older Pixelify uses NgaResources.apk and new ones nga.tar.xz
        if [ -f /sdcard/Pixelify/backup/nga.tar.xz ] || [ -f /sdcard/Pixelify/backup/NgaResources.apk ]; then

            # Check backup is upto date
            if [ "$(cat /sdcard/Pixelify/version/nga.txt)" != "$NGAVERSION" ]; then
                echo " - New Version Detected for NGA Resources" >>$logfile
                echo " - Installed version: $(cat /sdcard/Pixelify/version/nga.txt) , New Version: $NGAVERSION " >>$logfile
                print "  (Network Connection Needed)"
                print "  New version Detected."
                print "  Do you Want to update or use Old Backup?"
                print "  Version: $NGAVERSION"
                print "  Size: $NGASIZE"
                print "   Vol Up += Update"
                print "   Vol Down += Use old backup"
                no_vk "UPDATE_NGA_RES"
                if $VKSEL; then
                    # check internet is avail or not
                    online
                    if [ $internet -eq 1 ]; then
                        echo " - Downloading, Installing and creating backup NGA Resources" >>$logfile
                        rm -rf /sdcard/Pixelify/backup/NgaResources.apk
                        rm -rf /sdcard/Pixelify/backup/nga.tar.xz
                        rm -rf /sdcard/Pixelify/version/nga.txt
                        cd $MODPATH/files
                        # Download version according to variables
                        # OSR with Offline Speech Recogonition 50xx
                        # DOES_NOT_REQ_SPEECH_PACK to forcelly disable with speechpack one only NGA Resources
                        if [ $ENABLE_OSR -eq 1 ] || [ $DOES_NOT_REQ_SPEECH_PACK -eq 1 ]; then
                            if [ $API -eq 30 ] || [ $API -eq 33 ]; then
                                $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/nga-new-$API.tar.xz -o nga.tar.xz &>/proc/self/fd/$OUTFD
                            else
                                $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/nga-new-31.tar.xz -o nga.tar.xz &>/proc/self/fd/$OUTFD
                            fi
                        else
                            $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/nga.tar.xz -o nga.tar.xz &>/proc/self/fd/$OUTFD
                        fi
                        cd /
                        # Create backup
                        print ""
                        print "- Creating Backup"
                        print ""
                        cp -Tf $MODPATH/files/nga.tar.xz /sdcard/Pixelify/backup/nga.tar.xz
                        echo "$NGAVERSION" >>/sdcard/Pixelify/version/nga.txt
                    else
                        # No internet dected
                        print " ! No internet detected"
                        print ""
                        print " ! Using Old backup for now."
                        print ""
                        echo " ! using old backup for NGA Resources due to no internet" >>$logfile
                    fi
                else
                    echo " - using old backup for NGA Resources" >>$logfile
                fi
            fi
            print "- Installing NgaResources from backups"
            print ""
            # Extract nga.tar.xz
            tar -xf /sdcard/Pixelify/backup/nga.tar.xz -C $MODPATH/system/product
        else
            print "  (Network Connection Needed)"
            print "  Do you want to install and Download NGA Resources"
            print "  Size: $NGASIZE"
            print "   Vol Up += Yes"
            print "   Vol Down += No"
            no_vk "DOWNLOAD_NGA_RES"
            if $VKSEL; then
                online
                if [ $internet -eq 1 ]; then
                    echo " - Downloading and Installing NGA Resources" >>$logfile
                    print " - Downloading NGA Resources"
                    cd $MODPATH/files
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/nga-new.tar.xz -o nga.tar.xz -O &>/proc/self/fd/$OUTFD
                    cd /
                    tar -xf $MODPATH/files/nga.tar.xz -C $MODPATH/system/product
                    print ""
                    print "  Do you want to create backup of NGA Resources"
                    print "  so that you don't need redownload it every time."
                    print "   Vol Up += Yes"
                    print "   Vol Down += No"
                    no_vk "BACKUP_NGA"
                    if $VKSEL; then
                        echo " - Creating backup for NGA Resources" >>$logfile
                        print "- Creating Backup"
                        mkdir -p /sdcard/Pixelify/backup
                        rm -rf /sdcard/Pixelify/backup/NgaResources.apk
                        rm -rf /sdcard/Pixelify/backup/nga.tar.xz
                        cp -f $MODPATH/files/nga.tar.xz /sdcard/Pixelify/backup/nga.tar.xz
                        mkdir -p /sdcard/Pixelify/version
                        echo "$NGAVERSION" >>/sdcard/Pixelify/version/nga.txt
                        print ""
                        print "- NGA Resources installation complete"
                        print ""
                    fi
                else
                    print " ! No internet detected"
                    print ""
                    print "- Skipping NGA Resources."
                    print ""
                    echo " - skipping NGA Resources due to no internet" >>$logfile
                fi
            else
                echo " - skipping NGA Resources" >>$logfile
            fi
        fi

        # Patching starts
        db_edit com.google.android.googlequicksearchbox stringVal "Cheetah" "13477"
        #db_edit com.google.android.googlequicksearchbox boolVal 1  10579 11627 14759 15114 16197 16347 16464 45351462 45352335 45353388 45353425 45354090 45355242 45355425 45357281 45357460 45357462 45357463 45357466 45357467 45357468 45357469 45357470 45357471 45357508 45358425 45368123 45368150 45368483 45374247 45375269 45386105 8674 9449 10596 3174 45357539 45358426 45360742 45372547 45372935 45373820 45374858 45376106 45380073 45380867 45385075 45385287 45386702 7882 8932 9418
        [ $TENSOR -eq 0 ] && db_edit_bin com.google.android.googlequicksearchbox 5470 $GOOGLEBIN
        db_edit com.google.android.libraries.search.googleapp.device#com.google.android.googlequicksearchbox boolVal 1 45410632 45410315 45369077
        db_edit com.google.android.apps.search.assistant.device#com.google.android.googlequicksearchbox extensionVal 45377874 $GSPOOF
        #sed -i -e 's/com.google.android.feature.PIXEL_2021_EXPERIENCE/com.google.android.feature.PIXEL_2019_EXPERIENCE/g' $VELVET_APK
        #am force-stop com.google.android.googlequicksearchbox
        #$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.g10040oogle.android.googlequicksearchbox' AND name='5470'"
        #$sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, extensionVal, committed) VALUES('com.google.android.googlequicksearchbox', '', '5470', 0, x'$GOOGLEBIN', 0)"
        # Patching ends

        # copy NGA files
        cp -f $MODPATH/files/nga.xml $MODPATH/system$product/etc/sysconfig/nga.xml
        cp -f $MODPATH/files/PixelifyGA.apk $MODPATH/system/product/overlay/PixelifyGA.apk
        # ok_google_hotword
        if [ $ENABLE_OSR -eq 1 ]; then
            osr_ins
        fi

        # Option to make Google app as system app or not forcely
        # in /sdcard/Pixelify/apps.txt add velet=1
        if [ -f $FORCE_FILE ]; then
            is_velvet="$(grep velvet= $FORCE_FILE | cut -d= -f2)"
            if [ $is_velvet -eq 1 ]; then
                FORCE_VELVET=1
            elif [ $is_velvet -eq 0 ]; then
                FORCE_VELVET=0
            else
                FORCE_VELVET=2
            fi
        else
            FORCE_VELVET=2
        fi

        # Make Google app as system app
        if [ -z $(pm list packages -s com.google.android.googlequicksearchbox | grep -v nga) ] && [ ! -f /data/adb/modules/Pixelify/system/product/priv-app/Velvet/Velvet.apk ] || [ $FORCE_VELVET -eq 1 ]; then
            print "- Google is not installed as a system app !!"
            print "- Making Google a system app"
            echo " - Making Google a system app" >>$logfile
            print ""
            if [ -f $app/com.google.android.googlequicksearchbox*/base.apk ]; then
                cp -r $app/com.google.android.googlequicksearchbox*/. $MODPATH/system/product/priv-app/Velvet
                mv $MODPATH/system/product/priv-app/Velvet/base.apk $MODPATH/system/product/priv-app/Velvet/Velvet.apk
            else
                cp -r /data/adb/modules/Pixelify/system$product/priv-app/Velvet/. $MODPATH/system$product/priv-app/Velvet
            fi
            rm -rf $MODPATH/system/product/priv-app/Velvet/oat
            #mv $MODPATH/files/privapp-permissions-com.google.android.googlequicksearchbox.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.googlequicksearchbox.xml

        # If Pixelify made system app then remake it
        elif [ -f /data/adb/modules/Pixelify/system/product/priv-app/Velvet/Velvet.apk ]; then
            if [ $FORCE_VELVET -eq 2 ]; then
                print "- Google is not installed as a system app !!"
                print "- Making Google a system app"
                echo " - Making Google a system app" >>$logfile
                print ""
                if [ -f $app/com.google.android.googlequicksearchbox*/base.apk ]; then
                    cp -r $app/com.google.android.googlequicksearchbox*/. $MODPATH/system/product/priv-app/Velvet
                    mv $MODPATH/system/product/priv-app/Velvet/base.apk $MODPATH/system/product/priv-app/Velvet/Velvet.apk
                else
                    cp -r data/adb/modules/Pixelify/system$product/priv-app/Velvet/. $MODPATH/system$product/priv-app/Velvet
                fi
                rm -rf $MODPATH/system/product/priv-app/Velvet/oat
            fi
            #mv $MODPATH/files/privapp-permissions-com.google.android.googlequicksearchbox.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.googlequicksearchbox.xml
        fi
    fi
fi

# Pixel Wallpapers
if [ $API -ge 28 ]; then
    PLW=$(find /system -name *PixelWallpapers2021* | grep -v overlay | grep -v "\.")
    PLW1=$(find /system -name *WallpapersBreel2* | grep -v overlay | grep -v "\.")
    if [ -f /sdcard/Pixelify/backup/pixel.tar.xz ]; then
        echo " - Backup Detected for Pixel Wallpapers" >>$logfile
        print "  Do you want to install Pixel Live Wallpapers?"
        print "  (Backup detected, no internet needed)"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        no_vk "ENABLE_LIVE_WALLPAPERS"
        if $VKSEL; then
            sed -i -e "s/Live=0/Live=1/g" $MODPATH/var.prop
            if [ "$(cat /sdcard/Pixelify/version/pixel.txt)" != "$LWVERSION" ]; then
                echo " - New Version Backup Detected for Pixel Wallpapers" >>$logfile
                echo " - Old version:$(cat /sdcard/Pixelify/version/pixel.txt), New Version:  $LWVERSION " >>$logfile
                print "  (Network Connection Needed)"
                print "  New version Detected "
                print "  Do you Want to update or use Old Backup?"
                print "  Version: $LWVERSION"
                print "  Size: $LWSIZE"
                print "   Vol Up += Update"
                print "   Vol Down += Use old backup"
                no_vk "DOWNLOAD_LIVE_WALLPAPERS"
                if $VKSEL; then
                    online
                    if [ $internet -eq 1 ]; then
                        echo " - Downloading and Installing New Backup for Pixel Wallpapers" >>$logfile
                        rm -rf /sdcard/Pixelify/backup/pixel.tar.xz
                        rm -rf /sdcard/Pixelify/version/pixel.txt
                        cd $MODPATH/files
                        if [ $API -ge 31 ]; then
                            $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pixel.tar.xz -O &>/proc/self/fd/$OUTFD
                        else
                            $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pixel-old.tar.xz -O &>/proc/self/fd/$OUTFD
                            mv pixel-old.tar.xz pixel.tar.xz
                        fi
                        cd /
                        print "- Creating Backup"
                        print ""
                        cp -f $MODPATH/files/pixel.tar.xz /sdcard/Pixelify/backup/pixel.tar.xz
                        echo " - Creating Backup for Pixel Wallpapers" >>$logfile
                        echo "$LWVERSION" >>/sdcard/Pixelify/version/pixel.txt
                    else
                        print " ! No internet detected"
                        print ""
                        print " ! Using Old backup for now."
                        print ""
                        echo " ! Using old Backup for Pixel Wallpapers due to no internet" >>$logfile
                    fi
                fi
            fi
            print "- Installing Pixel LiveWallpapers"
            print ""
            tar -xf /sdcard/Pixelify/backup/pixel.tar.xz -C $MODPATH/system$product
            pm install $MODPATH/system$product/priv-app/PixelLiveWallpaperPrebuilt/*.apk &>/dev/null

            if [ $API -le 28 ]; then
                mv $MODPATH/system/overlay/Breel*.apk $MODPATH/vendor/overlay
                rm -rf $MODPATH/system/overlay
            fi
            REMOVE="$REMOVE $PLW $PLW1"
            pm enable -n com.google.pixel.livewallpaper/com.google.pixel.livewallpaper.pokemon.wallpapers.PokemonWallpaper -a android.intent.action.MAIN &>/dev/null
            mkdir -p $MODPATH/system$product/app/WallpapersBReel2020/lib/arm64
            cp -f $MODPATH/system$product/lib64/libgdx.so $MODPATH/system$product/app/WallpapersBReel2020/lib/arm64/libgdx.so
            install_wallpaper_with_backup
            WALL_DID=1
        else
            echo " - Using old backup Pixel Wallpapers" >>$logfile
        fi
    else
        print "  (Network Connection Needed)"
        print "  Do you want to install and Download Pixel LiveWallpapers?"
        print "  Size: $LWSIZE"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        no_vk "ENABLE_LIVE_WALLPAPERS"
        if $VKSEL; then
            online
            if [ $internet -eq 1 ]; then
                sed -i -e "s/Live=0/Live=1/g" $MODPATH/var.prop
                print "- Downloading Pixel LiveWallpapers"
                echo " - Downloading and Installing Pixel Wallpapers" >>$logfile
                print ""
                cd $MODPATH/files
                if [ $API -ge 31 ]; then
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pixel.tar.xz -O &>/proc/self/fd/$OUTFD
                else
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pixel-old.tar.xz -O &>/proc/self/fd/$OUTFD
                    mv pixel-old.tar.xz pixel.tar.xz
                fi
                cd /
                print ""
                print "- Installing Pixel Live Wallpapers"
                tar -xf $MODPATH/files/pixel.tar.xz -C $MODPATH/system$product
                pm install $MODPATH/system$product/priv-app/PixelLiveWallpaperPrebuilt/*.apk &>/dev/null

                if [ $API -le 28 ]; then
                    mv $MODPATH/system/overlay/Breel*.apk $MODPATH/vendor/overlay
                    rm -rf $MODPATH/system/overlay
                fi
                print ""
                print "  Do you want to create backup of Pixel LiveWallpapers?"
                print "  so that you don't need redownload it every time."
                print "   Vol Up += Yes"
                print "   Vol Down += No"
                no_vk "BACKUP_LIVE_WALLPAPERS"
                if $VKSEL; then
                    print "- Creating Backup"
                    mkdir -p /sdcard/Pixelify/backup
                    rm -rf /sdcard/Pixelify/backup/pixel.tar.xz
                    cp -f $MODPATH/files/pixel.tar.xz /sdcard/Pixelify/backup/pixel.tar.xz
                    print ""
                    mkdir /sdcard/Pixelify/version
                    echo " - Creating Backup for Pixel Wallpapers" >>$logfile
                    echo "$LWVERSION" >>/sdcard/Pixelify/version/pixel.txt
                    print " - Done"
                    print ""
                fi
                REMOVE="$REMOVE $PLW $PLW1"
                pm enable -n com.google.pixel.livewallpaper/com.google.pixel.livewallpaper.pokemon.wallpapers.PokemonWallpaper -a android.intent.action.MAIN &>/dev/null
                mkdir -p $MODPATH/system$product/app/WallpapersBReel2020/lib/arm64
                cp -f $MODPATH/system$product/lib64/libgdx.so $MODPATH/system$product/app/WallpapersBReel2020/lib/arm64/libgdx.so
                install_wallpaper_with_backup
                WALL_DID=1
            else
                print " ! No internet detected"
                print ""
                print " ! Skipping Pixel LiveWallpaper"
                print ""
                echo " ! Skipping Pixel Wallpapers due to no internet" >>$logfile
            fi
        else
            echo " - Skipping Pixel Wallpapers" >>$logfile
        fi
    fi
fi

# Enable using monet bootanimation as they have themed_bootanimation function
[ $API -ge 32 ] && MONET_BOOTANIMATION=1

# checking Monet is supported or not
is_monet

# Pixel bootanimation
if [ $TARGET_DEVICE_OP12 -eq 0 ]; then
    print "  Do you want to install Pixel Bootanimation?"
    print "   Vol Up += Yes"
    print "   Vol Down += No"
    no_vk "ENABLE_BOOTANIMATION"
    if $VKSEL; then
        echo " - Installing Pixel Bootanimation" >>$logfile
        if [ -f /system/media/bootanimation.zip ]; then
            MEDIA_PATH=system/media
        else
            MEDIA_PATH=system/product/media
        fi
        boot_res=$(unzip -p /$MEDIA_PATH/bootanimation.zip desc.txt | head -n 1 | cut -d' ' -f1)
        if [ ! -z "$boot_res" ]; then
            print " - Detected $boot_res Resolution Bootanimation"
        else
            print " ! Failed to detect Resolution of Bootanimation"
        fi
        print ""
        mkdir -p $MODPATH/$MEDIA_PATH
        if [ $MONET_BOOTANIMATION -eq 0 ]; then
            case "$boot_res" in
            720)
                tar -xf $MODPATH/files/bootanimation-720.tar.xz -C $MODPATH/$MEDIA_PATH
                print " - Using 720p resolution pixel Bootanimation"
                ;;
            1440)
                tar -xf $MODPATH/files/bootanimation-1440.tar.xz -C $MODPATH/$MEDIA_PATH
                print " - Using 1440p resolution pixel Bootanimation"
                ;;
            *)
                tar -xf $MODPATH/files/bootanimation.tar.xz -C $MODPATH/$MEDIA_PATH
                print " - Using 1080p resolution pixel Bootanimation"
                ;;
            esac
            print ""
            if [ ! -f /system/bin/themed_bootanimation ]; then
                rm -rf $MODPATH/$MEDIA_PATH/bootanimation.zip
                cp -f $MODPATH/$MEDIA_PATH/bootanimation-dark.zip $MODPATH/$MEDIA_PATH/bootanimation.zip
                echo " - Themed Animation not detected, using dark animation as default" >>$logfile
            fi
        else
            case "$boot_res" in
            720)
                tar -xf $MODPATH/files/bootanimation-m-720.tar.xz -C $MODPATH/$MEDIA_PATH
                print " - Using 720p resolution pixel Bootanimation"
                ;;
            1440)
                tar -xf $MODPATH/files/bootanimation-m-1440.tar.xz -C $MODPATH/$MEDIA_PATH
                print " - Using 1440p resolution pixel Bootanimation"
                ;;
            *)
                tar -xf $MODPATH/files/bootanimation-m.tar.xz -C $MODPATH/$MEDIA_PATH
                print " - Using 1080p resolution pixel Bootanimation"
                ;;
            esac
            print ""
            cp -f $MODPATH/$MEDIA_PATH/bootanimation.zip $MODPATH/$MEDIA_PATH/bootanimation-dark.zip
        fi
    else
        echo " - Skipping Pixel Bootanimation" >>$logfile
        rm -rf $MODPATH/system$product/media/boot*.zip
    fi
else
    rm -rf $MODPATH/system$product/media/boot*.zip
fi

# Pixel Launcher
if [ $API -ge 29 ]; then
    PL=$(find /system -name *Launcher* | grep -v overlay | grep -v Nexus | grep -v bin | grep -v "\.")
    TR=$(find /system -name *Trebuchet* | grep -v overlay | grep -v "\.")
    QS=$(find /system -name *QuickStep* | grep -v overlay | grep -v "\.")
    LW=$(find /system -name *MiuiHome* | grep -v overlay | grep -v "\.")
    TW=$(find /system -name *TouchWizHome* | grep -v overlay | grep -v "\.")
    KW=$(find /system -name *Lawnchair* | grep -v overlay | grep -v "\.")

    if [ -f /sdcard/Pixelify/backup/pl-$API.tar.xz ]; then
        echo " - Backup Detected for Pixel Launcher" >>$logfile
        print "  Do you want to install Pixel Launcher?"
        print "  (Backup detected, no internet needed)"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        no_vk "ENABLE_PIXEL_LAUNCHER"
        if $VKSEL; then
            REMOVE="$REMOVE $PL $TR $QS $LW $TW $KW"
            cp -f $MODPATH/files/PixelifyPixelLauncherCustomOverlay.apk $MODPATH/system/product/overlay/PixelifyPixelLauncherCustomOverlay.apk
            if [ "$(cat /sdcard/Pixelify/version/pl-$API.txt)" != "$PLVERSION" ]; then
                echo " - New Version Backup Detected for Pixel Launcher" >>$logfile
                echo " - Old version:$(cat /sdcard/Pixelify/version/pl-$API.txt), New Version:  $PLVERSION " >>$logfile
                print "  (Network Connection Needed)"
                print "  New version Detected "
                print "  Do you Want to update or use Old Backup?"
                print "  Version: $PLVERSION"
                print "  Size: $PLSIZE"
                print "   Vol Up += Update"
                print "   Vol Down += Use old backup"
                no_vk "UPDATE_PIXEL_LAUNCHER"
                if $VKSEL; then
                    online
                    if [ $internet -eq 1 ]; then
                        echo " - Downloading and Installing New Backup for Pixel Launcher" >>$logfile
                        rm -rf /sdcard/Pixelify/backup/pl-$API.tar.xz
                        rm -rf /sdcard/Pixelify/version/pl-$API.txt
                        cd $MODPATH/files
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/PixelLauncher/$API/$PL_VERSION.tar.xz -O &>/proc/self/fd/$OUTFD
                        mv $PL_VERSION.tar.xz pl-$API.tar.xz
                        cd /
                        print "- Creating Backup"
                        print ""
                        cp -f $MODPATH/files/pl-$API.tar.xz /sdcard/Pixelify/backup/pl-$API.tar.xz
                        echo " - Creating Backup for Pixel Launcher" >>$logfile
                        echo "$PLVERSION" >>/sdcard/Pixelify/version/pl-$API.txt
                    else
                        print " ! No internet detected"
                        print ""
                        print " ! Using Old backup for now."
                        print ""
                        echo " ! Using old Backup for Pixel Launcher due to no internet" >>$logfile
                    fi
                fi
            fi
            print "- Installing Pixel Launcher"
            print ""
            pl_fix

            if [ $API -ge 31 ]; then
                tar -xf /sdcard/Pixelify/backup/pl-$API.tar.xz -C $MODPATH/system$product
            else
                tar -xf /sdcard/Pixelify/backup/pl-$API.tar.xz -C $MODPATH/system$product/priv-app
            fi

            if [ $WALL_DID -eq 0 ]; then
                install_wallpaper_with_backup
            fi
        else
            echo " - Skipping Pixel Launcher" >>$logfile
            rm -rf $MODPATH/system/product/overlay/PixelLauncherOverlay.apk
            rm -rf $MODPATH/system/product/overlay/Pixelifyroundshape.apk
        fi
    else
        print "  (Network Connection Needed)"
        print "  Do you want to install and Download Pixel Launcher?"
        print "  Size: $PLSIZE"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        no_vk "ENABLE_PIXEL_LAUNCHER"
        if $VKSEL; then
            online
            if [ $internet -eq 1 ]; then
                print "- Downloading Pixel Launcher"
                echo " - Downloading and Installing Pixel Launcher" >>$logfile
                print ""
                cd $MODPATH/files
                $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/PixelLauncher/$API/$PL_VERSION.tar.xz -O &>/proc/self/fd/$OUTFD
                mv $PL_VERSION.tar.xz pl-$API.tar.xz
                cd /
                print ""
                print "- Installing Pixel Launcher"
                if [ $API -ge 31 ]; then
                    tar -xf $MODPATH/files/pl-$API.tar.xz -C $MODPATH/system$product
                else
                    tar -xf $MODPATH/files/pl-$API.tar.xz -C $MODPATH/system$product/priv-app
                fi
                pl_fix
                REMOVE="$REMOVE $PL $TR $QS $LW $TW $KW"
                print ""
                print "  Do you want to create backup of Pixel Launcher?"
                print "  so that you don't need redownload it every time."
                print "   Vol Up += Yes"
                print "   Vol Down += No"
                no_vk "BACKUP_PIXEL_LAUNCHER"
                if $VKSEL; then
                    print "- Creating Backup"
                    mkdir -p /sdcard/Pixelify/backup
                    rm -rf /sdcard/Pixelify/backup/pl-$API.tar.xz
                    cp -f $MODPATH/files/pl-$API.tar.xz /sdcard/Pixelify/backup/pl-$API.tar.xz
                    print ""
                    mkdir -p /sdcard/Pixelify/version
                    echo " - Creating Backup for Pixel Launcher" >>$logfile
                    echo "$PLVERSION" >>/sdcard/Pixelify/version/pl-$API.txt
                    print " - Done"
                    print ""
                fi

                if [ $WALL_DID -eq 0 ]; then
                    install_wallpaper_with_backup
                fi
            else
                print " ! No internet detected"
                print ""
                print " ! Skipping Pixel launcher"
                print ""
                echo " ! Skipping Pixel Launcher due to no internet" >>$logfile
                rm -rf $MODPATH/system/product/overlay/PixelLauncherOverlay.apk
                rm -rf $MODPATH/system/product/overlay/Pixelifyroundshape.apk
            fi
        else
            echo " - Skipping Pixel Launcher" >>$logfile
            rm -rf $MODPATH/system/product/overlay/PixelLauncherOverlay.apk
            rm -rf $MODPATH/system/product/overlay/Pixelifyroundshape.apk
        fi
    fi
else
    echo " - Skipping Pixel Launcher" >>$logfile
    rm -rf $MODPATH/system/product/overlay/PixelLauncherOverlay.apk
    rm -rf $MODPATH/system/product/overlay/Pixelifyroundshape.apk
fi

#Adding Google san font.
print ""
#print "  (NOTE: Playstore or Google or GMS crashes then dont enable it)"
print "  Do you want add Google San Fonts?"
print "    Vol Up += Yes"
print "    Vol Down += No"
no_vk "GSAN_FONT"
if $VKSEL; then
    patch_font
else
    rm -rf $MODPATH/system/product/overlay/PixelifyGsan*.apk
    rm -rf $MODPATH/system/product/overlay/GInterOverlay.apk
fi
# rm -rf $MODPATH/system/product/overlay/PixelifyGsan*.apk
# rm -rf $MODPATH/system/product/overlay/GInterOverlay.apk
# rm -rf $MODPATH/system/fonts

# Google Settings service
if [ $API -ge 28 ] && [ $TARGET_DEVICE_OP12 -eq 0 ]; then
    print "  Do you want to install Google settings service?"
    # print "  (Battery Widget)"
    print "    Vol Up += Yes"
    print "    Vol Down += No"
    no_vk "ENABLE_GSI"
    if $VKSEL; then
        SI=$(find /system -name *SettingsIntelligence* | grep -v overlay | grep -v "\.")
        db_edit com.google.android.settings.intelligence boolVal 1 $GSS_FLAGS
        tar -xf $MODPATH/files/sig.tar.xz -C $MODPATH/system$product/priv-app
        # cp -f $MODPATH/files/PixelifySettingsIntelligenceGoogleOverlay.apk $MODPATH/system/product/overlay/PixelifySettingsIntelligenceGoogleOverlay.apk
        # REMOVE="$REMOVE $SI"
    else
        echo " - Skipping Google settings intelligence" >>$logfile
    fi
fi

# Extreme battery Saver
if [ $API -ge 30 ]; then
    print "  Do you want to install Extreme Battery Saver (Flipendo)?"
    print "    Vol Up += Yes"
    print "    Vol Down += No"
    no_vk "ENABLE_EXTREME_BATTERY_SAVER"
    if $VKSEL; then
        print "- Installing Extreme Battery Saver (Flipendo)"
        echo " - Installing Extreme Battery Saver (Flipendo)" >>$logfile
        cp -f $MODPATH/files/PixelifyFilpendo.apk $MODPATH/system/product/overlay/PixelifyFilpendo.apk
        if [ $API -eq 32 ]; then
            tar -xf $MODPATH/files/flip-31.tar.xz -C $MODPATH/system
        else
            tar -xf $MODPATH/files/flip-$API.tar.xz -C $MODPATH/system
        fi
        FLIPENDO=$(find /system -name Flipendo)
        REMOVE="$REMOVE $FLIPENDO"
    else
        echo " - Skipping Extreme Battery Saver (Flipendo)" >>$logfile
    fi
fi

# Rboard app fixes
if [ ! -z "$(pm list packages | grep de.dertyp7214.rboardthememanager)" ]; then
    print ""
    print "- Rboard app is installed !!"
    print ""
    print "  Do you want to apply fix for Rboard by disabling GMS overriding flags?"
    print "  Note: Pixelify will still try to patch other method"
    print "    Vol Up += Yes"
    print "    Vol Down += No"
    no_vk "DISABLE_GBOARD_GMS_OVERRIDE"
    if $VKSEL; then
        DISABLE_GBOARD_GMS=1
    fi
fi

# Google keyboard
if [ ! -z "$(pm list packages | grep com.google.android.inputmethod.latin)" ]; then
    print ""
    print " Google keyboard is installed."
    print "- Enabling pixel exclusive features"
    [ $API -ge 31 ] && print "- Enabling NGA Voice typing (If Nga is installed)"

    # Flags patch for Gboard
    echo " - Patching Google Keyboard's bools" >>$logfile
    patch_gboard

    #$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.inputmethod.latin#com.google.android.inputmethod.latin'"
    if [ $DISABLE_GBOARD_GMS -eq 0 ]; then
        db_edit com.google.android.gms.learning#com.google.android.inputmethod.latin boolVal 1 "PredictorFeature__is_predict_enabled"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin boolVal 1 $GBOARD_FLAGS
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin boolVal $TENSOR "enable_edge_tpu" "lm_personalization_enabled"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin intVal 2000 "inline_suggestion_dismiss_tooltip_delay_time_millis"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin intVal 4 "inline_suggestion_experiment_version"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin stringVal "https://www.gstatic.com/android/keyboard/spell_checker/prod/2023011201/metadata_cpu_2023011201.json" "grammar_checker_manifest_uri"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin stringVal "en" "enable_emojify_language_tags"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin intVal 2 "nga_backspace_behavior"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin intVal 301153970 "nga_min_version_code_for_streaming_rpc"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin stringVal "en" "enabled_ocr_language_tags"
        # G Logo
        print ""
        print "  Do you want enable G logo in google keyboard?"
        print "  Note: Enabling it will not show you languages in spacebar"
        print "    Vol Up += Yes"
        print "    Vol Down += No"
        no_vk "G_LOGO"
        if $VKSEL; then
            db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin boolVal 1 "show_branding_on_space"
            db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin intVal 0 "show_branding_interval_seconds"
            db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin intVal 86400000 "branding_fadeout_delay_ms"
        fi
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin stringVal "com.android.mms,com.discord,com.facebook.katana,com.facebook.lite,com.facebook.orca,com.google.android.apps.dynamite,com.google.android.apps.messaging,com.google.android.youtube,com.instagram.android,com.snapchat.android,com.twitter.android,com.verizon.messaging.vzmsgs,com.viber.voip,com.whatsapp,com.zhiliaoapp.musically,jp.naver.line.android,org.telegram.messenger,tw.nekomimi.nekogram,org.telegram.BifToGram" "emojify_app_allowlist"
        pm enable com.google.android.googlequicksearchbox/com.google.android.apps.search.assistant.surfaces.dictation.service.endpoint.AssistantDictationService &>/dev/null
        am broadcast -a grpc.io.action.BIND -n com.google.android.googlequicksearchbox/com.google.android.apps.search.assistant.surfaces.dictation.service.endpoint.AssistantDictationService &>/dev/null
    fi

    if [ -z $(pm list packages -s com.google.android.inputmethod.latin) ] && [ -z "$(cat $pix/apps_temp.txt | grep gboard)" ]; then
        print "- GBoard is not installed as a system app !!"
        print "- Making Gboard a system app"
        echo " - Making Google Keyboard a system app" >>$logfile
        cp -r $app/com.google.android.inputmethod.latin*/. $MODPATH/system/product/app/LatinIMEGooglePrebuilt
        mv $MODPATH/system/product/app/LatinIMEGooglePrebuilt/base.apk $MODPATH/system/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk
        rm -rf $MODPATH/system/product/app/LatinIMEGooglePrebuilt/oat
        #mv $MODPATH/files/privapp-permissions-com.google.android.inputmethod.latin.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.inputmethod.latin.xml
        echo "gboard" >>$pix/app2.txt
    elif [ ! -z "$(cat $pix/apps_temp.txt | grep gboard)" ]; then
        print "- GBoard is not installed as a system app !!"
        echo " - Making Google Keyboard as system app" >>$logfile
        print "- Making Gboard a system app"
        cp -r $app/com.google.android.inputmethod.latin*/. $MODPATH/system/product/app/LatinIMEGooglePrebuilt
        mv $MODPATH/system/product/app/LatinIMEGooglePrebuilt/base.apk $MODPATH/system/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk
        rm -rf $MODPATH/system/product/app/LatinIMEGooglePrebuilt/oat
        #mv $MODPATH/files/privapp-permissions-com.google.android.inputmethod.latin.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.inputmethod.latin.xml
        echo "gboard" >>$pix/app2.txt
    fi
fi

# Speech Services by Google
if [ ! -z $(pm list packages com.google.android.tts) ]; then
    if [ -z $(pm list packages -s com.google.android.tts) ] && [ ! -f /data/adb/modules/Pixelify/system/product/app/GoogleTTS/GoogleTTS.apk ]; then
        install_tts
    elif [ -f /data/adb/modules/Pixelify/system$product/app/GoogleTTS/GoogleTTS.apk ]; then
        install_tts
    fi
else
    print ""
    print " ! It is recommended to install Google TTS"
    print " ! If you face any problem regarding call screening or call recording"
    [ $API -ge 31 ] && print " ! It is required for Live caption data downloading"
    print " ! Then Install GoogleTTS via playstore"
    print " ! Reinstall module to make it system app"
    print ""
fi

ui_print " - Patching GMS flags to enable features"
ui_print " - This may take a minute or two"

# Android System Intelligence
$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.platform.device_personalization_services' AND name LIKE 'Echo__search_%'"
db_edit com.google.android.platform.device_personalization_services boolVal 1 $ASI_FLAGS
db_edit com.google.android.platform.launcher boolVal 1 "enable_quick_launch_v2" "ENABLE_QUICK_LAUNCH_V2" "GBOARD_UPDATE_ENTER_KEY" "ENABLE_SMARTSPACE_ENHANCED"
#db_edit com.google.android.platform.device_personalization_services boolVal $TENSOR "Translate__enable_opmv4_service" "VisualCortex__enable_control_system"
if [ $TENSOR -eq 0 ]; then
    db_edit com.google.android.platform.device_personalization_services extensionVal SpeechPack__downloadable_language_packs_raw $ASIBIN

# $sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.platform.device_personalization_services' AND name='SpeechPack__downloadable_language_packs_raw'"
# $sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, extensionVal, committed) VALUES('com.google.android.platform.device_personalization_services', '', 'SpeechPack__downloadable_language_packs_raw', 0, x'$ASIBIN', 0)"
fi
#db_edit_bin com.google.android.platform.device_personalization_services WallpaperEffects__cinematic_models_mdd_manifest_config $WLPEFFECTCONFIG
db_edit com.google.android.platform.device_personalization_services extensionVal WallpaperEffects__cinematic_models_mdd_manifest_config $WLPEFFECTCONFIG
#Translate
db_edit com.google.android.platform.device_personalization_services stringVal "com.google.android.talk" "Translate__app_blocklist"
#db_edit com.google.android.platform.device_personalization_services stringVal "en,fr,it,de,ja,es" Translate__audio_to_text_language_list
db_edit com.google.android.platform.device_personalization_services stringVal "ja" "Translate__beta_audio_to_text_languages_in_live_caption"
db_edit com.google.android.platform.device_personalization_services boolVal 1 "Translate__blue_chip_translate_enabled"
db_edit com.google.android.platform.device_personalization_services boolVal 0 Translate__characterset_lang_detection_enabled
#db_edit com.google.android.platform.device_personalization_services stringVal "de,en,es,fr,it,ja,hi,zh,ru,pl,pt,ko,th,tr,nl,zh_Hant,sv,da,vi,ar,fa" Translate__chat_translate_languages
db_edit com.google.android.platform.device_personalization_services boolVal 1 Translate__copy_to_translate_enabled
db_edit com.google.android.platform.device_personalization_services boolVal 1 Translate__differentiate_simplified_and_traditional_chinese
db_edit com.google.android.platform.device_personalization_services boolVal 0 Translate__disable_session_state
db_edit com.google.android.platform.device_personalization_services boolVal 1 Translate__disable_translate_without_system_animation
db_edit com.google.android.platform.device_personalization_services boolVal 0 Translate__enable_chronicle_migration
db_edit com.google.android.platform.device_personalization_services boolVal 0 Translate__enable_default_langid_model
db_edit com.google.android.platform.device_personalization_services boolVal 0 Translate__enable_dictionary_langid_detection
db_edit com.google.android.platform.device_personalization_services boolVal 0 Translate__enable_language_profile_quick_update
db_edit com.google.android.platform.device_personalization_services boolVal 0 Translate__enable_nextdoor
db_edit com.google.android.platform.device_personalization_services boolVal $TENSOR Translate__enable_opmv4_service
db_edit com.google.android.platform.device_personalization_services boolVal 0 Translate__enable_spa_setting
#db_edit com.google.android.platform.device_personalization_services stringVal "af,ar,be,bg,bn,ca,cs,cy,da,de,el,eo,es,et,fa,fi,fr,ga,gl,hi,hr,ht,hu,id,is,it,ja,ko,lt,lv,mk,mr,ms,mt,nl,no,pl,pt,ro,ru,sk,sl,sq,sv,sw,ta,te,th,tl,tr,uk,ur,vi,zh,en" Translate__image_to_text_language_list
#db_edit com.google.android.platform.device_personalization_services stringVal "de,en,ja,es,fr,it" Translate__interpreter_source_languages
#db_edit com.google.android.platform.device_personalization_services stringVal "de,en,ja,es,fr,it" Translate__interpreter_target_languages
#db_edit com.google.android.platform.device_personalization_services stringVal "de,en,fr,it,ja,es" Translate__live_captions_translate_languages
#db_edit com.google.android.platform.device_personalization_services boolVal 0 Translate__replace_auto_translate_copied_text_enabled SimpleStorage__disable_live_translate_dao_provider
#db_edit com.google.android.platform.device_personalization_services stringVal "vi,ja,fa,ro,nl,mr,mt,ar,ms,it,eo,is,et,es,iw,zh,uk,af,id,ur,mk,cy,hi,el,be,pt,lt,hr,lv,hu,ht,te,de,bg,th,bn,tl,pl,tr,kn,sv,gl,ko,sw,cs,da,ta,gu,ka,sl,ca,sk,ga,sq,no,fi,ru,fr,en,zh_Hant,fil" Translate__text_to_text_language_list
db_edit com.google.android.platform.device_personalization_services boolVal 1 Translate__translation_service_enabled
db_edit com.google.android.platform.device_personalization_services boolVal 1 Translate__translator_expiration_enabled
db_edit com.google.android.platform.device_personalization_services boolVal $TENSOR Translate__use_translate_kit_streaming_api
db_edit com.google.android.platform.device_personalization_services stringVal "https://www.gstatic.com/safecomms/superpacks/manifests/phishing-5.json" Safecomms__hades_config_url
#db_edit com.google.android.platform.device_personalization_services stringVal "en-US;en-GB;en-CA;en-IE;en-AU;en-SG;en-IN;fr-FR;fr-CA;fr-BE;fr-CH;it-IT;it-CH;de-DE;de-AT;de-BE;de-CH;ja-JP;es-ES;es-US" Captions__supported_languages
db_edit com.google.android.platform.device_personalization_services intVal 20221227 Captions__new_model_version_advanced
db_edit com.google.android.platform.device_personalization_services intVal 20210623 Captions__new_model_version
db_edit com.google.android.platform.device_personalization_services intVal 20200112 Captions__model_version_v1_2
db_edit com.google.android.platform.device_personalization_services intVal 20190613 Captions__model_version_v1
db_edit com.google.android.platform.device_personalization_services stringVal "https://storage.googleapis.com/captions/%{NAMESPACE}_%{VERSION}_manifest.json" Captions__manifest_url_template

# Google Photos
#db_edit_bin com.google.android.apps.photos 45415301 $AUDIO_ERASER
#db_edit_bin com.google.android.apps.photos 45420912 $MAGIC_EDITOR
#db_edit_bin com.google.android.apps.photos 45422509 $ME3
#db_edit_bin com.google.android.apps.photos 45416982 $BESTTAKE
#db_edit_bin com.google.android.apps.photos 3015 $GPHOTOS
#db_edit com.google.android.apps.photos boolVal 1 45351624 45376295 45379559 45389076 45407001 45417606 45418019 45418318 45420670 45421194 45421373 45426271 45427054 45427088 45427578 45427613 45427667 45428201 45429413 45429414 45429500 45430376
#db_edit com.google.android.apps.photos boolVal 1 "45387434" "45351624" "45376295" "45379559" "45389076" "45407001" "45418318" "45420670" "45421194" "45421373" "45426271" "45427054" "45427088" "45427578" "45427613" "45427667" "45428201" "45429413" "45429414" "45429500" "45430376"
#Audio Eraser, Magic Editor, best take, unblur (requires PIXEL_EXPER)
#db_edit com.google.android.apps.photos boolVal 1 "45417606" "45421373" "45418019" "45376295"
# Fix for tools not installed, new magic eraser
#db_edit com.google.android.apps.photos boolVal 0 "45425404" "45398451" "45422612"

# Google Photos
db_edit com.google.android.apps.photos boolVal 1 "45389969" "45429858" "45377931" "45430953" "45417067" "45413465"
#Audio Eraser, Magic Editor
db_edit com.google.android.apps.photos boolVal 1 "45417606" "45421373"
# Fix for tools not installed, new magic eraser
db_edit com.google.android.apps.photos boolVal 0 "45425404" "45398451" "45422612"
# db_edit_bin com.google.android.apps.photos "45415301" "$AUDIO_ERASER"
# db_edit_bin com.google.android.apps.photos "45420912" "$MAGIC_EDITOR"
# db_edit_bin com.google.android.apps.photos "45422509" "$ME3"
# db_edit_bin com.google.android.apps.photos "45416982" "$BESTTAKE"
# db_edit_bin com.google.android.apps.photos "3015" "$GPHOTOS"
# db_edit_bin com.google.android.apps.photos "45378073" "$ERASER"
db_edit com.google.android.apps.photos extensionVal "45415301" "$AUDIO_ERASER"
db_edit com.google.android.apps.photos extensionVal "45420912" "$MAGIC_EDITOR"
db_edit com.google.android.apps.photos extensionVal "45422509" "$ME3"
db_edit com.google.android.apps.photos extensionVal "45416982" "$BESTTAKE"
db_edit com.google.android.apps.photos extensionVal "3015" "$GPHOTOS"
db_edit com.google.android.apps.photos extensionVal "45378073" "$ERASER"

# Digital Wellbeing
#$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.apps.wellbeing.device#com.google.android.apps.wellbeing'"
db_edit com.google.android.apps.wellbeing.device#com.google.android.apps.wellbeing boolVal 1 "ScreenTimeWidget__enable_pin_screen_time_widget_intent" "ScreenTimeWidget__enable_screen_time_widget" "HatsSurveys__enable_testing_mode" "WindDown__enable_wallpaper_dimming" "WalkingDetection__enable_outdoor_detection_v2" "Clockshine__enable_sleep_detection" "Clockshine__show_sleep_insights_screen" "Clockshine__show_manage_data_screen" "WebsiteUsage__display_website_usage"

# Google messages
db_edit com.google.android.apps.messaging#com.google.android.apps.messaging boolVal 1 "bugle_phenotype__enable_additional_functionalities_for_magic_compose" "bugle_phenotype__enable_combined_magic_compose" "bugle_phenotype__enable_magic_compose_view" "bugle_phenotype__magic_compose_enabled_in_xms" "45414981" "bugle_phenotype__enable_home_screen_redesign" "bugle_phenotype__untangle_otp_auto_delete_from_super_sort"

# Google Contacts
db_edit com.google.android.contacts#com.google.android.contacts boolVal 1 "45402053"

# Google Clock
db_edit com.google.android.deskclock#com.google.android.deskclock boolVal 1 "45408428" "45410158"

# Google translate
#$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.apps.translate'"
db_edit com.google.android.apps.translate boolVal 1 "Widgets__enable_quick_actions_widget" "Widgets__enable_saved_history_widget"

# Google settings Services
#$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.settings.intelligence'"
db_edit com.google.android.settings.intelligence boolVal 1 "RoutinesPrototype__is_activities_enabled" "RoutinesPrototype__is_module_enabled" "RoutinesPrototype__is_manual_location_rule_adding_enabled" "RoutinesPrototype__is_routine_inference_enabled" "BatteryWidget__is_widget_enabled" "BatteryWidget__is_enabled"

# Fix Precise Location
#$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.platform.privacy'"
db_edit com.google.android.platform.privacy boolVal 1 "location_accuracy_enabled" "permissions_hub_enabled" "privacy_dashboard_7_day_toggle" "safety_protection_enabled"

# Live Wallpapers
#$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.pixel.livewallpaper'"
db_edit com.google.pixel.livewallpaper stringVal "" DownloadableWallpaper__blocking_module_list

#turbo
#db_edit com.google.android.apps.turbo boolVal 1 $TURBO_FLAGS

# Google Recorder
#$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.apps.recorder#com.google.android.apps.recorder'"

# Calendar New widget Theme
db_edit com.google.android.calendar boolVal 1 "Gm3Widget_Enabled"

# Google cast
db_edit com.google.android.gms.cast boolVal 1 $CAST_FLAGS

# Qr Code
db_edit com.google.android.gms.vision boolVal 1 $QR_SCANNER_FLAGS

# Fitness
db_edit com.google.android.gms.fitness boolVal 1 $FITNESS_FLAGS

# Google Keep
db_edit com.google.android.keep#com.google.android.keep boolVal 1 45372155 45357152

# Google Play Store
db_edit com.google.android.finsky.regular boolVal 1 RetailMode__is_force_enabled
db_edit com.google.android.finsky.stable boolVal 1 RetailMode__is_force_enabled MaterialNextDynamicTheming__killswitch_dynamic_theming_bottomnavbar_flag

# Google Text to speech
#db_edit com.google.android.tts#com.google.android.tts boolVal 1 $

# Google Phenotype
db_edit com.google.android.gms.phenotype boolVal 1 PhenotypeFeature__allow_gmscore_to_override_flags

# Google multidevice
db_edit com.google.android.gms.multideice#com.google.android.gms boolVal 1 MultideviceSettingsConfig__enable_link_your_devices

# System
#$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.platform.systemui'"
db_edit com.google.android.platform.systemui boolVal 1 "clipboard_overlay_show_actions"

#Google TTS
[ $TENSOR -eq 0 ] && db_edit com.google.android.apps.search.transcription.device#com.google.android.tts extensionVal 11 $TTSBIN

# Permissions for apps
for j in $MODPATH/system/*/priv-app/*/*.apk; do
    set_perm_app $j
done
for j in $MODPATH/system/priv-app/*/*.apk; do
    set_perm_app $j
done

# Patching Sound trigger
#sound_trigger_patch

# Disable features as per API
if [ $API -ge 32 ]; then
    rm -rf $MODPATH/system/product/overlay/PixelifyPixel12.apk
fi

if [ $API -ge 31 ]; then
    rm -rf $MODPATH/system/product/overlay/PixelifyPixel.apk
    rm -rf $MODPATH/system/product/overlay/PixelifyApi30.apk
    sed -i -e 's/<feature name="com.google.android.feature.ZERO_TOUCH" \/>/<!-- <feature name="com.google.android.feature.ZERO_TOUCH" \/> -->/g' $MODPATH/system/product/etc/sysconfig/pixelifyexperience.xml
    if [ $WREM -eq 1 ]; then
        rm -rf $MODPATH/system/product/priv-app/WallpaperPickerGoogleRelease
    fi
fi

if [ $API -le 30 ]; then
    rm -rf $MODPATH/system$product/overlay/PixelifyPixelS.apk
fi

if [ $API -le 29 ]; then
    sed -i -e "s/device_config/#device_config/g" $MODPATH/service.sh
    rm -rf $MODPATH/system$product/priv-app/SimpleDeviceConfig
fi

if [ $API -le 27 ]; then
    sed -i -e "s/bool_patch AdaptiveCharging__v1_enabled/#bool_patch AdaptiveCharging__v1_enabled/g" $MODPATH/service.sh
fi

# OOS 12+ Fix
oos_fix

# Fix Permission controller
if [ $ROM_TYPE != "custom" ]; then
    rm -rf $MODPATH/system/product/overlay/Pixelify.apk
fi

# Setting permisions
set_perm_recursive $MODPATH 0 0 0755 0644

for i in $MODPATH/system/vendor/overlay $MODPATH/system$product/overlay $MODPATH/system$product/priv-app/* $MODPATH/system$product/app/*; do
    set_perm_recursive $i 0 0 0755 0644
done

# Regenerate overlay list
rm -rf /data/resource-cache/overlays.list
find /data/resource-cache/ -name "*Pixelify*" -exec rm -rf {} \;
find /data/resource-cache/ -name "*PixelLauncherOverlay*" -exec rm -rf {} \;

#make some permissions not enforced
pm set-permission-enforced android.permission.READ_DEVICE_CONFIG false
pm set-permission-enforced android.permission.SUSPEND_APPS. false

# Fix unknown creation of data folder
rm -rf $MODPATH/system/product/data

# Clear package cache
rm -rf /data/system/package_cache/*

# Updating vars
rm -rf $pix/apps_temp.txt $MODPATH/zygisk_1
mv $pix/app2.txt $pix/app.txt

# Replace apps
REMOVE="$(echo "$REMOVE" | tr ' ' '\n' | sort -u)"
REPLACE="$REMOVE"

settings put secure show_qr_code_scanner_setting true
settings put secure lock_screen_show_qr_code_scanner true

#Clean Up
rm -rf $MODPATH/files
rm -rf $MODPATH/spoof.prop
rm -rf $MODPATH/inc.prop

# create Uninstaller
[ -d $PIXELIFYUNS ] && rm -rf $PIXELIFYUNS
mkdir -p $PIXELIFYUNS
mv $MODPATH/module-uninstaller.prop $PIXELIFYUNS/module.prop
mv $MODPATH/service-uninstaller.sh $PIXELIFYUNS/service.sh
cp -r $MODPATH/flags_* $PIXELIFYUNS
rm -rf $MODPATH/flags_*
cp -f $MODPATH/deviceconfig.txt $PIXELIFYUNS/deviceconfig.txt
cp -f $MODPATH/utils.sh $PIXELIFYUNS/utils.sh
cp -f $MODPATH/vars.sh $PIXELIFYUNS/vars.sh
cp -r $MODPATH/addon $PIXELIFYUNS
touch $PIXELIFYUNS/first

mkdir -p $MODPATH/system/bin
mv $MODPATH/pixelify.sh $MODPATH/system/bin/pixelify
chmod 0755 $MODPATH/system/bin/pixelify

echo " 
- Replacing apps -
$REMOVE
------------------
" >>$logfile

echo " ---- Installation Finished ----" >>$logfile

print ""
print "- Done"
print ""
print " - Installation logs were saved as /sdcard/Pixelify/logs.txt"
print ""
