pixel_spoof=0

if [ $ARCH != "arm64" ] && [ $API -le 23 ]; then
    ui_print "Error: Minimum requirements doesn't meet"
    ui_print "arch: ARM64"
    ui_print "android version: 7.0+"
    exit 1
fi

logfile=/sdcard/Pixelify/logs.txt
rm -rf $logfile

echo " =============
   Pixelify $(cat $MODPATH/module.prop | grep version= | cut -d= -f2)
   Android Version: $API
=============
---- Installation Logs Started ----" >> $logfile

tar -xf $MODPATH/files/system.tar.xz -C $MODPATH

chmod 0755 $MODPATH/addon/*

online() {
    s=$($MODPATH/addon/curl -s -I http://www.google.com --connect-timeout 5 | grep "ok")
    if [ ! -z "$s" ]; then
        internet=1
        echo " - Network is Online" >> $logfile
    else
        internet=0
        echo "- Network is Offline" >> $logfile
    fi
}

online

pix=/data/pixelify
mkdir /sdcard/Pixelify

if [ ! -d $pix ]; then
    mkdir -p $pix
fi

if [ -f $pix/app.txt ]; then
    rm -rf $pix/apps_temp.txt
    cp -f $pix/app.txt $pix/apps_temp.txt
else
    touch $pix/apps_temp.txt
fi

rm -rf $pix/app2.txt
touch $pix/app2.txt

DPVERSIONP=1
NGAVERSIONP=1.1
LWVERSIONP=1.4
PLVERSIONP=1
NGASIZE="13.6 Mb"
LWSIZE="108 Mb"
PLSIZE="5 Mb"
WNEED=0
SEND_DPS=0

if [ $API -eq 31 ]; then
    if [ -f /Pixelify/backup/dp-net-$API.tar.xz ]; then
        DPSIZE="24 Mb"
    else
        DPSIZE="28 Mb"
    fi
    DPVERSIONP=1.4
    WSIZE="2.0 Mb"
    WNEED=1
    PLVERSIONP=1.1
    PLSIZE="12 Mb"
elif [ $API -eq 30 ]; then
    DPSIZE="20 Mb"
    DPVERSIONP=1.2
    WSIZE="2.1 Mb"
    WNEED=1
elif [ $API -eq 29 ]; then
    WSIZE="3.6 Mb"
    DPSIZE="15 Mb"
    DPVERSIONP=1
    WNEED=1
elif [ $API -eq 28 ]; then
    WSIZE="1.6 Mb"
    DPSIZE="10 Mb"
    DPVERSIONP=1
    WNEED=1
fi

online_mb(){
    while read B dummy; do
        [ $B -lt 1024 ] && echo ${B} && break
        KB=$(((B+512)/1024))
        [ $KB -lt 1024 ] && echo ${KB} && break
        MB=$(((KB+512)/1024))
        echo ${MB}
    done
}

if [ $internet -eq 1 ]; then
    ver=$($MODPATH/addon/curl -s https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/version.txt)
    NGAVERSION=$(echo "$ver" | grep nga | cut -d'=' -f2)
    LWVERSION=$(echo "$ver" | grep wallpaper | cut -d'=' -f2)
    DPVERSION=$(echo "$ver" | grep dp-$API | cut -d'=' -f2)
    PLVERSION=$(echo "$ver" | grep pl-$API | cut -d'=' -f2)
    rm -rf $pix/nga.txt
    rm -rf $pix/pixel.txt
    rm -rf $pix/dp.txt
    rm -rf $pix/pl-$API.txt
    echo "$NGAVERSION" >> $pix/nga.txt
    echo "$LWVERSION" >> $pix/pixel.txt
    echo "$DPVERSION" >> $pix/dp.txt
    echo "$PLVERSION" >> $pix/pl-$API.txt
    NGASIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/NgaResources.apk | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
    LWSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pixel.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
    if [  $API -eq 31 ]; then
        if [ -f /sdcard/Pixelify/backup/dp-net-$API.tar.xz ]; then
            DPSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/dp-$API.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
        else
            DPSIZE="$(expr $($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/dp-$API.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) + $($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/dp-net-$API.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb)) Mb"
            SEND_DPS=1
        fi
    else
        DPSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/dp-$API.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
    fi
    PLSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pl-$API.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
else
    if [ ! -f $pix/nga.txt ]; then
        echo "$NGAVERSIONP" >> $pix/nga.txt
    fi
    if [ ! -f $pix/pixel.txt ]; then
        echo "$LWVERSIONP" >> $pix/pixel.txt
    fi
    if [ ! -f $pix/dp.txt ]; then
        echo "$DPVERSIONP" >> $pix/pixel.txt
    fi
    if [ ! -f $pix/pl-$API.txt ]; then
        echo "$PLVERSIONP" >> $pix/pl-$API.txt
    fi
fi

NGAVERSION=$(cat $pix/nga.txt)
LWVERSION=$(cat $pix/pixel.txt)
DPVERSION=$(cat $pix/dp.txt)
PLVERSION=$(cat $pix/pl-$API.txt)

echo "
- NGA version is $NGAVERSION
- Pixel Live Wallpapers version is $NGAVERSION
- Device Personalisation Services version is $DPVERSION
- Pixel Launcher ($API) version is $PLVERSION
" >> $logfile

chmod -R 0755 $MODPATH/addon
chmod 0644 $MODPATH/files/*.xz
alias keycheck="$MODPATH/addon/keycheck"
sqlite=$MODPATH/addon/sqlite3
gms=/data/user/0/com.google.android.gms/databases/phenotype.db

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

mkdir $MODPATH/system$product/priv-app
mkdir $MODPATH/system$product/app

if [ $API -ge 30 ]; then
    app=/data/app/*
else
    app=/data/app
fi

print() {
    ui_print "$@"
    sleep 0.3
}

ui_print ""
print "- Detected Arch: $ARCH"
print "- Detected SDK : $API"
RAM=$( grep MemTotal /proc/meminfo | tr -dc '0-9')
print "- Detected Ram: $RAM"
ui_print ""
if [ $RAM -le "6000000" ]; then
    rm -rf $MODPATH/system$product/etc/sysconfig/GoogleCamera_6gb_or_more_ram.xml
    echo " - Removing GoogleCamera_6gb_or_more_ram.xml as device has less than 6Gb Ram" >> $logfile
fi

DIALER1=$(find /system -name *Dialer.apk)

GOOGLE=$(find /system -name Velvet.apk)

REMOVE=""

if [ $API -ge "28" ]; then
    if [ ! -z $(find /system -name DevicePerson* | grep -v "\.") ] && [ ! -z $(find /system -name DevicePerson* | grep -v "\.") ]; then
        DP1=$(find /system -name DevicePerson* | grep -v "\.")
        DP2=$(find /system -name Matchmaker* | grep -v "\.")
        DP="$DP1 $DP2"
    elif [ -z  $(find /system -name DevicePerson* | grep -v "\.") ]; then
        DP=$(find /system -name Matchmaker* | grep -v "\.")
    else
        DP=$(find /system -name DevicePerson* | grep -v "\.")
    fi
    #REMOVE="$DP"
fi

if [ $API -ge 28 ]; then
    TUR=$(find /system -name Turbo*.apk | grep -v overlay)
    REMOVE="$REMOVE $TUR"
fi

bool_patch() {
    file=$2
    line=$(grep $1 $2 | grep false | cut -c 14- | cut -d' ' -f1)
    for i in $line; do
        val_false='value="false"'
        val_true='value="true"'
        write="${i} $val_true"
        find="${i} $val_false"
        sed -i -e "s/${find}/${write}/g" $file
    done
}

string_patch() {
    file=$3
    str=$(grep $1 $3 | grep string | cut -c 14- | cut -d'<' -f1)
    str1=$(grep $1 $3 | grep string | cut -c 14- | cut -d'>' -f1)
    add="$str1>$2"
    sed -i -e "s/${str}/${add}/g" $file
}

abort1() {
    echo "Installation Failed: $1" >> $logfile
    abort "$1"
}

keytest() {
    ui_print "- Vol Key Test"
    ui_print "    Press a Vol Key:"
    if (timeout 3 /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events); then
        return 0
    else
        ui_print "   Try again:"
        timeout 3 $MODPATH/addon/keycheck
        local SEL=$?
        [ $SEL -eq 143 ] && abort1 "   Vol key not detected!" || return 1
    fi
}

chooseport() {
    # Original idea by chainfire @xda-developers, improved on by ianmacd @xda-developers
    #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
    while true; do
        /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events
        if (`cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
            break
        fi
    done
    if (`cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
        print ""
        print "  Selected: Volume UP"
        print ""
        return 0
    else
        print ""
        print "  Selected: Volume Down"
        print ""
        return 1
    fi
}

chooseportold() {
    # Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
    # Calling it first time detects previous input. Calling it second time will do what we want
    while true; do
        $MODPATH/addon/keycheck
        local SEL=$?
        if [ "$1" == "UP" ]; then
            UP=$SEL
            break
        elif [ "$1" == "DOWN" ]; then
            DOWN=$SEL
            break
        elif [ $SEL -eq $UP ]; then
            print ""
            print "  Selected: Volume UP"
            print ""
            return 0
        elif [ $SEL -eq $DOWN ]; then
            print ""
            print "  Selected: Volume Down"
            print ""
            return 1
        fi
    done
}

# Have user option to skip vol keys
OIFS=$IFS; IFS=\|; MID=false; NEW=false
case $(echo $(basename $ZIPFILE) | tr '[:upper:]' '[:lower:]') in
    *novk*) ui_print "- Skipping Vol Keys -" ;;
    *) if keytest; then
            VKSEL=chooseport
        else
            VKSEL=chooseportold
            ui_print "  ! Legacy device detected! Using old keycheck method"
            ui_print " "
            ui_print "- Vol Key Programming -"
            ui_print "  Press Vol Up Again:"
            $VKSEL "UP"
            ui_print "  Press Vol Down"
            $VKSEL "DOWN"
        fi ;;
esac
IFS=$OIFS

DIALER=com.google.android.dialer
ui_print ""
print "- Installing Pixelify Module"
print "- Extracting Files...."
if [ $API -ge 28 ]; then
    tar -xf $MODPATH/files/tur.tar.xz -C $MODPATH/system$product/priv-app
fi

if [ ! -z "$(getprop ro.rom.version | grep Oxygen)" ] || [ ! -z "$(getprop ro.miui.ui.version.code)" ] || [ "$(getprop ro.product.vendor.manufacturer)" == "samsung" ]; then
    echo " - Oxygen OS or MiUI or One Ui Rom Detected" >> $logfile
    echo " - Dropping ro.product.vendor.name, ro.product.vendor.device, ro.product.vendor.model, ro.product.vendor.brand prop from spoof.prop" >> $logfile
    while read p; do
        if [ ! -z "$(echo $p | grep vendor)" ]; then
            sed -i -e "s/${p}/#${p}/g" $MODPATH/spoof.prop
        fi
    done <$MODPATH/spoof.prop
fi

GUNLIMITED=0
print ""
print "  Do you want to enable Google Photos Original Unlimited Backup?"
print " -----------NOTE---------------"
print " - Your device model will be set to Pixel 3 XL"
print " - If Select 'No' here you can still get Unlimited Storage Saver Backup"
print " - Next Generation Assistant Continued Conversation Won't Work"
print " -----------END---------------"
print "   Vol Up += Yes"
print "   Vol Down += No"

if $VKSEL; then
	rm -rf $MODPATH/system/product/etc/sysconfig/pixel_experience_2020.xml
	touch $MODPATH/system/product/etc/sysconfig/pixel_experience_2020.xml
	GUNLIMITED=1
	sed -i -e "s/Pixel 6 Pro/Pixel 3 XL/g" $MODPATH/spoof.prop
	cat $MODPATH/spoof.prop >> $MODPATH/system.prop
fi

if [ $GUNLIMITED -eq 0 ]; then
print ""
print "  Do you want to Spoof your device to Pixel 5/Pixel 6 Pro?"
print "   Vol Up += Yes"
print "   Vol Down += No"

if $VKSEL; then
    pixel_spoof=1
    print " ---------"
    print "  Note: If your device have some problem with downloading in playstore"
    print "  Please Select Pixel 6 Pro"
    print "---------"
    print ""
    print "  Select Spoof to Pixel 5 (recommended) or Pixel 6 Pro?"
    print "   Vol Up += Pixel 5"
    print "   Vol Down += Pixel 6 Pro (Google Photos Unlimited backup may not work properly)"
    if $VKSEL; then
        sed -i -e "s/Pixel 6 Pro/Pixel 5/g" $MODPATH/spoof.prop
    fi
    echo " - Spoofing device to $(grep ro.product.model $MODPATH/spoof.prop | cut -d'=' -f2) ( $(grep ro.product.device $MODPATH/spoof.prop | cut -d'=' -f2 ) )" >> $logfile
    cat $MODPATH/spoof.prop >> $MODPATH/system.prop
else
    echo " - Ignoring spoofing device" >> $logfile
fi
fi

DPAS=1
if [ ! -z $(pm list packages -s | grep com.google.android.as) ]; then
    echo " - Device Personalisation Services is not installed or not installed as system app" >> $logfile
    if [ -z $(cat $pix/apps_temp.txt | grep "dp-$API") ]; then
        if [ $API -eq 30 ] && [ ! -z $($MODPATH/addon/dumpsys package com.google.android.as | grep versionName | grep pixel5) ]; then
            echo " - Ignoring Device Personalisation Services due to Pixel 5 version already installed" >> $logfile
            DPAS=0
        elif [ $API -eq 31 ] && [ ! -z $($MODPATH/addon/dumpsys package com.google.android.as | grep versionName | grep pixel6) ]; then
            echo " - Ignoring Device Personalisation Services due to Pixel 6 version already installed" >> $logfile
            DPAS=0
        elif [ $API -le 29 ]; then
            DPAS=0
            echo " - Ignoring Device Personalisation Services because it's already installed" >> $logfile
        fi
    fi
fi

if [ $API -le 27 ]; then
    echo " - Disabling Device Personalisation Services installation due to api not supported" >> $logfile
    DPAS=0
fi

if [ "$(getprop ro.product.vendor.manufacturer)" == "samsung" ]; then
    if [ ! -z "$(getprop ro.build.PDA)" ]; then
        echo " - Disabling Device Personalisation Services installation on samsung devices" >> $logfile
        DPAS=0
    fi
fi

if [ $DPAS -eq 1 ]; then
    echo " - Installing Device Personalisation Services" >> $logfile
    $sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.platform.device_personalization_services' AND name='AdaptiveAudio__enable_adaptive_audio'"
    $sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, boolVal, committed) VALUES('com.google.android.platform.device_personalization_services', '', 'AdaptiveAudio__enable_adaptive_audio', 0, 1, 0)"
    $sqlite $gms "UPDATE Flags SET boolVal='1' WHERE packageName='com.google.android.platform.device_personalization_services' AND name='adaptiveAudio__enable_adaptive_audio'"
    if [ -f /sdcard/Pixelify/backup/dp-$API.tar.xz ]; then
        echo " - Backup Detected for Device Personalisation Services" >> $logfile
        REMOVE="$REMOVE $DP"
        if [ "$(cat /sdcard/Pixelify/version/dp.txt)" != "$DPVERSION_$API" ] || [ $SEND_DPS -eq 1 ]; then
            echo " - New Version Detected for Device Personalisation Services" >> $logfile
            echo " - Installed version: $(cat /sdcard/Pixelify/version/dp.txt) , New Version: $DPVERSION_$API " >> $logfile
            ui_print ""
            print "  (Network Connection Needed)"
            print "  New version Detected of Device Personalistaion Services"
            print "  Do you Want to update or use Old Backup?"
            print "  Version: $DPVERSION"
            print "  Size: $DPSIZE"
            print "   Vol Up += Update"
            print "   Vol Down += Use Old Backup"
            if $VKSEL; then
                online
                if [ $internet -eq 1 ]; then
                    echo " - Downloading and installing new backup for Device Personalisation Services" >> $logfile
                    rm -rf /sdcard/Pixelify/backup/dp-$API.tar.xz
                    rm -rf /sdcard/Pixelify/version/dp.txt
                    cd $MODPATH/files
                    if [ ! -f /sdcard/Pixelify/backup/dp-net-$API.tar.xz ] && [ $API -eq 31 ]; then
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/dp-net-$API.tar.xz -O &> /proc/self/fd/$OUTFD
                        rm -rf /backup/dp-net-$API.tar.xz
                        cp -f $MODPATH/files/dp-net-$API.tar.xz /sdcard/Pixelify/backup/dp-net-$API.tar.xz
                    fi
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/dp-$API.tar.xz -O &> /proc/self/fd/$OUTFD
                    cd /
                    print ""
                    print "- Creating Backup"
                    cp -f $MODPATH/files/dp-$API.tar.xz /sdcard/Pixelify/backup/dp-$API.tar.xz
                    echo "$DPVERSION_$API" >> /sdcard/Pixelify/version/dp.txt
                else
                    print ""
                    print "!! Warning !!"
                    print " No internet detected"
                    print ""
                    print "- Using Old backup for now."
                    echo " - Using Old backup for Device Personalisation Services due to no internet services" >> $logfile
                    print ""
                fi
            else
                echo " - Using Old backup for Device Personalisation Services" >> $logfile
                print ""
            fi
        fi
        print "- Installing Device Personalisation Services"
        print ""
        if [ $API -eq 31 ] && [ -z $($MODPATH/addon/dumpsys package com.google.android.as | grep versionName | grep pixel6) ]; then
            rm -rf /data/app/*/*com.google.android.as*
        fi
        cp -f $MODPATH/files/PixeliflyDPS.apk $MODPATH/system/product/overlay/PixeliflyDPS.apk
        if [ $API -eq 31 ] && [ -f /sdcard/Pixelify/backup/dp-net-$API.tar.xz ]; then
            tar -xf /sdcard/Pixelify/backup/dp-net-$API.tar.xz -C $MODPATH/system$product/priv-app
        fi
        tar -xf /sdcard/Pixelify/backup/dp-$API.tar.xz -C $MODPATH/system$product/priv-app
        echo dp-$API > $pix/app2.txt
    else
        ui_print ""
        echo " - No backup Detected for Device Personalisation Services" >> $logfile
        print "  (Network Connection Needed)"
        print "  Do you want to install and Download Device Personalisation Services?"
        print "  Size: $DPSIZE"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        if $VKSEL; then
            online
            if [ $internet -eq 1 ]; then
                print "- Downloading Device Personalisation Services"
                echo " - Downloading and installing Device Personalisation Services" >> $logfile
                ui_print ""
                cd $MODPATH/files
                if [ $API -eq 31 ]; then
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/dp-net-$API.tar.xz -O &> /proc/self/fd/$OUTFD
                fi
                $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/dp-$API.tar.xz -O &> /proc/self/fd/$OUTFD
                cd /
                print ""
                print "- Installing Device Personalisation Services"
                cp -f $MODPATH/files/PixeliflyDPS.apk $MODPATH/system/product/overlay/PixeliflyDPS.apk
                if [ $API -eq 31 ]; then
                    tar -xf $MODPATH/files/dp-net-$API.tar.xz -C $MODPATH/system$product/priv-app
                fi
                tar -xf $MODPATH/files/dp-$API.tar.xz -C $MODPATH/system$product/priv-app
                if [ $API -eq 31 ] && [ -z $($MODPATH/addon/dumpsys package com.google.android.as | grep versionName | grep pixel6) ]; then
                    rm -rf /data/app/*/*com.google.android.as*
                fi
                echo dp-$API > $pix/app2.txt
                REMOVE="$REMOVE $DP"
                ui_print ""
                print "  Do you want to create backup of Device Personalisation Services?"
                print "  so that you don't need redownload it everytime."
                print "   Vol Up += Yes"
                print "   Vol Down += No"
                if $VKSEL; then
                    echo " - Creating backup for Device Personalisation Services" >> $logfile
                    print "- Creating Backup"
                    mkdir -p /sdcard/Pixelify/backup
                    rm -rf /sdcard/Pixelify/backup/dp-$API.tar.xz
                    if [ -f $MODPATH/files/dp-net-$API.tar.xz ] && [ $API -eq 31 ]; then
                        rm -rf /sdcard/Pixelify/backup/dp-net-$API.tar.xz
                        cp -f $MODPATH/files/dp-net-$API.tar.xz /sdcard/Pixelify/backup/dp-net-$API.tar.xz
                    fi
                    cp -f $MODPATH/files/dp-$API.tar.xz /sdcard/Pixelify/backup/dp-$API.tar.xz
                    print ""
                    mkdir /sdcard/Pixelify/version
                    echo "$DPVERSION" >> /sdcard/Pixelify/version/dp.txt
                    print " - Done"
                fi
            else
                print "!! Warning !!"
                print " No internet detected"
                print ""
                print "- Skipping Device Personalisation Services"
                print ""
                echo " - Skipping Device Personalisation Services due to no internet services" >> $logfile
            fi
        fi
    fi
else
    print ""
fi

if [ -d /data/data/$DIALER ]; then
    print "  Do you want to install Google Dialer features?"
    print "   - Includes Call Screening, Call Recording, Hold for Me, Direct My Call"
    print "   (For all Countries)"
    print "    Vol Up += Yes"
    print "    Vol Down += No"
    if $VKSEL; then
        echo " - Installing Google Dialer features" >> $logfile
        DIALER_PREF=/data/data/com.google.android.dialer/shared_prefs/dialer_phenotype_flags.xml
        sed -i -e "s/CallScreening=0/CallScreening=1/g" $MODPATH/config.prop
        print "- Enabling Call Screening & Hold for me & Direct My Call"
        print ""
        print "- Please Use google Dialer apk for"
        print "  Direct my Call given in Pixelify github link"
        print " "
        print "- Enabling Call Recording (Working is device dependent)"
        setprop sys.persist.locale en-US
        print " "
        print "- Please set your launguage to"
        print "  English (United States) for call screening"
        print " "
        device="$(getprop ro.product.device)"
        device_len=${#device}
        carr_coun1="$(getprop gsm.sim.operator.iso-country)"
        carr_coun="$(getprop gsm.sim.operator.iso-country | tr '[:lower:]' '[:upper:]')"
        if [ ! -z $carr_coun ]; then
            echo " - Adding Country ($carr_coun) patch for Call Recording and Hold for me, Direct My Call" >> $logfile
            sed -i -e "s/TX/${carr_coun}/g" $MODPATH/files/$DIALER
            if [ -z $(echo "AU US JP" | grep $carr_coun) ]; then
                sed -i -e "s/TF/${carr_coun}/g" $MODPATH/files/$DIALER
            fi
            sed -i -e "s/xy/${carr_coun1}/g" $MODPATH/files/$DIALER
        fi
        if [ $pixel_spoof -eq 0 ]; then
            if [ -z "$(cat $MODPATH/recording.txt | grep $device)" ]; then
                echo " - Adding Call Recording patch" >> $logfile
                case $device_len in
                    3)
                        sed -i -e "s/lmi/${device}/g" $MODPATH/files/$DIALER
                        ;;
                    4)
                        sed -i -e "s/ares/${device}/g" $MODPATH/files/$DIALER
                        ;;
                    5)
                        sed -i -e "s/bhima/${device}/g" $MODPATH/files/$DIALER
                        ;;
                    6)
                        sed -i -e "s/ginkgo/${device}/g" $MODPATH/files/$DIALER
                        ;;
                    7)
                        sed -i -e "s/gauguin/${device}/g" $MODPATH/files/$DIALER
                        ;;
                    8)
                        sed -i -e "s/camellia/${device}/g" $MODPATH/files/$DIALER
                        ;;
                    9)
                        sed -i -e "s/camellian/${device}/g" $MODPATH/files/$DIALER
                        ;;
                    11)
                        sed -i -e "s/OnePlusN200/${device}/g" $MODPATH/files/$DIALER
                        ;;
                    12)
                        sed -i -e "s/Infinix-X692/${device}/g" $MODPATH/files/$DIALER
                        ;;
                    13)
                        sed -i -e "s/gauguininpro/${device}/g" $MODPATH/files/$DIALER
                        ;;
                    14)
                        sed -i -e "s/Infinix-X687BR/${device}/g" $MODPATH/files/$DIALER
                        ;;
                    *)
                        print ""
                        print "  Warning !!"
                        print "  For Call Recording your ro.product.device"
                        print "  needs to set (raven)"
                        print "  Do you Wish to Install Google Dialer Call Recording?"
                        print "    Vol Up += Yes"
                        print "    Vol Down += No (Call recording won't be installed)"
                        if $VKSEL; then
                            echo "ro.product.device=raven" >> $MODPATH/system.prop
                        fi
                        ;;
                esac
            fi
        fi

        # Remove old prompt to replace to use within overlay
        rm -rf /data/data/com.google.android.dialer/files/callrecordingprompt

        cp -Tf $MODPATH/files/$DIALER $MODPATH/$DIALER
        cp -Tf $MODPATH/files/$DIALER /data/data/com.google.android.dialer/files/phenotype/$DIALER
        am force-stop $DIALER

        if [ -z $(pm list packages -s $DIALER) ] && [ ! -f /data/adb/modules/Pixelify/system/product/priv-app/GoogleDialer/GoogleDialer.apk ]; then
            print ""
            print "- Google Dialer is not installed as a system app !!"
            print "- Making Google Dialer as a system app"
            echo " - Making Google Dialer system app" >> $logfile
            print ""
            cp -r ~/$app/com.google.android.dialer*/. $MODPATH/system$product/priv-app/GoogleDialer
            mv $MODPATH/system$product/priv-app/GoogleDialer/base.apk $MODPATH/system$product/priv-app/GoogleDialer/GoogleDialer.apk
            rm -rf $MODPATH/system$product/priv-app/GoogleDialer/oat
        elif [ -f /data/adb/modules/Pixelify/system/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk ]; then
            print ""
            print "- Google Dialer is not installed as a system app !!"
            print "- Making Google Dialer as a system app"
            echo " - Making Google Dialer system app" >> $logfile
            print ""
            cp -r ~/$app/com.google.android.dialer*/. $MODPATH/system$product/priv-app/GoogleDialer
            mv $MODPATH/system$product/priv-app/GoogleDialer/base.apk $MODPATH/system$product/priv-app/GoogleDialer/GoogleDialer.apk
            rm -rf $MODPATH/system$product/priv-app/GoogleDialer/oat
        fi
    fi
fi

GOOGLE_PREF=/data/data/com.google.android.googlequicksearchbox/shared_prefs/GEL.GSAPrefs.xml
if [ -d /data/data/com.google.android.googlequicksearchbox ] && [ $API -ge 29 ]; then
    print "  Google is installed."
    print "  Do you want to installed Next generation assistant?"
    if [  $pixel_spoof -eq 0 ] && [ $GUNLIMITED -eq 0 ]; then
        print "Note: Your Model will be set to Pixel 6 Pro if YES"
	elif [ $GUNLIMITED -eq 1 ]; then
		print "Note: NGA assistant may not work due to Spoof to Pixel 3 XL"
    fi
    print "   Vol Up += Yes"
    print "   Vol Down += No"
    if $VKSEL; then
        echo " - Installing Next generation assistant" >> $logfile
        if [ -f /sdcard/Pixelify/backup/NgaResources.apk  ]; then
            if [ "$(cat /sdcard/Pixelify/version/nga.txt)" != "$NGAVERSION" ]; then
                echo " - New Version Detected for NGA Resources" >> $logfile
                echo " - Installed version: $(cat /sdcard/Pixelify/version/nga.txt) , New Version: $NGAVERSION " >> $logfile
                print "  (Network Connection Needed)"
                print "  New version Detected."
                print "  Do you Want to update or use Old Backup?"
                print "  Version: $NGAVERSION"
                print "  Size: $NGASIZE"
                print "   Vol Up += Update"
                print "   Vol Down += Use old backup"
                if $VKSEL; then
                    online
                    if [ $internet -eq 1 ]; then
                        echo " - Downloading, Installing and creating backup NGA Resources" >> $logfile
                        rm -rf /sdcard/Pixelify/backup/NgaResources.apk
                        rm -rf /sdcard/Pixelify/version/nga.txt
                        mkdir $MODPATH/system/product/app/NgaResources
                        cd $MODPATH/system/product/app/NgaResources
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/NgaResources.apk -O &> /proc/self/fd/$OUTFD
                        cd /
                        print ""
                        print "- Creating Backup"
                        print ""
                        cp -f $MODPATH/system/product/app/NgaResources/NgaResources.apk /sdcard/Pixelify/backup/NgaResources.apk
                        echo "$NGAVERSION" >> /sdcard/Pixelify/version/nga.txt
                    else
                        print "!! Warning !!"
                        print " No internet detected"
                        print ""
                        print "- Using Old backup for now."
                        print ""
                        echo " - using old backup for NGA Resources due to no internet" >> $logfile
                    fi
                else
                    echo " - using old backup for NGA Resources" >> $logfile
                fi
            fi
            print "- Installing NgaResources from backups"
            print ""
            mkdir $MODPATH/system/product/app/NgaResources
            cp -f /sdcard/Pixelify/backup/NgaResources.apk $MODPATH/system/product/app/NgaResources/NgaResources.apk
        else
            print "  (Network Connection Needed)"
            print "  Do you want to install and Download NGA Resources"
            print "  Size: $NGASIZE"
            print "   Vol Up += Yes"
            print "   Vol Down += No"
            if $VKSEL; then
                online
                if [ $internet -eq 1 ]; then
                    echo " - Downloading and Installing NGA Resources" >> $logfile
                    print "  Downloading NGA Resources"
                    mkdir $MODPATH/system/product/app/NgaResources
                    cd $MODPATH/system/product/app/NgaResources
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/NgaResources.apk -O &> /proc/self/fd/$OUTFD
                    cd /
                    ui_print ""
                    print "  Do you want to create backup of NGA Resources"
                    print "  so that you don't need redownload it everytime."
                    print "   Vol Up += Yes"
                    print "   Vol Down += No"
                    if $VKSEL; then
                        echo " - Creating backup for NGA Resources" >> $logfile
                        print "- Creating Backup"
                        mkdir /sdcard/Pixelify
                        mkdir /sdcard/Pixelify/backup
                        rm -rf /sdcard/Pixelify/backup/NgaResources.apk
                        cp -f $MODPATH/system/product/app/NgaResources/NgaResources.apk /sdcard/Pixelify/backup/NgaResources.apk
                        mkdir /sdcard/Pixelify/version
                        echo "$NGAVERSION" >> /sdcard/Pixelify/version/nga.txt
                        ui_print ""
                        print "- NGA Resources installation complete"
                        print ""
                    fi
                else
                    print "!! Warning !!"
                    print " No internet detected"
                    print ""
                    print "- Skipping NGA Resources."
                    print ""
                    echo " - skipping NGA Resources due to no internet" >> $logfile
                fi
            else
                echo " - skipping NGA Resources" >> $logfile
            fi
        fi

        if [  $pixel_spoof -eq 0 ] && [ $GUNLIMITED -eq 0 ]; then
            echo " - Spoofing to Pixel 6 Pro for Next Generation Assistant" >> $logfile
            echo "ro.product.model=Pixel 6 Pro" >> $MODPATH/system.prop
        fi

        google_flag="17074 45353661"
        for i in $google_flag; do
            $sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.googlequicksearchbox' AND name='$i'"
        done

        $sqlite $gms "UPDATE Flags SET stringVal='Pixel 6,Pixel 6 Pro,Pixel 5,Pixel 3XL' WHERE packageName='com.google.android.googlequicksearchbox' AND name='17074'"
        $sqlite $gms "UPDATE Flags SET stringVal='Oriole,oriole,Raven,raven,Pixel 6,Pixel 6 Pro,redfin,Redfin,Pixel 5,crosshatch,Pixel 3XL' WHERE packageName='com.google.android.googlequicksearchbox' AND name='45353661'"
        $sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, stringVal, committed) VALUES('com.google.android.googlequicksearchbox', '', '17074', 0, 'Pixel 6,Pixel 6 Pro,Pixel 5,Pixel 3XL', 0)"
        $sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, stringVal, committed) VALUES('com.google.android.googlequicksearchbox', '', '45353661', 0, 'Oriole,oriole,Raven,raven,Pixel 6,Pixel 6 Pro,redfin,Redfin,Pixel 5,crosshatch,Pixel 3XL', 0)"

        cp -f $MODPATH/files/nga.xml $MODPATH/system$product/etc/sysconfig/nga.xml

        if [ -z $(pm list packages -s com.google.android.googlequicksearchbox | grep -v nga) ] && [ ! -f /data/adb/modules/Pixelify/system/product/priv-app/Velvet/Velvet.apk ]; then
            print "- Google is not installed as a system app !!"
            print "- Making Google as a system app"
            echo " - Making Google system app" >> $logfile
            print ""
            cp -r ~/$app/com.google.android.googlequicksearchbox*/. $MODPATH/system/product/priv-app/Velvet
            mv $MODPATH/system/product/priv-app/Velvet/base.apk $MODPATH/system/product/priv-app/Velvet/Velvet.apk
            rm -rf $MODPATH/system/product/priv-app/Velvet/oat
            #mv $MODPATH/files/privapp-permissions-com.google.android.googlequicksearchbox.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.googlequicksearchbox.xml
        elif [ -f /data/adb/modules/Pixelify/system/product/priv-app/Velvet/Velvet.apk ]; then
            print "- Google is not installed as a system app !!"
            print "- Making Google as a system app"
            echo " - Making Google system app" >> $logfile
            print ""
            cp -r ~/$app/com.google.android.googlequicksearchbox*/. $MODPATH/system/product/priv-app/Velvet
            mv $MODPATH/system/product/priv-app/Velvet/base.apk $MODPATH/system/product/priv-app/Velvet/Velvet.apk
            rm -rf $MODPATH/system/product/priv-app/Velvet/oat
            #mv $MODPATH/files/privapp-permissions-com.google.android.googlequicksearchbox.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.googlequicksearchbox.xml
        fi
    fi
fi

WREM=1

install_wallpaper() {
    if [ $WNEED -eq 1 ]; then
        print "  (Network Connection Needed)"
        print "  Do you want to Download Google Styles and Wallpapers?"
        print "  Size: $WSIZE"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        if $VKSEL; then
            online
            if [ $internet -eq 1 ]; then
                print "- Downloading Styles and Wallpapers"
                echo " - Downloading and installing Styles and Wallpapers" >> $logfile
                cd $MODPATH/files
                $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/wpg-$API.tar.xz -O &> /proc/self/fd/$OUTFD
                cd /
                rm -rf $MODPATH/system$product/priv-app/WallpaperPickerGoogleRelease
                print ""
                print "- Installing Styles and Wallpapers"
                print ""
                tar -xf $MODPATH/files/wpg-$API.tar.xz -C $MODPATH/system$product/priv-app
                WREM=0
            fi
        fi
    fi
}

WALL_DID=0
wall=$(find /system -name WallpaperPickerGoogle*.apk)
if [ $API -ge 28 ]; then
    if [ -f /sdcard/Pixelify/backup/pixel.tar.xz ]; then
        echo " - Backup Detected for Pixel Wallpapers" >> $logfile
        print "  Do you want to install Pixel Live Wallpapers?"
        print "  (Backup detected, no internet needed)"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        if $VKSEL; then
            sed -i -e "s/Live=0/Live=1/g" $MODPATH/config.prop
            REMOVE="$REMOVE $wall"
            if [ "$(cat /sdcard/Pixelify/version/pixel.txt)" != "$LWVERSION" ]; then
                echo " - New Version Backup Detected for Pixel Wallpapers" >> $logfile
                echo " - Old version:$(cat /sdcard/Pixelify/version/pixel.txt), New Version:  $LWVERSION " >> $logfile
                print "  (Network Connection Needed)"
                print "  New version Detected "
                print "  Do you Want to update or use Old Backup?"
                print "  Version: $LWVERSION"
                print "  Size: $LWSIZE"
                print "   Vol Up += Update"
                print "   Vol Down += Use old backup"
                if $VKSEL; then
                    online
                    if [ $internet -eq 1 ]; then
                        echo " - Downloading and Installing New Backup for Pixel Wallpapers" >> $logfile
                        rm -rf /sdcard/Pixelify/backup/pixel.tar.xz
                        rm -rf /sdcard/Pixelify/version/pixel.txt
                        cd $MODPATH/files
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pixel.tar.xz -O &> /proc/self/fd/$OUTFD
                        cd /
                        print "- Creating Backup"
                        print ""
                        cp -f $MODPATH/files/pixel.tar.xz /sdcard/Pixelify/backup/pixel.tar.xz
                        echo " - Creating Backup for Pixel Wallpapers" >> $logfile
                        echo "$LWVERSION" >> /sdcard/Pixelify/version/pixel.txt
                    else
                        print "!! Warning !!"
                        print " No internet detected"
                        print ""
                        print "- Using Old backup for now."
                        print ""
                        echo " - Using old Backup for Pixel Wallpapers due to no internet" >> $logfile
                    fi
                fi
            fi
            print "- Installing Pixel LiveWallpapers"
            print ""
            tar -xf /sdcard/Pixelify/backup/pixel.tar.xz -C $MODPATH/system$product
            pm install $MODPATH/system$product/priv-app/PixelLiveWallpaperPrebuilt/*.apk

            if [ $API -ge 31 ]; then
                rm -rf $MODPATH/system/product/app/PixelThemesStub/PixelThemesStub.apk
                mv $MODPATH/files/PixelThemesStub.apk $MODPATH/system/product/app/PixelThemesStub/PixelThemesStub.apk
            fi

            if [ $API -le 28 ]; then
                mv $MODPATH/system/overlay/Breel*.apk $MODPATH/vendor/overlay
                rm -rf $MODPATH/system/overlay
            fi
            install_wallpaper
			WALL_DID=1
        else
            echo " - Using old backup Pixel Wallpapers" >> $logfile
        fi
    else
        print "  (Network Connection Needed)"
        print "  Do you want to install and Download Pixel LiveWallpapers?"
        print "  Size: $LWSIZE"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        if $VKSEL; then
            online
            if [ $internet -eq 1 ]; then
                sed -i -e "s/Live=0/Live=1/g" $MODPATH/config.prop
                print "- Downloading Pixel LiveWallpapers"
                echo " - Downloading and Installing Pixel Wallpapers" >> $logfile
                ui_print ""
                cd $MODPATH/files
                $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pixel.tar.xz -O &> /proc/self/fd/$OUTFD
                cd /
                print ""
                print "- Installing Pixel LiveWallpapers"
                tar -xf $MODPATH/files/pixel.tar.xz -C $MODPATH/system$product
                pm install $MODPATH/system$product/priv-app/PixelLiveWallpaperPrebuilt/*.apk

                if [ $API -le 28 ]; then
                    mv $MODPATH/system/overlay/Breel*.apk $MODPATH/vendor/overlay
                    rm -rf $MODPATH/system/overlay
                fi
                REMOVE="$REMOVE $wall"
                ui_print ""
                print "  Do you want to create backup of Pixel LiveWallpapers?"
                print "  so that you don't need redownload it everytime."
                print "   Vol Up += Yes"
                print "   Vol Down += No"
                if $VKSEL; then
                    print "- Creating Backup"
                    mkdir -p /sdcard/Pixelify/backup
                    rm -rf /sdcard/Pixelify/backup/pixel.tar.xz
                    cp -f $MODPATH/files/pixel.tar.xz /sdcard/Pixelify/backup/pixel.tar.xz
                    print ""
                    mkdir /sdcard/Pixelify/version
                    echo " - Creating Backup for Pixel Wallpapers" >> $logfile
                    echo "$LWVERSION" >> /sdcard/Pixelify/version/pixel.txt
                    print " - Done"
                    print ""
                fi
                install_wallpaper
				WALL_DID=1
            else
                print "!! Warning !!"
                print " No internet detected"
                print ""
                print "- Skipping Pixel LiveWallpaper"
                print ""
                echo " - Skipping Pixel Wallpapers due to no internet" >> $logfile
            fi
        else
            echo " - Skipping Pixel Wallpapers" >> $logfile
        fi
    fi
fi

print "  Do you want to install Pixel Bootanimation?"
print "   Vol Up += Yes"
print "   Vol Down += No"
if $VKSEL; then
    echo " - Installing Pixel Bootanimation" >> $logfile
    if [ ! -f /system/bin/themed_bootanimation ]; then
        rm -rf $MODPATH/system$product/media/bootanimation.zip
        cp -f $MODPATH/system$product/media/bootanimation-dark.zip $MODPATH/system$product/media/bootanimation.zip
        echo " - Themed Animation not detected, using dark animation as default" >> $logfile
    fi
else
    echo " - Skipping Pixel Bootanimation" >> $logfile
    rm -rf $MODPATH/system$product/media/boot*.zip
fi

if [ $API -ge 29 ]; then
    PL=$(find /system -name *Launcher* | grep -v overlay | grep -v "\.")
    TR=$(find /system -name *Trebuchet* | grep -v overlay | grep -v "\.")
    QS=$(find /system -name *QuickStep* | grep -v overlay | grep -v "\.")
    if [ -f /sdcard/Pixelify/backup/pl-$API.tar.xz ]; then
        echo " - Backup Detected for Pixel Launcher" >> $logfile
        print "  Do you want to install Pixel Launcher?"
        print "  (Backup detected, no internet needed)"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        if $VKSEL; then
            REMOVE="$REMOVE $PL $TR $QS"
            if [ "$(cat /sdcard/Pixelify/version/pl-$API.txt)" != "$PLVERSION" ]; then
                echo " - New Version Backup Detected for Pixel Launcher" >> $logfile
                echo " - Old version:$(cat /sdcard/Pixelify/version/pl-$API.txt), New Version:  $PLVERSION " >> $logfile
                print "  (Network Connection Needed)"
                print "  New version Detected "
                print "  Do you Want to update or use Old Backup?"
                print "  Version: $PLVERSION"
                print "  Size: $PLSIZE"
                print "   Vol Up += Update"
                print "   Vol Down += Use old backup"
                if $VKSEL; then
                    online
                    if [ $internet -eq 1 ]; then
                        echo " - Downloading and Installing New Backup for Pixel Launcher" >> $logfile
                        rm -rf /sdcard/Pixelify/backup/pl-$API.tar.xz
                        rm -rf /sdcard/Pixelify/version/pl-$API.txt
                        cd $MODPATH/files
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pl-$API.tar.xz -O &> /proc/self/fd/$OUTFD
                        cd /
                        print "- Creating Backup"
                        print ""
                        cp -f $MODPATH/files/pl-$API.tar.xz /sdcard/Pixelify/backup/pl-$API.tar.xz
                        echo " - Creating Backup for Pixel Launcher" >> $logfile
                        echo "$PLVERSION" >> /sdcard/Pixelify/version/pl-$API.txt
                    else
                        print "!! Warning !!"
                        print " No internet detected"
                        print ""
                        print "- Using Old backup for now."
                        print ""
                        echo " - Using old Backup for Pixel Launcher due to no internet" >> $logfile
                    fi
                fi
            fi
            print "- Installing Pixel Launcher"
            print ""

            if [ $API -eq 31 ]; then
                tar -xf /sdcard/Pixelify/backup/pl-$API.tar.xz -C $MODPATH/system$product
            else
                tar -xf /sdcard/Pixelify/backup/pl-$API.tar.xz -C $MODPATH/system$product/priv-app
            fi
			
			if [ $WALL_DID -eq 0 ]; then
				install_wallpaper
			fi
        else
            echo " - Skipping Pixel Launcher" >> $logfile
            rm -rf $MODPATH/system/product/overlay/PixelLauncherOverlay.apk
        fi
    else
        print "  (Network Connection Needed)"
        print "  Do you want to install and Download Pixel Launcher?"
        print "  Size: $PLSIZE"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        if $VKSEL; then
            online
            if [ $internet -eq 1 ]; then
                print "- Downloading Pixel Launcher"
                echo " - Downloading and Installing Pixel Launcher" >> $logfile
                ui_print ""
                cd $MODPATH/files
                $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pl-$API.tar.xz -O &> /proc/self/fd/$OUTFD
                cd /
                print ""
                print "- Installing Pixel Launcher"
                if [ $API -eq 31 ]; then
                    tar -xf $MODPATH/files/pl-$API.tar.xz -C $MODPATH/system$product
                else
                    tar -xf $MODPATH/files/pl-$API.tar.xz -C $MODPATH/system$product/priv-app
                fi

                REMOVE="$REMOVE $PL $TR $QS"
                ui_print ""
                print "  Do you want to create backup of Pixel Launcher?"
                print "  so that you don't need redownload it everytime."
                print "   Vol Up += Yes"
                print "   Vol Down += No"
                if $VKSEL; then
                    print "- Creating Backup"
                    mkdir -p /sdcard/Pixelify/backup
                    rm -rf /sdcard/Pixelify/backup/pl-$API.tar.xz
                    cp -f $MODPATH/files/pl-$API.tar.xz /sdcard/Pixelify/backup/pl-$API.tar.xz
                    print ""
                    mkdir -p /sdcard/Pixelify/version
                    echo " - Creating Backup for Pixel Launcher" >> $logfile
                    echo "$PLVERSION" >> /sdcard/Pixelify/version/pl-$API.txt
                    print " - Done"
                    print ""
                fi
				
				if [ $WALL_DID -eq 0 ]; then
					install_wallpaper
				fi
            else
                print "!! Warning !!"
                print " No internet detected"
                print ""
                print "- Skipping Pixel launcher"
                print ""
                echo " - Skipping Pixel Launcher due to no internet" >> $logfile
                rm -rf $MODPATH/system/product/overlay/PixelLauncherOverlay.apk
            fi
        else
            echo " - Skipping Pixel Launcher" >> $logfile
            rm -rf $MODPATH/system/product/overlay/PixelLauncherOverlay.apk
        fi
    fi
else
    echo " - Skipping Pixel Launcher" >> $logfile
    rm -rf $MODPATH/system/product/overlay/PixelLauncherOverlay.apk
fi

if [ $API -ge 30 ]; then
    print "  Do you want to install Extreme Battery Saver (Flipendo)?"
    print "    Vol Up += Yes"
    print "    Vol Down += No"
    if $VKSEL; then
        print "- Installing Extreme Battery Saver (Flipendo)"
        echo " - Installing Extreme Battery Saver (Flipendo)" >> $logfile
        tar -xf $MODPATH/files/flip.tar.xz -C $MODPATH/system
        tar -xf $MODPATH/files/flip-$API.tar.xz -C $MODPATH/system
        if [ -f /system/system_ext/etc/selinux/system_ext_seapp_contexts ]; then
            flip=/system/system_ext/etc/selinux/system_ext_seapp_contexts
        elif [ -f /system_ext/etc/selinux/system_ext_seapp_contexts ]; then
            flip=/system_ext/etc/selinux/system_ext_seapp_contexts
        else
            flip=""
            echo "user=_app seinfo=platform name=com.google.android.flipendo domain=flipendo type=app_data_file levelFrom=all" >> $MODPATH/system/system_ext/etc/selinux/system_ext_seapp_contexts
        fi
        if [ ! -z "$flip" ]; then
            if [ -z "$(cat $flip | grep com.google.android.flipendo)" ]; then
                echo " - Adding Flipendo seapp_contexts" >> $logfile
                cp -r $flip $MODPATH/system/system_ext/etc/selinux/system_ext_seapp_contexts
                echo "user=_app seinfo=platform name=com.google.android.flipendo domain=flipendo type=app_data_file levelFrom=all" >> $MODPATH/system/system_ext/etc/selinux/system_ext_seapp_contexts
            fi
        fi
        FLIPENDO=$(find /system -name Flipendo)
        REMOVE="$REMOVE $FLIPENDO"
    else
        echo " - Skipping Extreme Battery Saver (Flipendo)" >> $logfile
    fi
fi

FIT=/data/data/com.google.android.apps.fitness/shared_prefs/growthkit_phenotype_prefs.xml
if [ -f $FIT ]; then
    print ""
    print " Google Fit is installed."
    print "- Enabling Heart rate Measurement "
    print "- Enabling Respiratory rate."
    bool_patch DeviceStateFeature $FIT
    bool_patch TestingFeature $FIT
    bool_patch Sync__sync_after_promo_shown $FIT
    bool_patch Sync__use_experiment_flag_from_promo $FIT
    bool_patch Promotions $FIT
    echo " - Patching Google Fit's bools" >> $logfile
fi

GBOARD=/data/data/com.google.android.inputmethod.latin/shared_prefs/flag_value.xml
if [ ! -z "$(pm list packages | grep com.google.android.inputmethod.latin)" ]; then
    ui_print ""
    print " GBoard is installed."
    print "- Enabling Smart Compose"
    print "- Enabling Redesigned Ui"
    print "- Enabling Lens for Gboard"
    print "- Enabling NGA Voice typing (If Nga is installed)"
    bool_patch nga $GBOARD
    bool_patch redesign $GBOARD
    bool_patch lens $GBOARD
    bool_patch generation $GBOARD
    bool_patch multiword $GBOARD
    bool_patch core_typing $GBOARD
    gboardflag="spellchecker_enable_language_trigger silk_on_all_pixel silk_on_all_devices nga_enable_undo_delete nga_enable_sticky_mic nga_enable_spoken_emoji_sticky_variant nga_enable_mic_onboarding_animation nga_enable_mic_button_when_dictation_eligible enable_next_generation_hwr_support enable_nga"
    for i in $gboardflag; do
        $sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.inputmethod.latin#com.google.android.inputmethod.latin' AND name='$i'"
        #$sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, boolVal, committed) VALUES('com.google.android.inputmethod.latin#com.google.android.inputmethod.latin', '', '$i', 0, 1, 0)"
        $sqlite $gms "UPDATE Flags SET boolVal='1' WHERE packageName='com.google.android.inputmethod.latin#com.google.android.inputmethod.latin' AND name='$i'"
    done
    echo " - Patching Google Keyboard's bools" >> $logfile
    if [ -z $(pm list packages -s com.google.android.inputmethod.latin) ] && [ -z "$(cat $pix/apps_temp.txt | grep gboard)" ]; then
        print ""
        print "- GBoard is not installed as a system app !!"
        print "- Making Gboard as a system app"
        echo " - Making Google Keyboard as system app" >> $logfile
        cp -r ~/$app/com.google.android.inputmethod.latin*/. $MODPATH/system/product/app/LatinIMEGooglePrebuilt
        mv $MODPATH/system/product/app/LatinIMEGooglePrebuilt/base.apk $MODPATH/system/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk
        rm -rf $MODPATH/system/product/app/LatinIMEGooglePrebuilt/oat
        #mv $MODPATH/files/privapp-permissions-com.google.android.inputmethod.latin.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.inputmethod.latin.xml
        echo "gboard" >> $pix/app2.txt
    elif [ ! -z "$(cat $pix/apps_temp.txt | grep gboard)" ]; then
        print ""
        print "- GBoard is not installed as a system app !!"
        echo " - Making Google Keyboard as system app" >> $logfile
        print "- Making Gboard as a system app"
        cp -r ~/$app/com.google.android.inputmethod.latin*/. $MODPATH/system/product/app/LatinIMEGooglePrebuilt
        mv $MODPATH/system/product/app/LatinIMEGooglePrebuilt/base.apk $MODPATH/system/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk
        rm -rf $MODPATH/system/product/app/LatinIMEGooglePrebuilt/oat
        #mv $MODPATH/files/privapp-permissions-com.google.android.inputmethod.latin.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.inputmethod.latin.xml
        echo "gboard" >> $pix/app2.txt
    fi
fi

if [ -d /data/data/com.google.android.apps.wellbeing ]; then
    pm enable com.google.android.apps.wellbeing/com.google.android.apps.wellbeing.walkingdetection.ui.WalkingDetectionActivity > /dev/null 2>&1
fi

set_perm_app() {
    out=$($MODPATH/addon/aapt d permissions $1)
    path="$(echo "$1" | sed 's/\/priv-app.*//')"
    name=$(echo $out | grep package: | cut -d' ' -f2)
    perm="$(echo $out | grep uses-permission:)"
    if [ ! -z "$perm" ]; then
        echo " - Generatings permission for package: $name" >> $logfile
        mkdir -p $path/etc/permissions
        echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<!--
	Generated by Pixelify Module
 -->" >> $path/etc/permissions/privapp_whitelist_$name.xml
        echo "<permissions>" >> $path/etc/permissions/privapp_whitelist_$name.xml
        echo "    <privapp-permissions package=\"${name}\">" >> $path/etc/permissions/privapp_whitelist_$name.xml
        for i in $perm; do
            s=$(echo $i | grep name= | cut -d= -f2 | sed "s/'/\"/g")
            if [ ! -z $s ]; then
                echo "        <permission name=$s/>" >> $path/etc/permissions/privapp_whitelist_$name.xml
            fi
        done
        echo "    </privapp-permissions>" >> $path/etc/permissions/privapp_whitelist_$name.xml
        echo " </permissions>" >> $path/etc/permissions/privapp_whitelist_$name.xml
        chmod 0644 $path/etc/permissions/privapp_whitelist_$name.xml
    fi
}

# Permissions for apps
for j in $MODPATH/system/*/priv-app/*/*.apk; do
    set_perm_app $j
done

for j in $MODPATH/system/priv-app/*/*.apk; do
    set_perm_app $j
done

REPLACE="$REMOVE"

chmod 0644 $MODPATH/system/vendor/overlay/*.apk
chmod 0644 $MODPATH/system$product/overlay/*.apk
chmod 0644 $MODPATH/system$product/priv-app/*/*.apk
chmod 0644 $MODPATH/system$product/app/*/*.apk
chmod 0644 $MODPATH/system$product/etc/permissions/*.xml
chmod 0644 $MODPATH/system/vendor/etc/permissions/*.xml

#Clean Up
rm -rf $MODPATH/files
rm -rf $MODPATH/spoof.prop
rm -rf $MODPATH/inc.prop

# Disable features as per API in service.sh
if [ $API -eq 31 ]; then
    rm -rf $MODPATH/system/product/overlay/PixelifyPixel.apk
    if [ $WREM -eq 1 ]; then
        rm -rf $MODPATH/system/product/priv-app/WallpaperPickerGoogleRelease
    fi
fi

if [ $API -le 30 ]; then
    rm -rf $MODPATH/system$product/overlay/PixeliflyPixelS.apk
fi

if [ $API -le 29 ]; then
    sed -i -e "s/device_config/#device_config/g" $MODPATH/service.sh
    sed -i -e "s/sleep/#sleep/g" $MODPATH/service.sh
    rm -rf $MODPATH/system$product/priv-app/SimpleDeviceConfig
fi

if [ $API -le 27 ]; then
    sed -i -e "s/bool_patch AdaptiveCharging__v1_enabled/#bool_patch AdaptiveCharging__v1_enabled/g" $MODPATH/service.sh
    rm -rf $MODPATH/system/vendor/overlay/PixeliflyPixelS.apk
fi

rm -rf $pix/apps_temp.txt
mv $pix/app2.txt $pix/app.txt

echo " ---- Installation Finished ----" >> $logfile

ui_print ""
print "- Done"
ui_print ""
