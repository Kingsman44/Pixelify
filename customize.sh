s_inc="SPB5.210812.002"
s_id="7671067"
s_change=0

if [ $ARCH != "arm64" ] && [ $API -le 23 ]; then
    ui_print "Error: Minimum requirements doesn't meet"
    ui_print "arch: ARM64"
    ui_print "android version: 7.0+"
    exit 1
fi

tar -xf $MODPATH/files/system.tar.xz -C $MODPATH

chmod 0755 $MODPATH/addon/*

id="$(grep ro.build.id $MODPATH/spoof.prop | cut -d'=' -f2)"
inc="$(grep ro.build.version.incremental $MODPATH/spoof.prop | cut -d'=' -f2)"

online() {
    s=$($MODPATH/addon/curl -s -I http://www.google.com --connect-timeout 5 | grep "ok")
    if [ ! -z "$s" ]; then
        internet=1
    else
        internet=0
    fi
}

online

pix=/data/pixelify
mkdir /sdcard/Pixelify

if [ ! -d $pix ]; then
    mkdir $pix
fi

if [ -f $pix/apps.txt ]; then
    rm -rf $pix/apps_temp.txt
    mv $pix/apps.txt $pix/apps_temp.txt
else
    touch $pix/apps_temp.txt
fi

DPVERSIONP=1
NGAVERSIONP=1
LWVERSIONP=1.3
NGASIZE="135 Mb"
LWSIZE="84 Mb"

if [ $API -ge 31 ]; then
    DPSIZE="17 Mb"
    DPVERSIONP=1
elif [ $API -eq 30 ]; then
    DPSIZE="20.1 Mb"
    DPVERSIONP=1.1
elif [ $API -eq 29 ]; then
    WSIZE="3.6 Mb"
    DPSIZE="15 Mb"
    DPVERSIONP=1
elif [ $API -eq 28 ]; then
    WSIZE="1.6 Mb"
    DPSIZE="10 Mb"
    DPVERSIONP=1
fi

if [ $internet -eq 1 ]; then
    ver=$($MODPATH/addon/curl -s https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/version.txt)
    NGAVERSION=$(echo "$ver" | grep nga | cut -d'=' -f2)
    LWVERSION=$(echo "$ver" | grep wallpaper | cut -d'=' -f2)
    DPVERSION=$(echo "$ver" | grep dp-$API | cut -d'=' -f2)
    rm -rf $pix/nga.txt
    rm -rf $pix/pixel.txt
    rm -rf $pix/dp.txt
    echo "$NGAVERSION" >> $pix/nga.txt
    echo "$LWVERSION" >> $pix/pixel.txt
    echo "$DPVERSION" >> $pix/dp.txt
    NGASIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/NgaResources.apk | grep -i Content-Length | cut -d':' -f2 | cut -c 2-4) Mb"
    LWSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pixel.tar.xz | grep -i Content-Length | cut -d':' -f2 | cut -c 2-3) Mb"
    DPSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/dp-$API.tar.xz | grep -i Content-Length | cut -d':' -f2 | cut -c 2-3) Mb"
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
fi

NGAVERSION=$(cat $pix/nga.txt)
LWVERSION=$(cat $pix/pixel.txt)
DPVERSION=$(cat $pix/dp.txt)

chmod -R 0755 $MODPATH/addon
chmod 0644 $MODPATH/files/*.xz
alias keycheck="$MODPATH/addon/keycheck"

if [ $API -le 28 ]; then
    cp -r $MODPATH/system/product/. $MODPATH/system
    cp -r $MODPATH/system/overlay/. $MODPATH/system/vendor/overlay
    rm -rf $MODPATH/system/overlay
    rm -rf $MODPATH/system/product
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
if [ $RAM -le "6291456" ]; then
    rm -rf $MODPATH/system$product/etc/sysconfig/GoogleCamera_6gb_or_more_ram.xml
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

keytest() {
    ui_print "- Vol Key Test"
    ui_print "    Press a Vol Key:"
    if (timeout 3 /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events); then
        return 0
    else
        ui_print "   Try again:"
        timeout 3 $MODPATH/addon/keycheck
        local SEL=$?
        [ $SEL -eq 143 ] && abort "   Vol key not detected!" || return 1
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
        return 0
    else
        return 1
    fi
}

chooseportold() {
    # Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
    # Calling it first time detects previous input. Calling it second time will do what we want
    while true; do
        $MODPATH/addon/keycheck
        $MODPATH/addon/keycheck
        local SEL=$?
        if [ "$1" == "UP" ]; then
            UP=$SEL
            break
        elif [ "$1" == "DOWN" ]; then
            DOWN=$SEL
            break
        elif [ $SEL -eq $UP ]; then
            return 0
        elif [ $SEL -eq $DOWN ]; then
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

curid="$(getprop ro.build.id)"
if [ "$curid" != "$id" ]; then
    if [ ! -z "$(grep $curid $MODPATH/inc.prop | head -1)" ]; then
        newinc=$(grep $curid $MODPATH/inc.prop | head -1 | cut -d'=' -f2)
        sed -i -e "s/${id}/${curid}/g" $MODPATH/spoof.prop
        sed -i -e "s/${inc}/${newinc}/g" $MODPATH/spoof.prop
        id=$curid
        inc=$newinc
        s_change=1
    fi
fi

if [ ! -z "$(getprop ro.rom.version | grep Oxygen)" ] || [ ! -z "$(getprop ro.miui.ui.version.code)" ]; then
    while read p; do
        if [ ! -z "$(echo $p | grep vendor)" ]; then
            sed -i -e "s/${p}/#${p}/g" $MODPATH/spoof.prop
        fi
    done <$MODPATH/spoof.prop
fi

if [ $API -eq 26 ]; then
    sed -i -e "s/:11/:8.0.0/g" $MODPATH/spoof.prop
    sed -i -e "s/redfin/walleye/g" $MODPATH/spoof.prop
    sed -i -e "s/Pixel 5/Pixel 2/g" $MODPATH/spoof.prop
    sed -i -e "s/${id}/OPD1.170816.025/g" $MODPATH/spoof.prop
    sed -i -e "s/${inc}/4424668/g" $MODPATH/spoof.prop
elif [ $API -eq 27 ]; then
    sed -i -e "s/:11/:8.1.0/g" $MODPATH/spoof.prop
    sed -i -e "s/redfin/walleye/g" $MODPATH/spoof.prop
    sed -i -e "s/Pixel 5/Pixel 2/g" $MODPATH/spoof.prop
    sed -i -e "s/${id}/OPM2.171026.006.G1/g" $MODPATH/spoof.prop
    sed -i -e "s/${inc}/4820017/g" $MODPATH/spoof.prop
elif [ $API -eq 28 ]; then
    sed -i -e "s/:11/:9/g" $MODPATH/spoof.prop
    sed -i -e "s/redfin/blueline/g" $MODPATH/spoof.prop
    sed -i -e "s/Pixel 5/Pixel 3/g" $MODPATH/spoof.prop
    sed -i -e "s/${id}/PQ3A.190801.002/g" $MODPATH/spoof.prop
    sed -i -e "s/${inc}/5670241/g" $MODPATH/spoof.prop
elif [ $API -eq 29 ]; then
    sed -i -e "s/:11/:10/g" $MODPATH/spoof.prop
    sed -i -e "s/redfin/coral/g" $MODPATH/spoof.prop
    sed -i -e "s/Pixel 5/Pixel 4 XL/g" $MODPATH/spoof.prop
    sed -i -e "s/${id}/QQ3A.200805.001/g" $MODPATH/spoof.prop
    sed -i -e "s/${inc}/6578210/g" $MODPATH/spoof.prop
elif [ $API -eq 31 ]; then
    sed -i -e "s/:11/:12/g" $MODPATH/spoof.prop
    if [ $s_change -eq 0 ]; then
        sed -i -e "s/${id}/${s_id}/g" $MODPATH/spoof.prop
        sed -i -e "s/${inc}/${s_inc}/g" $MODPATH/spoof.prop
    fi
fi

print ""
print "  Do you want to Spoof your device to $(grep ro.product.system.model $MODPATH/spoof.prop | cut -d'=' -f2) $(grep ro.product.system.device $MODPATH/spoof.prop | cut -d'=' -f2 )?"
if [ $API -ge 29 ]; then
    print "  Needed for Next Generation Assistant Continued Conversation"
fi
print "   Vol Up += Yes"
print "   Vol Down += No"

if $VKSEL; then
    cat $MODPATH/spoof.prop >> $MODPATH/system.prop
fi

DPAS=1
if [ $API -ge 30 ] && [ ! -z $($MODPATH/addon/dumpsys package com.google.android.as | grep versionName | grep pixel5) ] && [ -z $(cat $pix/app_temp.txt | grep 'dp-$API') ]; then
    DPAS=0
elif [ ! -z $(pm list packages -s | grep com.google.android.as) ] && [ ! -z $(cat $pix/app_temp.txt | grep 'dp-$API') ]; then
    DPAS=0
fi

if [ $API -le 27 ]; then
    DPAS=0
fi

if [ $DPAS -eq 1 ]; then
    if [ -f /sdcard/Pixelify/backup/dp-$API.tar.xz ]; then
        REMOVE="$REMOVE $DP"
        if [ "$(cat /sdcard/Pixelify/version/dp.txt)" != "$DPVERSION_$API" ]; then
            ui_print ""
            print " - Installing Device Personalistaion Services"
            ui_print ""
            print "  (Network Connection Needed)"
            print "  New version Detected of Device Personalistaion Services"
            print "  Do you Want to update or use Old Backup?"
            print "  Version: $DPVERSION"
            print "  Size: $DPSIZE"
            print "   Vol Up += Yes"
            print "   Vol Down += No"
            if $VKSEL; then
                online
                if [ $internet -eq 1 ]; then
                    rm -rf /sdcard/Pixelify/backup/dp-$API.tar.xz
                    rm -rf /sdcard/Pixelify/version/dp.txt
                    cd $MODPATH/files
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
                fi
            fi
        fi
        print ""
        print "- Installing Device Personalisation Services"
        print ""
        tar -xf /sdcard/Pixelify/backup/dp-$API.tar.xz -C $MODPATH/system$product/priv-app
        echo dp-$API > $pix/app.txt
    else
        ui_print ""
        print "  (Network Connection Needed)"
        print "  Do you want to install and Download Device Personalisation Services?"
        print "  Size: $DPSIZE"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        ui_print ""
        if $VKSEL; then
            online
            if [ $internet -eq 1 ]; then
                print "- Downloading Device Personalisation Services"
                ui_print ""
                cd $MODPATH/files
                $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/dp-$API.tar.xz -O &> /proc/self/fd/$OUTFD
                cd /
                print ""
                print "- Installing Device Personalisation Services"
                tar -xf $MODPATH/files/dp-$API.tar.xz -C $MODPATH/system$product/priv-app
                echo dp-$API > $pix/app.txt
                REMOVE="$REMOVE $DP"

                ui_print ""
                print "  Do you want to create backup of Device Personalisation Services?"
                print "  so that you don't need redownload it everytime."
                print "   Vol Up += Yes"
                print "   Vol Down += No"
                if $VKSEL; then
                    ui_print ""
                    print "- Creating Backup"
                    mkdir -p /sdcard/Pixelify/backup
                    rm -rf /sdcard/Pixelify/backup/dp-$API.tar.xz
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
            fi
        fi
    fi
fi

if [ -d /data/data/$DIALER ]; then
    print "  Do you want to install Call Screening & Call Recording?"
    print "    Vol Up += Yes"
    print "    Vol Down += No"
    print ""
    if $VKSEL; then
		AP=/vendor/etc/audio_policy_configuration.xml
        DIALER_PREF=/data/data/com.google.android.dialer/shared_prefs/dialer_phenotype_flags.xml
        sed -i -e "s/CallScreening=0/CallScreening=1/g" $MODPATH/config.prop
        print "- Enabling Call Screening"
        print " "
        print "- Enabling Call Recording (Working is device dependent)"
        setprop sys.persist.locale en-US
        print " "
        print "- Please set your launguage to English (United States) for call screening"
        print " "
        device="$(getprop ro.product.device)"
        device_len=${#device}

        carr="$(getprop gsm.sim.operator.numeric)"
        carrier=${#carr}
        case $carrier in
            6)
                sed -i -e "s/310004/${carr}/g" $MODPATH/files/$DIALER
                ;;
            5)
                sed -i -e "s/21403/${carr}/g" $MODPATH/files/$DIALER
                ;;
        esac

        if [ -z "$(cat $MODPATH/recording.txt | grep $device)" ]; then
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
                    print "  needs to set (redfin)"
                    print "  Do you Wish to Install Google Dialer Call Recording?"
                    print "    Vol Up += Yes"
                    print "    Vol Down += No"
                    if $VKSEL; then
                        echo "ro.product.device=redfin" >> $MODPATH/system.prop
                    fi
                    ;;
            esac
        fi
		
		if [ -z "$(grep call_screen_mode_supported $AP)'" ]; then
			mkdir -p $MODPATH/system/vendor/etc
			cp -f $AP $MODPATH/system/vendor/etc/audio_policy_configuration.xml
			sed -i -e "s/speaker_drc_enabled=\"true\"/speaker_drc_enabled=\"true\" call_screen_mode_supported=\"true\"/g" $MODPATH/system/vendor/etc/audio_policy_configuration.xml
		fi
		
		echo "vendor.audio.feature.incall_music.enable=true" $MODPATH/system.prop

        # Remove old prompt to replace to use within overlay
        rm -rf /data/data/com.google.android.dialer/files/callrecordingprompt

        cp -Tf $MODPATH/files/$DIALER $MODPATH/$DIALER
        cp -Tf $MODPATH/files/$DIALER /data/data/com.google.android.dialer/files/phenotype/$DIALER
        am force-stop $DIALER

        bool_patch speak_easy $DIALER_PREF
        bool_patch speakeasy $DIALER_PREF
        bool_patch call_screen $DIALER_PREF
        bool_patch revelio $DIALER_PREF
        bool_patch record $DIALER_PREF
        bool_patch atlas $DIALER_PREF

        if [ -z $(pm list packages -s $DIALER) ] && [ ! -f /data/adb/modules/Pixelify/system/product/priv-app/GoogleDialer/GoogleDialer.apk ]; then
            print ""
            print "- Google Dialer is not installed as a system app !!"
            print "- Making Google Dialer as a system app"
            print ""
            cp -r ~/$app/com.google.android.dialer*/. $MODPATH/system$product/priv-app/GoogleDialer
            mv $MODPATH/system$product/priv-app/GoogleDialer/base.apk $MODPATH/system$product/priv-app/GoogleDialer/GoogleDialer.apk
            rm -rf $MODPATH/system$product/priv-app/GoogleDialer/oat
        elif [ -f /data/adb/modules/Pixelify/system/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk ]; then
            print ""
            print "- Google Dialer is not installed as a system app !!"
            print "- Making Google Dialer as a system app"
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
    print "   Vol Up += Yes"
    print "   Vol Down += No"
    ui_print ""
    if $VKSEL; then
        sed -i -e "s/Assistant=0/Assistant=1/g" $MODPATH/config.prop
        if [ -f /sdcard/Pixelify/backup/NgaResources.apk  ]; then
            if [ "$(cat /sdcard/Pixelify/version/nga.txt)" != "$NGAVERSION" ]; then
                print "  (Network Connection Needed)"
                print "  New version Detected."
                print "  Do you Want to update or use Old Backup?"
                print "  Version: $NGAVERSION"
                print "  Size: $NGASIZE"
                print "   Vol Up += Yes"
                print "   Vol Down += No"
                ui_print ""
                if $VKSEL; then
                    online
                    if [ $internet -eq 1 ]; then
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
                    fi
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
            ui_print ""
            if $VKSEL; then
                online
                if [ $internet -eq 1 ]; then
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
                    print ""
                    if $VKSEL; then
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
                fi
            fi
        fi

        print "- Patching Next Generation Assistant Files.."
        print ""
        name=$(grep current_account_name /data/data/com.android.vending/shared_prefs/account_shared_prefs.xml | cut -d">" -f2 | cut -d"<" -f1)
        f1=$(grep 12490 $GOOGLE_PREF | cut -d'>' -f2 | cut -d'<' -f1)
        f2=$(grep 12491 $GOOGLE_PREF | cut -d'>' -f2 | cut -d'<' -f1)
        if [ ! -z $name ]; then
            string_patch GSAPrefs.google_account $name $MODPATH/files/GEL.GSAPrefs.xml
        fi
        if [ ! -z $f1 ]; then
            string_patch 12490 "$f1" $MODPATH/files/GEL.GSAPrefs.xml
        fi
        if [ ! -z $f2 ]; then
            string_patch 12491 "$f2" $MODPATH/files/GEL.GSAPrefs.xml
        fi
        cp -f $MODPATH/files/GEL.GSAPrefs.xml $MODPATH/GEL.GSAPrefs.xml
        chmod 0771 /data/data/com.google.android.googlequicksearchbox/shared_prefs
        rm -rf $GOOGLE_PREF
        rm -rf /data/data/com.google.android.googlequicksearchbox/cache/*

        if [ -z $(pm list packages -s com.google.android.googlequicksearchbox | grep -v nga) ] && [ ! -f /data/adb/modules/Pixelify/system/product/priv-app/Velvet/Velvet.apk ]; then
            print "- Google is not installed as a system app !!"
            print "- Making Google as a system app"
            print ""
            cp -r ~/$app/com.google.android.googlequicksearchbox*/. $MODPATH/system/product/priv-app/Velvet
            mv $MODPATH/system/product/priv-app/Velvet/base.apk $MODPATH/system/product/priv-app/Velvet/Velvet.apk
            rm -rf $MODPATH/system/product/priv-app/Velvet/oat
            mv $MODPATH/files/privapp-permissions-com.google.android.googlequicksearchbox.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.googlequicksearchbox.xml
        elif [ -f /data/adb/modules/Pixelify/system/product/priv-app/Velvet/Velvet.apk ]; then
            print "- Google is not installed as a system app !!"
            print "- Making Google as a system app"
            print ""
            cp -r ~/$app/com.google.android.googlequicksearchbox*/. $MODPATH/system/product/priv-app/Velvet
            mv $MODPATH/system/product/priv-app/Velvet/base.apk $MODPATH/system/product/priv-app/Velvet/Velvet.apk
            rm -rf $MODPATH/system/product/priv-app/Velvet/oat
            mv $MODPATH/files/privapp-permissions-com.google.android.googlequicksearchbox.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.googlequicksearchbox.xml
        fi
    fi
fi

wall=$(find /system -name WallpaperPickerGoogle*.apk)
if [ $API -ge 28 ]; then
    if [ -f /sdcard/Pixelify/backup/pixel.tar.xz ]; then
        print "  Do you want to install Pixel Live Wallpapers?"
        print "  (Backup detected, no internet needed)"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        ui_print ""
        if $VKSEL; then
            REMOVE="$REMOVE $wall"
            if [ "$(cat /sdcard/Pixelify/version/pixel.txt)" != "$LWVERSION" ]; then
                print "  (Network Connection Needed)"
                print "  New version Detected "
                print "  Do you Want to update or use Old Backup?"
                print "  Version: $LWVERSION"
                print "  Size: $LWSIZE"
                print "   Vol Up += Yes"
                print "   Vol Down += No"
                ui_print ""
                if $VKSEL; then
                    online
                    if [ $internet -eq 1 ]; then
                        rm -rf /sdcard/Pixelify/backup/pixel.tar.xz
                        rm -rf /sdcard/Pixelify/version/pixel.txt
                        cd $MODPATH/files
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pixel.tar.xz -O &> /proc/self/fd/$OUTFD
                        cd /
                        print "- Creating Backup"
                        print ""
                        cp -f $MODPATH/files/pixel.tar.xz /sdcard/Pixelify/backup/pixel.tar.xz
                        echo "$LWVERSION" >> /sdcard/Pixelify/version/pixel.txt
                    else
                        print "!! Warning !!"
                        print " No internet detected"
                        print ""
                        print "- Using Old backup for now."
                        print ""
                    fi
                fi
            fi
            print "- Installing Pixel LiveWallpapers"
            print ""
            tar -xf /sdcard/Pixelify/backup/pixel.tar.xz -C $MODPATH/system$product

            if [ $API -ge 28 ]; then
                mv $MDOPATH/files/PixelifyWallpaper.apk $MODPATH/system/product/overlay/PixelifyWallpaper.apk
                mkdir -p $MODPATH/system/product/app/PixelifyThemesStub
                mv $MDOPATH/files/PixelifyThemesStub.apk $MODPATH/system/product/app/PixelifyThemesStub/PixelifyThemesStub.apk
            fi

            if [ $API -le 28 ]; then
                mv $MODPATH/system/overlay/Breel*.apk $MODPATH/vendor/overlay
                rm -rf $MODPATH/system/overlay
            fi

            if [ $API -le 29 ] && [ $API -ge 28 ]; then
                if [ -f /sdcard/Pixelify/backup/wpg-$API.tar.xz ]; then
                    print "  (Network Connection Needed)"
                    print "  Do you want to Download Google Styles and Wallpapers?"
                    print "  Size: $WSIZE"
                    print "   Vol Up += Yes"
                    print "   Vol Down += No"
                    print ""
                    if $VKSEL; then
                        online
                        if [ $internet -eq 1 ]; then
                            print "- Downloading Styles and Wallpapers"
                            cd $MODPATH/files
                            $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/wpg-$API.tar.xz -O &> /proc/self/fd/$OUTFD
                            cd /
                            rm -rf $MODPATH/system$product/priv-app/WallpaperPickerGoogleRelease
                            tar -xf $MODPATH/files/gwp-$API.tar.xz -C $MODPATH/system$product/priv-app
                            print ""
                            print "  Do you want to Create backups of Styles and Wallpapers?"
                            print "   Vol Up += Yes"
                            print "   Vol Down += No"
                            print ""
                            if $VKSEL; then
                                cp -f $MODPATH/files/gwp-$API.tar.xz /sdcard/Pixelify/backup/gwp-$API.tar.xz
                            fi
                        fi
                    fi
                else
                    rm -rf $MODPATH/system$product/priv-app/WallpaperPickerGoogleRelease
                    tar -xf /sdcard/Pixelify/backup/gwp-$API.tar.xz -C $MODPATH/system$product/priv-app
                fi
            fi
        fi
    else
        print "  (Network Connection Needed)"
        print "  Do you want to install and Download Pixel LiveWallpapers?"
        print "  Size: $LWSIZE"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        ui_print ""
        if $VKSEL; then
            online
            if [ $internet -eq 1 ]; then
                print "- Downloading Pixel LiveWallpapers"
                ui_print ""
                cd $MODPATH/files
                $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pixel.tar.xz -O &> /proc/self/fd/$OUTFD
                cd /
                print ""
                print "- Installing Pixel LiveWallpapers"
                tar -xf $MODPATH/files/pixel.tar.xz -C $MODPATH/system$product
                if [ $API -le 29 ]; then
                    print ""
                    print "- Downloading Styles and Wallpapers"
                    cd $MODPATH/files
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/wpg-$API.tar.xz -O &> /proc/self/fd/$OUTFD
                    cd /
                    rm -rf $MODPATH/system$product/priv-app/WallpaperPickerGoogleRelease
                    tar -xf $MODPATH/files/wpg-$API.tar.xz -C $MODPATH/system$product/priv-app
                fi

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
                    ui_print ""
                    print "- Creating Backup"
                    mkdir -p /sdcard/Pixelify/backup
                    rm -rf /sdcard/Pixelify/backup/pixel.tar.xz
                    cp -f $MODPATH/files/pixel.tar.xz /sdcard/Pixelify/backup/pixel.tar.xz
                    print ""
                    if [ $API -le 29 ]; then
                        cp -f $MODPATH/files/gwp-$API.tar.xz /sdcard/Pixelify/backup/gwp-$API.tar.xz
                    fi
                    mkdir /sdcard/Pixelify/version
                    echo "$LWVERSION" >> /sdcard/Pixelify/version/pixel.txt
                    print " - Done"
                    print ""
                fi
            else
                print "!! Warning !!"
                print " No internet detected"
                print ""
                print "- Skipping Pixel LiveWallpaper"
                print ""
            fi
        fi
    fi
fi

print "  Do you want to install PixelBootanimation?"
print "   Vol Up += Yes"
print "   Vol Down += No"
if $VKSEL; then
    if [ ! -f /system/bin/themed_bootanimation ]; then
        rm -rf $MODPATH/system$product/media/bootanimation.zip
        mv $MODPATH/system$product/media/bootanimation-dark.zip $MODPATH/system$product/media/bootanimation.zip
    fi
else
    rm -rf $MODPATH/system$product/media/boot*.zip
fi

if [ $API -ge 29 ]; then
    ui_print ""
    print "  Do you want to install Pixel Launcher?"
    print "   Vol Up += Yes"
    print "   Vol Down += No"
    if $VKSEL; then
        tar -xf $MODPATH/files/pl-$API.tar.xz -C $MODPATH/system/product/priv-app
        mv $MODPATH/files/privapp-permissions-com.google.android.apps.nexuslauncher.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.apps.nexuslauncher.xml
        PL=$(find /system -name *Launcher* | grep -v overlay | grep -v "\.")
        TR=$(find /system -name *Trebuchet* | grep -v overlay | grep -v "\.")
        QS=$(find /system -name *QuickStep* | grep -v overlay | grep -v "\.")
        REMOVE="$REMOVE $PL $TR $QS"
    else
        rm -rf $MODPATH/system/product/overlay/PixelLauncherOverlay.apk
    fi
else
    rm -rf $MODPATH/system/product/overlay/PixelLauncherOverlay.apk
fi

if [ $API -eq 30 ]; then
    print ""
    print "  Do you want to install Extreme Battery Saver (Flipendo)?"
    print "    Vol Up += Yes"
    print "    Vol Down += No"
    if $VKSEL; then
        print ""
        print "- Installing Extreme Battery Saver (Flipendo)"
        tar -xf $MODPATH/files/flip.tar.xz -C $MODPATH/system
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
                cp -r $flip $MODPATH/system/system_ext/etc/selinux/system_ext_seapp_contexts
                echo "user=_app seinfo=platform name=com.google.android.flipendo domain=flipendo type=app_data_file levelFrom=all" >> $MODPATH/system/system_ext/etc/selinux/system_ext_seapp_contexts
            fi
        fi
        FLIPENDO=$(find /system -name Flipendo)
        REMOVE="$REMOVE $FLIPENDO"
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
    if [ -z $(pm list packages -s com.google.android.inputmethod.latin) ] && [ -z "$(cat $pix/app_temp.txt | grep gboard)" ]; then
        print ""
        print "- GBoard is not installed as a system app !!"
        print "- Making Gboard as a system app"
        cp -r ~/$app/com.google.android.inputmethod.latin*/. $MODPATH/system/product/app/LatinIMEGooglePrebuilt
        mv $MODPATH/system/product/app/LatinIMEGooglePrebuilt/base.apk $MODPATH/system/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk
        rm -rf $MODPATH/system/product/app/LatinIMEGooglePrebuilt/oat
        mv $MODPATH/files/privapp-permissions-com.google.android.inputmethod.latin.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.inputmethod.latin.xml
        echo "gboard" >> $pix/app.txt
    elif [ ! -z "$(cat $pix/app_temp.txt | grep gboard)" ]; then
        print ""
        print "- GBoard is not installed as a system app !!"
        print "- Making Gboard as a system app"
        cp -r ~/$app/com.google.android.inputmethod.latin*/. $MODPATH/system/product/app/LatinIMEGooglePrebuilt
        mv $MODPATH/system/product/app/LatinIMEGooglePrebuilt/base.apk $MODPATH/system/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk
        rm -rf $MODPATH/system/product/app/LatinIMEGooglePrebuilt/oat
        mv $MODPATH/files/privapp-permissions-com.google.android.inputmethod.latin.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.inputmethod.latin.xml
        echo "gboard" >> $pix/app.txt
    fi
fi

if [ -d /data/data/com.google.android.apps.wellbeing ]; then
    pm enable com.google.android.apps.wellbeing/com.google.android.apps.wellbeing.walkingdetection.ui.WalkingDetectionActivity > /dev/null 2>&1
fi

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
    rm -rf $MODPATH/system/product/priv-app/WallpaperPickerGoogleRelease
fi

if [ $API -le 29 ]; then
    sed -i -e "s/device_config/#device_config/g" $MODPATH/service.sh
    sed -i -e "s/sleep/#sleep/g" $MODPATH/service.sh
    rm -rf $MODPATH/system$product/priv-app/SimpleDeviceConfig
fi

if [ $API -le 27 ]; then
    sed -i -e "s/bool_patch AdaptiveCharging__v1_enabled/#bool_patch AdaptiveCharging__v1_enabled/g" $MODPATH/service.sh
fi

rm -rf /sdcard/Pixelify/logs.txt
rm -rf $pix/apps_temp.txt

ui_print ""
print "- Done"
ui_print ""
