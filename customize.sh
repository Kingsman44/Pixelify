pixel_spoof=0

BETA_BUILD=1
ENABLE_OSR=1

if [ $ARCH != "arm64" ] && [ $API -le 23 ]; then
    ui_print "Error: Minimum requirements doesn't meet"
    ui_print "arch: ARM64"
    ui_print "android version: 7.0+"
    exit 1
fi

if [ ! -f $MODPATH/addon/curl ]; then
    mkdir -p $MODPATH/addon
    cp -f /system/bin/curl $MODPATH/addon/curl
    cp -f /system/bin/sqlite3 $MODPATH/addon/sqlite3
    cp -f /system/bin/curl $MODPATH/addon/curl
    cp -f /system/bin/dumpsys $MODPATH/addon/dumpsys
    chmod 0755 $MODPATH/addon/*
fi

ASI_PERM="android.permission.CAPTURE_MEDIA_OUTPUT
android.permission.MODIFY_AUDIO_ROUTING
android.permission.CAPTURE_VOICE_COMMUNICATION_OUTPUT
android.permission.CAPTURE_AUDIO_OUTPUT
android.permission.MODIFY_AUDIO_SETTINGS
android.permission.RECORD_AUDIO
android.permission.START_ACTIVITIES_FROM_BACKGROUND
android.permission.WRITE_SECURE_SETTINGS
android.permission.CAMERA
android.permission.READ_DEVICE_CONFIG
android.permission.UPDATE_DEVICE_STATS
android.permission.SUBSTITUTE_NOTIFICATION_APP_NAME
android.permission.SYSTEM_CAMERA
android.permission.FOREGROUND_SERVICE
android.permission.MODIFY_PHONE_STATE
android.permission.CONTROL_INCALL_EXPERIENCE
android.permission.READ_PHONE_STATE
android.permission.SYSTEM_APPLICATION_OVERLAY
android.permission.QUERY_ALL_PACKAGES
android.permission.REQUEST_NOTIFICATION_ASSISTANT_SERVICE
android.permission.ACCESS_COARSE_LOCATION
android.permission.ACCESS_BACKGROUND_LOCATION
android.permission.BLUETOOTH_ADMIN
android.permission.MANAGE_APP_PREDICTIONS
android.permission.ACCESS_WIFI_STATE
android.permission.ACCESS_FINE_LOCATION
android.permission.PACKAGE_USAGE_STATS
android.permission.ACCESS_SHORTCUTS
android.permission.UNLIMITED_SHORTCUTS_API_CALLS
android.permission.READ_CALL_LOG
android.permission.READ_CONTACTS
android.permission.READ_SMS
com.google.android.apps.nexuslauncher.permission.HOTSEAT_EDU
android.permission.MANAGE_SEARCH_UI
android.permission.MANAGE_SMARTSPACE
android.permission.WAKE_LOCK
android.permission.READ_PEOPLE_DATA
android.permission.READ_GLOBAL_APP_SEARCH_DATA
android.permission.BLUETOOTH_CONNECT
android.permission.BLUETOOTH_SCAN
android.permission.MANAGE_MUSIC_RECOGNITION
android.permission.VIBRATE
android.permission.OBSERVE_SENSOR_PRIVACY
android.permission.RECEIVE_BOOT_COMPLETED
com.google.android.ambientindication.permission.AMBIENT_INDICATION
android.permission.CAPTURE_AUDIO_HOTWORD
android.permission.MANAGE_SOUND_TRIGGER
android.permission.ACCESS_NETWORK_STATE
android.permission.LOCATION_HARDWARE
android.permission.EXEMPT_FROM_AUDIO_RECORD_RESTRICTIONS
com.google.android.setupwizard.SETUP_COMPAT_SERVICE
android.permission.READ_EXTERNAL_STORAGE
com.android.alarm.permission.SET_ALARM
android.permission.MANAGE_UI_TRANSLATION
android.permission.READ_OEM_UNLOCK_STATE"

ASI_OS_PERM="android.permission.INTERNET
android.permission.READ_DEVICE_CONFIG
android.permission.RECEIVE_BOOT_COMPLETED
android.permission.ACCESS_NETWORK_STATE
android.permission.ACCESS_WIFI_STATE
android.permission.CHANGE_WIFI_STATE"

overide_spoof="org.pixelexperience.device
org.evolution.device
ro.bliss.device
ro.cherish.device
ro.lighthouse.device
ro.ssos.device
ro.spark.device"

exact_prop=""

for i in $overide_spoof; do
    if [ ! -z $i ]; then
        kkk="$(getprop $i)"
        if [ ! -z $kkk ] || [ $kkk == "redfin" ]; then
            exact_prop="$i"
            break
        fi
    fi
done

if [ -z $exact_prop ] && [ ! -z "$(getprop ro.crdroid.build.version)" ]; then
    exact_prop="ro.product.device"
fi

logfile=/sdcard/Pixelify/logs.txt
rm -rf $logfile

echo "=============
   Pixelify $(cat $MODPATH/module.prop | grep version= | cut -d= -f2)
   SDK version: $API
=============
---- Installation Logs Started ----
" >> $logfile

touch $MODPATH/grant

tar -xf $MODPATH/files/system.tar.xz -C $MODPATH

chmod 0755 $MODPATH/addon/*

FIRST_ONLINE_TIME=0
FORCED_ONLINE=0
SPDB="/data/data/com.google.android.as/databases/superpacks.db"

online() {
    s=$($MODPATH/addon/curl -s -I http://www.google.com --connect-timeout 5 | grep "ok")
    if [ ! -z "$s" ]; then
        internet=1
        echo " - Network is Online" >> $logfile
    elif [ $FORCED_ONLINE -eq 1 ]; then
        internet=1
        echo " - Network is forced to be online" >> $logfile
    elif [ $FIRST_ONLINE_TIME -eq 1 ]; then
        FIRST_ONLINE_TIME=0
        print ""
        print "  (INTERNET NOT DETECTED)"
        print "  If you think this is error of module, you force enable to detect"
        print "  internet is on."
        print "  Note: If you are not connected to internet please"
        print "  don't force enable it."
        print ""
        print "   Vol Up += Force Enable internet"
        print "   Vol Down += Default settings"
        no_vk "FORCE_ENABLE_ONLINE"
        if $VKSEL; then
            FORCED_ONLINE=1
            internet=1
        fi
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
if [ $ENABLE_OSR -eq 1 ]; then
    NGAVERSIONP=1.3
else
    NGAVERSIONP=1.2 
fi
LWVERSIONP=1.6
PLVERSIONP=1
NGASIZE="13.6 Mb"
LWSIZE="108 Mb"
PLSIZE="5 Mb"
WNEED=0
SEND_DPS=0
OSRVERSIONP=1
OSRSIZE="172 Mb"
NEW_PL=0

sec_patch="$(getprop ro.build.version.security_patch)"
if [ $(echo $sec_patch | cut -d- -f1) -ge 2022 ] && [ $API -ge 31 ]; then
    NEW_PL=1
elif [ $(echo $sec_patch | cut -d- -f1) -eq 2021 ] && [ $(echo $sec_patch | cut -d- -f2) -ge 12 ] && [ $API -ge 31 ]; then
    NEW_PL=1
fi

NEWAPI=$API

echo "
- Device info -
Codename: $(getprop ro.product.vendor.name)
Model: $(getprop ro.product.vendor.model)
security patch: $sec_patch
Magisk version: $MAGISK_VER_CODE" >> $logfile

PCSSIZE="15 Mb"
PCSVERSION=1

if [ $API -eq 32 && "$(getprop ro.build.version.security_patch)" == "Tiramisu" ]; then
	echo "Android version: 13" >> $logfile
	WNEED=1
	NEWAPI=33
	WSIZE="2.2 Mb"
	PLSIZE="11 Mb"
	PLVERSIONP=1
elif [ $API -eq 32 ]; then
	echo "Android version: 12.1 (12L)" >> $logfile
	WNEED=1
	WSIZE="2.2 Mb"
	PLSIZE="11 Mb"
	PLVERSIONP=1
elif [ $API -eq 31 ]; then
	echo "Android version: 12 (S)" >> $logfile
    DPSIZE="51 Mb"
    DPVERSIONP=2.0
    WSIZE="2.0 Mb"
    WNEED=1
    if [ $NEW_PL -eq 1 ]; then
        PLVERSIONP=2.1
    else
        PLVERSIONP=1.3
    fi
    PLSIZE="11 Mb"
elif [ $API -eq 30 ]; then
	echo "Android version: 11 (R)" >> $logfile
    DPSIZE="20 Mb"
    DPVERSIONP=1.2
    WSIZE="2.1 Mb"
    WNEED=1
elif [ $API -eq 29 ]; then
	echo "Android version: 10 (Q)" >> $logfile
    WSIZE="3.6 Mb"
    DPSIZE="15 Mb"
    DPVERSIONP=1
    WNEED=1
elif [ $API -eq 28 ]; then
	echo "Android version: 9 (Pie)" >> $logfile
    WSIZE="1.6 Mb"
    DPSIZE="10 Mb"
    DPVERSIONP=1
    WNEED=1
fi

echo " - Device info -
" >> $logfile

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
	echo "- Fetching version of online packages" >> $logfile
    ver=$($MODPATH/addon/curl -s https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/version.txt)
    if [ $ENABLE_OSR -eq 1 ]; then
        NGAVERSION=$(echo "$ver" | grep ngsa | cut -d'=' -f2)
        NGASIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/nga-new.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
    else
        NGAVERSION=$(echo "$ver" | grep nga | cut -d'=' -f2)
        NGASIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/nga.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
    fi
    LWVERSION=$(echo "$ver" | grep wallpaper | cut -d'=' -f2)
    OSRVERSION=$(echo "$ver" | grep osr | cut -d'=' -f2)
    DPVERSION=$(echo "$ver" | grep dp-$API | cut -d'=' -f2)
    PCSVERSION=$(echo "$ver" | grep pcs | cut -d'=' -f2)
    PCSSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pcs.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
    DPSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/dp-$API.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb)"
    if [ $API -ge 31 ]; then
        DPVERSION=$(echo "$ver" | grep asi-new-31 | cut -d'=' -f2)
        DPSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/asi-new-31.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb)"
    fi
    if [ $NEW_PL -eq 1 ]; then
    	PLVERSION=$(echo "$ver" | grep pl-new-$NEWAPI | cut -d'=' -f2)
    	PLSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pl-new-$NEWAPI.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
    else
        PLVERSION=$(echo "$ver" | grep pl-$API | cut -d'=' -f2)
        PLSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pl-$API.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
    fi
    rm -rf $pix/nga.txt
    rm -rf $pix/pixel.txt
    rm -rf $pix/dp.txt
    rm -rf $pix/osr.txt
    rm -rf $pix/pl-$NEWAPI.txt
    echo "$PCSVERSION" >> $pix/pcs.txt
    echo "$NGAVERSION" >> $pix/nga.txt
    echo "$LWVERSION" >> $pix/pixel.txt
    echo "$DPVERSION" >> $pix/dp.txt
    echo "$OSRVERSION" >> $pix/osr.txt
    echo "$PLVERSION" >> $pix/pl-$NEWAPI.txt
    OSRSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/osr.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
    LWSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pixel.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
else
	echo "- Warning, Cannot able to fetch package version, using saved version instead" >> $logfile
    if [ ! -f $pix/nga.txt ]; then
        echo "$NGAVERSIONP" >> $pix/nga.txt
    fi
    if [ ! -f $pix/osr.txt ]; then
        echo "$OSRVERSIONP" >> $pix/nga.txt
    fi
    if [ ! -f $pix/pcs.txt ]; then
        echo "$PCSVERSIONP" >> $pix/pcs.txt
    fi
    if [ ! -f $pix/pixel.txt ]; then
        echo "$LWVERSIONP" >> $pix/pixel.txt
    fi
    if [ ! -f $pix/dp.txt ]; then
        echo "$DPVERSIONP" >> $pix/dp.txt
    fi
    if [ ! -f $pix/pl-$NEWAPI.txt ]; then
        echo "$PLVERSIONP" >> $pix/pl-$NEWAPI.txt
    fi
fi

OSRVERSION=$(cat $pix/osr.txt)
NGAVERSION=$(cat $pix/nga.txt)
LWVERSION=$(cat $pix/pixel.txt)
DPVERSION=$(cat $pix/dp.txt)
DPSVERSION=$(cat $pix/dps.txt)
PCSVERSION=$(cat $pix/pcs.txt)
PLVERSION=$(cat $pix/pl-$NEWAPI.txt)

if [ "$(getprop ro.soc.model)" == "Tensor" ]; then
	echo "- Tensor chip Detected !" >> $logfile
	TENSOR=1
    rm -rf $MODPATH/zygisk
    mv $MODPATH/zygisk_1 $MODPATH/zygisk
else
	TENSOR=0
fi

if [ "$(getprop ro.product.vendor.name)" == "coral" ] || [ "$(getprop ro.product.vendor.name)" == "flame" ]; then
    echo "- Pixel 4/XL Detected !"
    for i in $MODPATH/zygisk/*; do
        sed -i -e "s/com.google.android.xx/com.google.android.as/g" $i
    done
fi

echo "
- NGA version: $NGAVERSION
- Pixel Live Wallpapers version: $NGAVERSION
- Device Personalisation Services version: $DPVERSION
- Pixel Launcher ($API) version: $PLVERSION
" >> $logfile

chmod -R 0755 $MODPATH/addon
chmod 0644 $MODPATH/files/*.xz
alias keycheck="$MODPATH/addon/keycheck"
sqlite=$MODPATH/addon/sqlite3
gms=/data/data/com.google.android.gms/databases/phenotype.db
gser=/data/data/com.google.android.gsf/databases/gservices.db
gah=/data/data/com.google.android.gms/databases/google_account_history.db

gacc="$("$sqlite" "$gah" "SELECT account_name FROM AccountHistory;")"

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

print ""
print "- Detected Arch: $ARCH"
print "- Detected SDK : $API"
RAM=$( grep MemTotal /proc/meminfo | tr -dc '0-9')
print "- Detected Ram: $RAM"
print ""
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
    if [ -f $file ]; then
        line=$(grep $1 $2 | grep false | cut -c 16- | cut -d' ' -f1)
        for i in $line; do
            val_false='value="false"'
            val_true='value="true"'
            write="${i} $val_true"
            find="${i} $val_false"
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
            str=$(grep $i $3 | grep long | cut -c 17-  | cut -d'"' -f1-2)
            str1=$(grep $i $3 | grep long | cut -c 17- | cut -d'"' -f1-3)
            add="$str\"$2"
            if [ ! "$add" == "$str1" ]; then
                sed -i -e "s/${str1}/${add}/g" $file
            fi
        done
    fi
}


abort1() {
    echo "Installation Failed: $1" >> $logfile
    abort "$1"
}

keytest() {
    print "- Vol Key Test"
    print "    Press a Vol Key:"
    if (timeout 5 /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events); then
        return 0
    else
        print "   Try again:"
        timeout 5 $MODPATH/addon/keycheck
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

NO_VK=1

if [ -f /sdcard/Pixelify/no-VK.prop ]; then
    vk_loc="/sdcard/Pixelify/no-VK.prop"
else
    vk_loc="$MODPATH/no-VK.prop"
fi

no_vk() {
    if [ "$(grep $1= $vk_loc | cut -d= -f2)" -eq 1 ]; then
        NO_VK=0
    elif [ "$(grep $1= $vk_loc | cut -d= -f2)" -eq 0 ]; then
        NO_VK=1
    else
        print ""
        print "Cannot find $1 in $vk_loc"
        print ""
        NO_VK=1
    fi
}

no_vksel() {
    if [ "$NO_VK" -eq 0 ]; then
        print ""
        print "  Selected: Volume up"
        print ""
        return 0
    else
        print ""
        print "  Selected: Volume down"
        print ""
        return 1
    fi
}

# Have user option to skip vol keys
if [ "$(grep 'DEVICE_USES_VOLUME_KEY=' $MODPATH/module.prop | cut -d= -f2)" -eq 0 ]; then
    print "- Skipping Vol Keys -"
    print ""
    print " Using config: $vk_loc"
    VKSEL=no_vksel
else
    if keytest; then
    	echo "- Using chooseport method for Volume keys" >> $logfile
        VKSEL=chooseport
    else
        VKSEL=chooseportold
        echo "- using chooseportold method for Volume Keys" >> $logfile
        print "  ! Legacy device detected! Using old keycheck method"
        print " "
        print "- Vol Key Programming -"
        print "  Press Vol Up Again:"
        $VKSEL "UP"
        print "  Press Vol Down"
        $VKSEL "DOWN"
    fi
fi

DIALER=com.google.android.dialer
print ""
print "- Installing Pixelify Module"
print "- Extracting Files...."
echo "- Extracting Files ..." >> $logfile
if [ $API -ge 28 ]; then
    tar -xf $MODPATH/files/tur.tar.xz -C $MODPATH/system$product/priv-app
fi

SHOW_GSS=1
if [ ! -z "$(getprop ro.rom.version | grep Oxygen)" ] || [ ! -z "$(getprop ro.miui.ui.version.code)" ] || [ "$(getprop ro.product.vendor.manufacturer)" == "samsung" ] && [ $NEWAPI -le 30 ]; then
    echo " - Oxygen OS or MiUI or One Ui Rom Detected" >> $logfile
    SHOW_GSS=0
fi

FIRST_ONLINE_TIME=1

drop_sys() {
    for i in /system/product/etc/sysconfig/*; do
        if [ ! -z "$(grep PIXEL_2020_ /system/product/etc/sysconfig/$i)" ] || [ ! -z "$(grep PIXEL_2021_ /system/product/etc/sysconfig/$i)" ] || [ ! -z "$(grep PIXEL_2022_ /system/product/etc/sysconfig/$i)" ]; then
            [ ! -f $MODPATH/system/product/etc/sysconfig/$i ] && cat /system/product/etc/sysconfig/$i | grep -v PIXEL_2020_ | grep -v PIXEL_2021_ | grep -v PIXEL_2022_ > $MODPATH/system/product/etc/sysconfig/$i
        fi
    done
    if [ -f /data/adb/modules/Pixelify/system/product/etc/sysconfig ]; then
        for i in /data/adb/modules/Pixelify/system/product/etc/sysconfig/*; do
            if [ ! -f $MODPATH/system/product/etc/sysconfig/$i ]; then
                cp -f /data/adb/modules/Pixelify/system/product/etc/sysconfig/$i $MODPATH/system/product/etc/sysconfig/$i
            fi
        done
    fi
    rm -rf $MODPATH/system$product/etc/sysconfig/pixel_experience_2020.xml
    rm -rf $MODPATH/system$product/etc/sysconfig/pixel_experience_2020_midyear.xml
    rm -rf $MODPATH/system$product/etc/sysconfig/pixel_experience_2021.xml
    rm -rf $MODPATH/system$product/etc/sysconfig/pixel_experience_2021_midyear.xml
    rm -rf $MODPATH/system$product/etc/sysconfig/pixel_experience_2022.xml
    rm -rf $MODPATH/system$product/etc/sysconfig/pixel_experience_2022_midyear.xml
    touch $MODPATH/system$product/etc/sysconfig/pixel_experience_2020.xml
    touch $MODPATH/system$product/etc/sysconfig/pixel_experience_2020_midyear.xml
    touch $MODPATH/system$product/etc/sysconfig/pixel_experience_2021.xml
    touch $MODPATH/system$product/etc/sysconfig/pixel_experience_2021_midyear.xml
    touch $MODPATH/system$product/etc/sysconfig/pixel_experience_2022.xml
    touch $MODPATH/system$product/etc/sysconfig/pixel_experience_2022_midyear.xml
}

db_edit() {
	type=$2
	val=$3
	name=$1
	shift
	shift
	shift
	echo "- $name patching started" >> $logfile
	for i in $@; do
		echo "Patching $i to $val" >> $logfile
	    $sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='$name' AND name='$i'"
	    $sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, $type, committed) VALUES('$name', '', '$i', 0, $val, 0)"
	    $sqlite $gms "UPDATE Flags SET $type='$val' WHERE packageName='$name' AND name='$i'"
	    # for j in $gacc; do
	    	# $sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, $type, committed) VALUES('$name', '$j', '$i', 0, $val, 0)"
	    # done
	done
	echo "- $name patching done" >> $logfile
}

if [ ! -z $exact_prop ]  && [ $NEWAPI -ge 31 ] && [ $BETA_BUILD -eq 1 ]; then
    print "  Disclaimer: This Feature is in BETA"
    print "  This features is only intended to Quick Phrase."
    print "  Disabling Internal Spoofing can break OTA Update (rom dependent)"
    print "  If it doesn't work properly then it causes issues to Google app"
    print "  If you are not aware of We wont recommended to enable it."
    print ""
    print "  Do you want to disable Internal spoofing of rom?"
    print "  Note: This may break ota update of your rom"
    print "   Vol Up += Yes"
    print "   Vol Down += No"
    no_vk "DISABLE_INTERNAL_SPOOFING"
    if $VKSEL; then
        echo " " >> $MODPATH/system.prop
        echo "$exact_prop=redfin" >> $MODPATH/system.prop
    fi   
fi

ZYGISK_P=0
if [ $TENSOR -eq 1 ]; then
	[ $MAGISK_VER_CODE -ge 24000 ] && ZYGISK_P=1
    print ""
    print "(TENSOR CHIPSET DETECTED)"
    print "  Do you want to enable Google Photos Unlimited Backup?"
    print "  Note: Magic Earser will only work on Photos app given in Github page"
    print "   Vol Up += Yes"
    print "   Vol Down += No"
    no_vk "ENABLE_TENSOR_UNLIMITED"
    if $VKSEL; then
    	echo "- Enabling Unlimited storage in this Tensor chipset device" >> $logfile
    	drop_sys
    else
    	echo "- Disabling Unlimited storage in this Tensor chipset device" >> $logfile
        rm -rf $MODPATH/zygisk $MODPATH/zygisk_1
    fi
elif [ $MAGISK_VER_CODE -ge 24000 ]; then
    print ""
    print "- Magisk v24 and above detected "
    print "- Zygisk must be enabled inorder Pixelify module to work"
    print ""
    print "- Spoofing Google apps according to there best configuration."
    print ""
    drop_sys
    ZYGISK_P=1
else
    print ""
    print "  Do you want to Spoof your device to Pixel 5/Pixel 6 Pro?"
    print "   Vol Up += Yes"
    print "   Vol Down += No"
    no_vk "ENABLE_PIXEL_SPOOFING"
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
        no_vk "TARGET_USES_PIXEL5_SPOOF"
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

now_playing() {
    print ""
    print "  Note: If you are facing problem with audio then dont enable"
    print "  Do you want to enable Now Playing?"
    print "   Vol Up += Yes"
    print "   Vol Down += No"
    no_vk "ENABLE_NOW_PLAYING"
    if $VKSEL; then
        cp -f $MODPATH/files/PixeliflyNowPlaying.apk $MODPATH/system$product/overlay/PixeliflyNowPlaying.apk
    fi
}

NOT_REQ_SOUND_PATCH=0
[ -f /product/etc/firmware/music_detector.sound_model ] && rm -rf $MODPATH/system/etc/firmware && NOT_REQ_SOUND_PATCH=1

$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.platform.device_personalization_services'"
db_edit com.google.android.platform.device_personalization_services boolVal 1 "Translate__characterset_lang_detection_enabled" "Overview__enable_lens_r_overview_translate_action" "Captions__enable_language_detection" "Echo__search_enable_application_header_type" "Echo__search_enable_app_search_tips" "Echo__search_enable_appsearch_tips_ranking_improvement" "Echo__search_enable_mdp_play_results" "Echo__search_enable_search_in_app_icon" "Echo__search_enable_static_shortcuts" "Echo__search_enable_superpacks_play_results" "Echo__search_enable_app_fetcher_v2" "Echo__search_enable_assistant_quick_phrases_settings" "Echo__smartspace_enable_battery_notification_parser" "SmartDictation__enable_alternatives_from_past_corrections" "SmartDictation__enable_alternatives_from_speech_hypotheses" "SmartDictation__enable_biasing_for_commands" "SmartDictation__enable_biasing_for_contacts" "SmartDictation__enable_biasing_for_contacts_learned_from_past_corrections" "SmartDictation__enable_biasing_for_interests_model" "SmartDictation__enable_biasing_for_past_correction" "SmartDictation__enable_biasing_for_screen_context" "SmartDictation__enable_personalized_biasing_on_locked_device" "SmartDictation__enable_selection_filtering" "Echo__search_enable_apps" "Captions__text_transform_augmented_input" "Captions__enable_augmented_modality" "Captions__enable_augmented_modality_input"" Translate__copy_to_translate_enabled" "Translate__blue_chip_translate_enabled" "Echo__enable_headphones_suggestions_from_agsa" "NowPlaying__youtube_export_enabled" "Overview__enable_lens_r_overview_long_press" "Overview__enable_lens_r_overview_select_mode" "Overview__enable_lens_r_overview_translate_action" "Echo__smartspace_enable_doorbell" "Echo__smartspace_enable_earthquake_alert_predictor" "Echo__smartspace_enable_echo_settings" "Echo__smartspace_enable_light_predictor" "Echo__smartspace_enable_paired_device_predictor" "Echo__smartspace_enable_safety_check_predictor"
db_edit com.google.android.platform.device_personalization_services boolVal 0 "SmartSelect__enable_smart_select_locked_bootloader_check"
# db_edit com.google.android.platform.device_personalization_services stringVal "en-US;en-GB;en-CA;en-IE;en-AU;en-SG;fr-FR;fr-CA;it-IT;de-DE;ja-JP;es-ES" "Captions__available_for_download"
# db_edit com.google.android.platform.device_personalization_services stringVal "en-US;es-SG;fr-FR;fr-CA;it-IT;de-DE;ja-JP" "Captions__supported_languages"
db_edit com.google.android.platform.launcher boolVal "ENABLE_SMARTSPACE_ENHANCED"

if [ $DPAS -eq 1 ]; then
    echo " - Installing Android System Intelligence" >> $logfile
    if [ -f /sdcard/Pixelify/backup/dp-$NEWAPI.tar.xz ]; then
        echo " - Backup Detected for Android System Intelligence" >> $logfile
        REMOVE="$REMOVE $DP"
        if [ "$(cat /sdcard/Pixelify/version/dp-$API.txt)" != "$DPVERSION" ] || [ $SEND_DPS -eq 1 ] || [ ! -f /sdcard/Pixelify/version/dp-$NEWAPI.txt ] ]; then
            echo " - New Version Detected for Android System Intelligence" >> $logfile
            echo " - Installed version: $(cat /sdcard/Pixelify/version/dp-$API.txt) , New Version: $DPVERSION " >> $logfile
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
                if [ $internet -eq 1 ]; then
                    echo " - Downloading and installing new backup for Android System Intelligence" >> $logfile
                    cd $MODPATH/files
                    rm -rf /sdcard/Pixelify/backup/dp-$API.tar.xz /sdcard/Pixelify/backup/dp-net-$API.tar.xz /sdcard/Pixelify/version/dp.txt /sdcard/Pixelify/version/dp-$API.txt
                    if [ $API -ge 31 ]; then
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/asi-new-31.tar.xz -o dp-$NEWAPI.tar.xz &> /proc/self/fd/$OUTFD
                    else
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/dp-$API.tar.xz -O &> /proc/self/fd/$OUTFD
                    fi
                    cp -f $MODPATH/files/dp-$NEWAPI.tar.xz /sdcard/Pixelify/backup/dp-$NEWAPI.tar.xz
                    echo "$DPVERSION" >> /sdcard/Pixelify/version/dp-$NEWAPI.txt
                    cd /
                    print ""
                    print "- Creating Backup"
                else
                    print ""
                    print "!! Warning !!"
                    print " No internet detected"
                    print ""
                    print "- Using Old backup for now."
                    echo " - Using Old backup for Android System Intelligence due to no internet services" >> $logfile
                    print ""
                fi
            else
                echo " - Using Old backup for Android System Intelligence" >> $logfile
                print ""
            fi
        fi
        now_playing
        print "- Installing Android System Intelligence"
        print ""
        cp -f $MODPATH/files/PixeliflyDPS.apk $MODPATH/system/product/overlay/PixeliflyDPS.apk
        tar -xf /sdcard/Pixelify/backup/dp-$NEWAPI.tar.xz -C $MODPATH/system$product/priv-app
        echo dp-$API > $pix/app2.txt
    else
        print ""
        echo " - No backup Detected for Android System Intelligence" >> $logfile
        print "  (Network Connection Needed)"
        print "  Do you want to install and Download Android System Intelligence?"
        print "  Size: $DPSIZE Mb"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        no_vk "ENABLE_DPS"
        if $VKSEL; then
            online
            if [ $internet -eq 1 ]; then
                print "- Downloading Android System Intelligence"
                echo " - Downloading and installing Android System Intelligence" >> $logfile
                print ""
                cd $MODPATH/files
                if [ $API -ge 31 ]; then
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/asi-new-31.tar.xz -o dp-$NEWAPI.tar.xz &> /proc/self/fd/$OUTFD
                else
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/dp-$API.tar.xz -O &> /proc/self/fd/$OUTFD
                fi
                cd /
                now_playing
                print ""
                print "- Installing Android System Intelligence"
                cp -f $MODPATH/files/PixeliflyDPS.apk $MODPATH/system/product/overlay/PixeliflyDPS.apk
                tar -xf $MODPATH/files/dp-$NEWAPI.tar.xz -C $MODPATH/system$product/priv-app
                echo dp-$API > $pix/app2.txt
                REMOVE="$REMOVE $DP"
                print ""
                print "  Do you want to create backup of Android System Intelligence?"
                print "  so that you don't need redownload it everytime."
                print "   Vol Up += Yes"
                print "   Vol Down += No"
                no_vk "BACKUP_DPS"
                if $VKSEL; then
                    echo " - Creating backup for Android System Intelligence" >> $logfile
                    print "- Creating Backup"
                    mkdir -p /sdcard/Pixelify/backup
                    rm -rf /sdcard/Pixelify/backup/dp-$NEWAPI.tar.xz /sdcard/Pixelify/backup/dp-net-$NEWAPI.tar.xz /sdcard/Pixelify/version/dp.txt /sdcard/Pixelify/version/dp-$API.txt
                    cp -f $MODPATH/files/dp-$NEWAPI.tar.xz /sdcard/Pixelify/backup/dp-$NEWAPI.tar.xz
                    print ""
                    mkdir /sdcard/Pixelify/version
                    echo "$DPVERSION" >> /sdcard/Pixelify/version/dp-$NEWAPI.txt
                    print " - Done"
                fi
            else
                print "!! Warning !!"
                print " No internet detected"
                print ""
                print "- Skipping Android System Intelligence"
                print ""
                echo " - Skipping Android System Intelligence due to no internet services" >> $logfile
            fi
        fi
    fi
    pm install --user 0 $MODPATH/system/product/priv-app/asi_up.apk &>/dev/null
    [ $API -ge 31 ] && pm install --user 0 $MODPATH/system/product/priv-app/DeviceIntelligenceNetworkPrebuilt/*.apk &>/dev/null
    for i in $ASI_OS_PERM; do
        pm grant com.google.android.as.oss $i &>/dev/null
    done
    for i in $ASI_PERM; do
        pm grant com.google.android.as $i &>/dev/null
    done
    rm -rf $MODPATH/system/product/priv-app/asi_up.apk
else
    print ""
fi

if [ -d /data/data/$DIALER ]; then
    print "  Do you want to install Google Dialer features?"
    print "   - Includes Call Screening, Call Recording, Hold for Me, Direct My Call"
    print "   (For all Countries)"
    print "    Vol Up += Yes"
    print "    Vol Down += No"
    no_vk "ENABLE_DIALER_FEATURES"
    if $VKSEL; then
        echo " - Installing Google Dialer features" >> $logfile
        DIALER_PREF=/data/data/com.google.android.dialer/shared_prefs/dialer_phenotype_flags.xml
        sed -i -e "s/CallScreening=0/CallScreening=1/g" $MODPATH/config.prop
        print "- Enabling Call Screening & Hold for me & Direct My Call"
        print " "
        print "- Enabling Call Recording (Working is device dependent)"
        lang=$(getprop persist.sys.locale | cut -d'-' -f1)
        full_lang=$(getprop persist.sys.locale)
        CUSTOM_CALL_SCREEN=0
        for i in "es" "fr" "it" "ja" "de"; do
            if [ "$i" == "$lang" ]; then
                CUSTOM_CALL_SCREEN=1
                break
            fi
        done
        DIALERFLAGS="
        atlas_show_preview_label
        G__enable_atlas
        enable_atlas_call_audio_state_verification
        enable_atlas_on_tidepods_voice_screen
        show_atlas_hold_for_me_confirmation_dialog
        atlas_use_soda_for_transcription
        atlas_ivr_alert_use_dialpad_clicks
        atlas_enable_au_business_number
        enable_theme_pushing
        enable_precall_dialpad_v2
        enable_call_screen_hats
        enable_hats_proof_mode
        enable_time_keeper
        enable_time_keeper_histogram
        enable_dialpad_v2_ux
        enable_android_s_notifications
        G__speak_easy_use_soda_asr
        G__enable_call_screen_saving_audio
        G__enable_call_recording
        G__force_within_call_recording_geofence_value
        G__use_call_recording_geofence_overrides
        G__force_within_crosby_geofence_value
        G__speak_easy_enabled
        G__enable_speakeasy_details
        G__speak_easy_bypass_locale_check
        G__speak_easy_enable_listen_in_button
        G__bypass_revelio_roaming_check
        G__enable_revelio
        G__enable_revelio_r_api
        enable_revelio_transcript
        Xatu__xatu_always_uses_soda
        enable_xatu
        enable_xatu_music_detection
        enable_dialer_hold_handling
        enable_hold_detection
        enable_video_calling_screen
        enable_video_type_picker
        enable_video_call_type_chooser
        G__new_voicemail_fragment_enabled"

        for i in $DIALERFLAGS; do
             $sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer' AND name='$i'"
        	if [ $CUSTOM_CALL_SCREEN -eq 1 ] && [[ $i == "G__enable_revelio" || $i == "G__enable_revelio_r_api" || $i == "enable_revelio_transcript" || $i == "G__bypass_revelio_roaming_check" || $i == "G__enable_call_screen_saving_audio" || $i == "G__speak_easy_enabled" || $i == "G__enable_speakeasy_details" || $i == "G__speak_easy_bypass_locale_check" || $i == "G__speak_easy_use_soda_asr" ]]; then
        		continue
        	fi
            if [ $API -le 30 ] && [ $i == "enable_android_s_notifications" ]; then
                continue
            fi
            $sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, boolVal, committed) VALUES('com.google.android.dialer', '', '$i', 0, 1, 0)"
            $sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, boolVal, committed) VALUES('com.google.android.dialer', '', '$i', 0, 1, 0)"
            $sqlite $gms "UPDATE Flags SET boolVal='1' WHERE packageName='com.google.android.dialer' AND name='$i'"
        done
        if [ $CUSTOM_CALL_SCREEN -eq 0 ]; then
            print " "
            print "- Please set your launguage to"
            print "  English (United States) for call screening"
            print " "
        else
        	print " "
            if [ -f /sdcard/Pixelify/backup/callscreen-$lang.tar.xz ]; then
                print "- Installing CallScreening $lang from backups"
                print ""
                mkdir -p $MODPATH/system/product/tts/google
                tar -xf /sdcard/Pixelify/backup/callscreen-$lang.tar.xz -C $MODPATH/system/product/tts/google
            else
                CRSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/callscreen-$lang.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
                print "  (Network Connection Needed)"
                print "  Do you want to Download CallScreening files for '$lang' launguage"
                print "  Size: $CRSIZE"
                print "   Vol Up += Yes"
                print "   Vol Down += No"
                no_vk "ADD_CALL_SCREENING_FILES"
                if $VKSEL; then
                    online
                    if [ $internet -eq 1 ]; then
                        echo " - Downloading CallScreening files for '$lang'" >> $logfile
                        print "  Downloading CallScreening files for '$lang'"
                        mkdir -p $MODPATH/system/product/tts/google
                        cd $MODPATH/files
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/callscreen-$lang.tar.xz -O &> /proc/self/fd/$OUTFD
                        cd /
                        tar -xf $MODPATH/files/callscreen-$lang.tar.xz -C $MODPATH/system/product/tts/google
                        print ""
                        print "  Do you want to create backup of CallScreening files for '$lang'"
                        print "  so that you don't need redownload it everytime."
                        print "   Vol Up += Yes"
                        print "   Vol Down += No"
                        no_vk "BACKUP_CALL_SCREENING_FILES"
                        if $VKSEL; then
                            echo " - Creating backup for CallScreening files for '$lang'" >> $logfile
                            print "- Creating Backup"
                            mkdir -p /sdcard/Pixelify/backup
                            rm -rf /sdcard/Pixelify/backup/callscreen-$lang.tar.xz
                            cp -f $MODPATH/files/callscreen-$lang.tar.xz /sdcard/Pixelify/backup/callscreen-$lang.tar.xz
                            print ""
                        fi
                    else
                        print "!! Warning !!"
                        print " No internet detected"
                        print ""
                        print "- Skipping CallScreening Resources."
                        print ""
                        echo " - skipping CallScreening Resources due to no internet" >> $logfile
                    fi
                else
                    echo " - skipping CallScreening Resources" >> $logfile
                fi
            fi
        fi

        bool_patch speak_easy $DIALER_PREF
        bool_patch speakeasy $DIALER_PREF
        bool_patch call_screen $DIALER_PREF
        # bool_patch revelio $DIALER_PREF
        bool_patch record $DIALER_PREF
        bool_patch atlas $DIALER_PREF
        bool_patch xatu $DIALER_PREF
        bool_patch enable_android_s_notifications $DIALER_PREF

        carr="$(getprop gsm.sim.operator.numeric)"
        carrier=${#carr}
        case $carrier in
            6)
                sed -i -e "s/310004/${carr}/g" $MODPATH/files/phenotype/com.google.android.dialer
                ;;
            5)
                sed -i -e "s/21403/${carr}/g" $MODPATH/files/phenotype/com.google.android.dialer
                ;;
        esac

        device="$(getprop ro.product.device)"
        device_len=${#device}
        carr_coun_small="$(getprop gsm.sim.operator.iso-country)"
        if [ ! -z $(echo $carr_coun_small | grep ',') ]; then
            carr_coun_small="$(getprop gsm.sim.operator.iso-country | cut -d, -f1)"
            if [ -z $carr_coun_small ]; then
                carr_coun_small="$(getprop gsm.sim.operator.iso-country | cut -d, -f2)"
                if [ -z $carr_coun_small ]; then
                    carr_coun_small="us"
                fi
            fi
        fi
        carr_coun="$(echo $carr_coun_small | tr '[:lower:]' '[:upper:]')"

        if [ ! -z $carr_coun ]; then
            echo " - Adding Country ($carr_coun) patch for Call Recording and Hold for me, Direct My Call" >> $logfile
            if [ -z $(echo "AU US JP" | grep $carr_coun) ]; then
                sed -i -e "s/YY/${carr_coun}/g" $MODPATH/files/phenotype/com.google.android.dialer
                sed -i -e "s/YY/${carr_coun}/g" $MODPATH/files/com.google.android.dialer-custom
            fi
        fi

        if [ -z $(echo "GB IE JP US DE IT FR ES" | grep $carr_coun) ]; then
            sed -i -e "s/kk-YT/${full_lang}/g" $MODPATH/files/com.google.android.dialer-custom
            sed -i -e "s/kk/${carr_coun_small}/g" $MODPATH/files/com.google.android.dialer-custom
        fi

        # Remove old prompt to replace to use within overlay
        rm -rf /data/data/com.google.android.dialer/files/callrecordingprompt/*
        mkdir -p /data/data/com.google.android.dialer/files/callrecordingprompt
        cp -r $MODPATH/files/callrec/* /data/data/com.google.android.dialer/files/callrecordingprompt
        chmod 0755 /data/data/com.google.android.dialer/files/phenotype
        if [ $CUSTOM_CALL_SCREEN -eq 0 ]; then
            chmod 0500 /data/data/com.google.android.dialer/files/phenotype
            cp -Tf $MODPATH/files/$DIALER $MODPATH/$DIALER
            cp -Tf $MODPATH/files/$DIALER-custom $MODPATH/$DIALER-1
            cp -Tf $MODPATH/files/$DIALER /data/data/com.google.android.dialer/files/phenotype/$DIALER
            am force-stop $DIALER
        else
            rm -rf $MODPATH/$DIALER
            sed -i -e "s/cp -Tf $MODDIR\/com.google.android.dialer/#cp -Tf $MODDIR\/com.google.android.dialer/g" $MODPATH/service.sh
            sed -i -e "s/chmod 500 \/data\/data\/com.google.android.dialer\/files\/phenotype/#chmod 500 \/data\/data\/com.google.android.dialer\/files\/phenotype/g" $MODPATH/service.sh
        fi

        chmod 0600 /data/data/com.google.android.dialer/files/phenotype/com.google.android.dialer
        if [ -z $(pm list packages -s $DIALER) ] && [ ! -f /data/adb/modules/Pixelify/system/product/priv-app/GoogleDialer/GoogleDialer.apk ]; then
            print ""
            print "- Google Dialer is not installed as a system app !!"
            print "- Making Google Dialer as a system app"
            echo " - Making Google Dialer system app" >> $logfile
            print ""
            cp -r ~/$app/com.google.android.dialer*/. $MODPATH/system$product/priv-app/GoogleDialer
            mv $MODPATH/system$product/priv-app/GoogleDialer/base.apk $MODPATH/system$product/priv-app/GoogleDialer/GoogleDialer.apk
            rm -rf $MODPATH/system$product/priv-app/GoogleDialer/oat
        elif [ -f /data/adb/modules/Pixelify/system/product/app/GoogleDialer/GoogleDialer.apk ]; then
            print ""
            print "- Google Dialer is not installed as a system app !!"
            print "- Making Google Dialer as a system app"
            echo " - Making Google Dialer system app" >> $logfile
            print ""
            cp -r ~/$app/com.google.android.dialer*/. $MODPATH/system$product/priv-app/GoogleDialer
            mv $MODPATH/system$product/priv-app/GoogleDialer/base.apk $MODPATH/system$product/priv-app/GoogleDialer/GoogleDialer.apk
            rm -rf $MODPATH/system$product/priv-app/GoogleDialer/oat
        fi
    else
    	rm -rf $MODPATH/system$product/overlay/PixelifyGD.apk
        chmod 755 /data/data/com.google.android.dialer/files/phenotype
        sed -i -e "s/cp -Tf $MODDIR\/com.google.android.dialer/#cp -Tf $MODDIR\/com.google.android.dialer/g" $MODPATH/service.sh
        sed -i -e "s/chmod 500 \/data\/data\/com.google.android.dialer\/files\/phenotype/#chmod 500 \/data\/data\/com.google.android.dialer\/files\/phenotype/g" $MODPATH/service.sh
    fi
else
    chmod 755 /data/data/com.google.android.dialer/files/phenotype
    sed -i -e "s/cp -Tf $MODDIR\/com.google.android.dialer/#cp -Tf $MODDIR\/com.google.android.dialer/g" $MODPATH/service.sh
    sed -i -e "s/chmod 500 \/data\/data\/com.google.android.dialer\/files\/phenotype/#chmod 500 \/data\/data\/com.google.android.dialer\/files\/phenotype/g" $MODPATH/service.sh
	rm -rf $MODPATH/system$product/overlay/PixelifyGD.apk
fi

osr_ins() {
    if [ -f /sdcard/Pixelify/backup/osr.tar.xz ]; then
        if [ "$(cat /sdcard/Pixelify/version/osr.txt)" != "$OSRVERSION" ]; then
            echo " - New Version Detected for Google offline speech recognition" >> $logfile
            echo " - Installed version: $(cat /sdcard/Pixelify/version/osr.txt) , New Version: $OSRVERSION " >> $logfile
            print "  (Network Connection Needed)"
            print "  New version of Google offline speech recogonition detected."
            print "  Do you Want to update or use Old Backup?"
            print "  Version: $OSRVERSION"
            print "  Size: $OSRSIZE"
            print "   Vol Up += Update"
            print "   Vol Down += Use old backup"
            no_vk "UPDATE_OSR"
            if $VKSEL; then
                online
                if [ $internet -eq 1 ]; then
                    REMOVE="$REMOVE /system/product/usr/srec/en-US"
                    echo " - Downloading, Installing and creating backup Google offline speech recogonition" >> $logfile
                    rm -rf /sdcard/Pixelify/backup/osr.tar.xz
                    rm -rf /sdcard/Pixelify/version/osr.txt
                    cd $MODPATH/files
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/osr.tar.xz -O &> /proc/self/fd/$OUTFD
                    cd /
                    print ""
                    print "- Creating Backup"
                    print ""
                    cp -Tf $MODPATH/files/osr.tar.xz /sdcard/Pixelify/backup/osr.tar.xz
                    echo "$OSRVERSION" >> /sdcard/Pixelify/version/osr.txt
                else
                    print "!! Warning !!"
                    print " No internet detected"
                    print ""
                    print "- Using Old backup for now."
                    print ""
                    echo " - using old backup for Google offline speech recognition due to no internet" >> $logfile
                fi
            else
                echo " - using old backup for Google offline speech recognition" >> $logfile
            fi
        fi
        print "- Installing Google offline speech recognition from backups"
        print ""
        tar -xf /sdcard/Pixelify/backup/osr.tar.xz -C $MODPATH/system/product
    else
        print "  (NOTE: Below Feature is not compulsary for NGA, But this can fix issues regarding Continued Conversation, and Transcription of Dialers Features)"
        print ""
        print "  (Network Connection Needed)"
        print "  Do you want to install and Download Google offline speech recognition"
        print "  Size: $OSRSIZE"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        no_vk "DOWNLOAD_OSR"
        if $VKSEL; then
            online
            if [ $internet -eq 1 ]; then
                REMOVE="$REMOVE /system/product/usr/srec/en-US"
                echo " - Downloading and Installing Google offline speech recognition" >> $logfile
                print "  Downloading Google offline speech recognition"
                cd $MODPATH/files
                $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/osr.tar.xz -O &> /proc/self/fd/$OUTFD
                cd /
                print " "
                print "  Extracting Google offline speech recognition"
                tar -xf $MODPATH/files/osr.tar.xz -C $MODPATH/system/product
                print ""
                print "  Do you want to create backup of Google offline speech recognition"
                print "  so that you don't need redownload it everytime."
                print "   Vol Up += Yes"
                print "   Vol Down += No"
                no_vk "BACKUP_OSR"
                if $VKSEL; then
                    echo " - Creating backup for Google offline speech recognition" >> $logfile
                    print "- Creating Backup"
                    mkdir -p /sdcard/Pixelify/backup
                    rm -rf /sdcard/Pixelify/backup/osr.tar.xz
                    cp -f $MODPATH/files/osr.tar.xz /sdcard/Pixelify/backup/osr.tar.xz
                    mkdir -p /sdcard/Pixelify/version
                    echo "$OSRVERSION" >> /sdcard/Pixelify/version/osr.txt
                    print ""
                    print "- Google offline speech recognition installation complete"
                    print ""
                fi
            else
                print "!! Warning !!"
                print " No internet detected"
                print ""
                print "- Skipping Google offline speech recognition."
                print ""
                echo " - skipping Google offline speech recognition due to no internet" >> $logfile
            fi
        else
            echo " - skipping Google offline speech recognition" >> $logfile
        fi
    fi
}

GOOGLE_PREF=/data/data/com.google.android.googlequicksearchbox/shared_prefs/GEL.GSAPrefs.xml
if [ -d /data/data/com.google.android.googlequicksearchbox ] && [ $API -ge 29 ]; then
    print "  Google is installed."
    print "  Do you want to installed Next generation assistant?"
    print "   Vol Up += Yes"
    print "   Vol Down += No"
    no_vk "ENABLE_NGA"
    if $VKSEL; then
        echo " - Installing Next generation assistant" >> $logfile
        if [ -f /sdcard/Pixelify/backup/nga.tar.xz ] || [ -f /sdcard/Pixelify/backup/NgaResources.apk ]; then
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
                no_vk "UPDATE_NGA_RES"
                if $VKSEL; then
                    online
                    if [ $internet -eq 1 ]; then
                        echo " - Downloading, Installing and creating backup NGA Resources" >> $logfile
                        rm -rf /sdcard/Pixelify/backup/NgaResources.apk
                        rm -rf /sdcard/Pixelify/backup/nga.tar.xz
                        rm -rf /sdcard/Pixelify/version/nga.txt
                        cd $MODPATH/files
                        if [ $ENABLE_OSR -eq 1 ]; then
                            $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/nga-new.tar.xz -o nga.tar.xz &> /proc/self/fd/$OUTFD
                        else
                            $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/nga.tar.xz -o nga.tar.xz &> /proc/self/fd/$OUTFD
                        fi
                        cd /
                        print ""
                        print "- Creating Backup"
                        print ""
                        cp -Tf $MODPATH/files/nga.tar.xz /sdcard/Pixelify/backup/nga.tar.xz
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
                    echo " - Downloading and Installing NGA Resources" >> $logfile
                    print "  Downloading NGA Resources"
                    cd $MODPATH/files
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/nga-new.tar.xz -o nga.tar.xz -O &> /proc/self/fd/$OUTFD
                    cd /
                    tar -xf $MODPATH/files/nga.tar.xz -C $MODPATH/system/product
                    print ""
                    print "  Do you want to create backup of NGA Resources"
                    print "  so that you don't need redownload it everytime."
                    print "   Vol Up += Yes"
                    print "   Vol Down += No"
                    no_vk "BACKUP_NGA"
                    if $VKSEL; then
                        echo " - Creating backup for NGA Resources" >> $logfile
                        print "- Creating Backup"
                        mkdir -p /sdcard/Pixelify/backup
                        rm -rf /sdcard/Pixelify/backup/NgaResources.apk
                        rm -rf /sdcard/Pixelify/backup/nga.tar.xz
                        cp -f $MODPATH/files/nga.tar.xz /sdcard/Pixelify/backup/nga.tar.xz
                        mkdir -p /sdcard/Pixelify/version
                        echo "$NGAVERSION" >> /sdcard/Pixelify/version/nga.txt
                        print ""
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

        $sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.googlequicksearchbox'"
        # db_edit com.google.android.googlequicksearchbox boolVal 0 "45351541" "9670" "8888" "15052" "45363987" "45363985" "45359819"
        db_edit com.google.android.googlequicksearchbox stringVal "Pixel 6,Pixel 6 Pro,Pixel 5,Pixel 3XL" "17074"
        db_edit com.google.android.googlequicksearchbox stringVal "Oriole,oriole,Raven,raven,Pixel 6,Pixel 6 Pro,redfin,Redfin,Pixel 5,crosshatch,Pixel 3XL" "45353661"

        cp -f $MODPATH/files/nga.xml $MODPATH/system$product/etc/sysconfig/nga.xml
        cp -f $MODPATH/files/PixeliflyGA.apk $MODPATH/system/product/overlay/PixeliflyGA.apk
        if [ $ENABLE_OSR -eq 1 ]; then
            osr_ins
        fi

        FORCE_FILE="/sdcard/Pixelify/apps.txt"
        is_velvet="$(grep velvet= $FORCE_FILE cut -d= -f2)"
        if [ -f $FORCE_FILE ]; then
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

        if [ -z $(pm list packages -s com.google.android.googlequicksearchbox | grep -v nga) ] && [ ! -f /data/adb/modules/Pixelify/system/product/priv-app/Velvet/Velvet.apk ] || [ $FORCE_VELVET -eq 1 ]; then
            print "- Google is not installed as a system app !!"
            print "- Making Google as a system app"
            echo " - Making Google system app" >> $logfile
            print ""
            if [ -f /$app/com.google.android.googlequicksearchbox*/base.apk ]; then
            	cp -r ~/$app/com.google.android.googlequicksearchbox*/. $MODPATH/system/product/priv-app/Velvet
            	mv $MODPATH/system/product/priv-app/Velvet/base.apk $MODPATH/system/product/priv-app/Velvet/Velvet.apk
            else
            	cp -r ~/data/adb/modules/Pixelify/system$product/priv-app/Velvet/. $MODPATH/system$product/priv-app/Velvet
            fi
            rm -rf $MODPATH/system/product/priv-app/Velvet/oat
            #mv $MODPATH/files/privapp-permissions-com.google.android.googlequicksearchbox.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.googlequicksearchbox.xml
        elif [ -f /data/adb/modules/Pixelify/system/product/priv-app/Velvet/Velvet.apk ]; then
            if [ $FORCE_VELVET -eq 2 ]; then
                print "- Google is not installed as a system app !!"
                print "- Making Google as a system app"
                echo " - Making Google system app" >> $logfile
                print ""
	            if [ -f /$app/com.google.android.googlequicksearchbox*/base.apk ]; then
	            	cp -r ~/$app/com.google.android.googlequicksearchbox*/. $MODPATH/system/product/priv-app/Velvet
	            	mv $MODPATH/system/product/priv-app/Velvet/base.apk $MODPATH/system/product/priv-app/Velvet/Velvet.apk
	            else
	            	cp -r ~/data/adb/modules/Pixelify/system$product/priv-app/Velvet/. $MODPATH/system$product/priv-app/Velvet
	            fi
                rm -rf $MODPATH/system/product/priv-app/Velvet/oat
            fi
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
        no_vk "DOWN_WGA"
        if $VKSEL; then
            online
            if [ $internet -eq 1 ]; then
                print "- Downloading Styles and Wallpapers"
                echo " - Downloading and installing Styles and Wallpapers" >> $logfile
                cd $MODPATH/files
                $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/wpg-$NEWAPI.tar.xz -O &> /proc/self/fd/$OUTFD
                cd /
                rm -rf $MODPATH/system$product/priv-app/WallpaperPickerGoogleRelease
                print ""
                print "- Installing Styles and Wallpapers"
                print ""
                tar -xf $MODPATH/files/wpg-$NEWAPI.tar.xz -C $MODPATH/system$product/priv-app
                if [ $API -ge 31 ]; then
                    mkdir -p $MODPATH/system/product/app/PixelThemesStub
                    rm -rf $MODPATH/system/product/app/PixelThemesStub/PixelThemesStub.apk
                    mv $MODPATH/files/PixelThemesStub.apk $MODPATH/system/product/app/PixelThemesStub/PixelThemesStub.apk
                fi
                WREM=0
            fi
        else
            rm -rf $MODPATH/system/product/app/PixelThemesStub
        fi
    else
        rm -rf $MODPATH/system/product/app/PixelThemesStub
    fi
}

WALL_DID=0
if [ $API -ge 28 ]; then
    PLW=$(find /system -name *PixelWallpapers2021* | grep -v overlay | grep -v "\.")
    PLW1=$(find /system -name *WallpapersBreel2* | grep -v overlay | grep -v "\.")
    if [ -f /sdcard/Pixelify/backup/pixel.tar.xz ]; then
        echo " - Backup Detected for Pixel Wallpapers" >> $logfile
        print "  Do you want to install Pixel Live Wallpapers?"
        print "  (Backup detected, no internet needed)"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        no_vk "ENABLE_LIVE_WALLPAPERS"
        if $VKSEL; then
            sed -i -e "s/Live=0/Live=1/g" $MODPATH/config.prop
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
                no_vk "DOWNLOAD_LIVE_WALLPAPERS"
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
            pm install $MODPATH/system$product/priv-app/PixelLiveWallpaperPrebuilt/*.apk &>/dev/null

            if [ $API -le 28 ]; then
                mv $MODPATH/system/overlay/Breel*.apk $MODPATH/vendor/overlay
                rm -rf $MODPATH/system/overlay
            fi
            REMOVE="$REMOVE $PLW $PLW1"
            pm enable -n com.google.pixel.livewallpaper/com.google.pixel.livewallpaper.pokemon.wallpapers.PokemonWallpaper -a android.intent.action.MAIN &>/dev/null
            mkdir -p $MODPATH/system$product/app/WallpapersBReel2020/lib/arm64
            cp -f $MODPATH/system$product/lib64/libgdx.so $MODPATH/system$product/app/WallpapersBReel2020/lib/arm64/libgdx.so
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
        no_vk "ENABLE_LIVE_WALLPAPERS"
        if $VKSEL; then
            online
            if [ $internet -eq 1 ]; then
                sed -i -e "s/Live=0/Live=1/g" $MODPATH/config.prop
                print "- Downloading Pixel LiveWallpapers"
                echo " - Downloading and Installing Pixel Wallpapers" >> $logfile
                print ""
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
                print ""
                print "  Do you want to create backup of Pixel LiveWallpapers?"
                print "  so that you don't need redownload it everytime."
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
                    echo " - Creating Backup for Pixel Wallpapers" >> $logfile
                    echo "$LWVERSION" >> /sdcard/Pixelify/version/pixel.txt
                    print " - Done"
                    print ""
                fi
                REMOVE="$REMOVE $PLW $PLW1"
                pm enable -n com.google.pixel.livewallpaper/com.google.pixel.livewallpaper.pokemon.wallpapers.PokemonWallpaper -a android.intent.action.MAIN &>/dev/null
                mkdir -p $MODPATH/system$product/app/WallpapersBReel2020/lib/arm64
                cp -f $MODPATH/system$product/lib64/libgdx.so $MODPATH/system$product/app/WallpapersBReel2020/lib/arm64/libgdx.so
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

MONET_BOOTANIMATION=0

if [ ! -z $(getprop persist.bootanim.color1) ]; then
    MONET_BOOTANIMATION=1
    print "  (Monet bootanimation rom detected)"
fi

print "  Do you want to install Pixel Bootanimation?"
print "   Vol Up += Yes"
print "   Vol Down += No"
no_vk "ENABLE_BOOTANIMATION"
if $VKSEL; then
    echo " - Installing Pixel Bootanimation" >> $logfile
    if [ -f /system/media/bootanimation.zip ]; then
        MEDIA_PATH=system/media
    else
        MEDIA_PATH=system/product/media
    fi
    boot_res=$(unzip -p /$MEDIA_PATH/bootanimation.zip desc.txt | head -n 1 | cut -d' ' -f1)
    if [ ! -z "$boot_res" ]; then
        print " - Detected $boot_res Resolution Bootanimation"
    else
        print " - Warning: Failed to detect Resolution of Bootanimation"
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
            echo " - Themed Animation not detected, using dark animation as default" >> $logfile
        fi
    else
        case "$boot_res" in
            1440)
                tar -xf $MODPATH/files/bootanimation-m-1440.tar.xz -C $MODPATH/$MEDIA_PATH
                print " - Using 1440p resolution pixel monet Bootanimation"
                ;;
            *)
                tar -xf $MODPATH/files/bootanimation-m.tar.xz -C $MODPATH/$MEDIA_PATH
                print " - Using 1080p resolution pixel monet Bootanimation"
                ;;
        esac
        cp -f $MODPATH/$MODPATH/bootanimation.zip $MODPATH/$MODPATH/bootanimation-dark.zip
    fi
else
    echo " - Skipping Pixel Bootanimation" >> $logfile
    rm -rf $MODPATH/system$product/media/boot*.zip
fi

if [ $API -ge 29 ]; then
    PL=$(find /system -name *Launcher* | grep -v overlay | grep -v Nexus | grep -v bin | grep -v "\.")
    TR=$(find /system -name *Trebuchet* | grep -v overlay | grep -v "\.")
    QS=$(find /system -name *QuickStep* | grep -v overlay | grep -v "\.")
    LW=$(find /system -name *MiuiHome* | grep -v overlay | grep -v "\.")
    TW=$(find /system -name *TouchWizHome* | grep -v overlay | grep -v "\.")
    KW=$(find /system -name *Lawnchair* | grep -v overlay | grep -v "\.")

    if [ -f /sdcard/Pixelify/backup/pl-$NEWAPI.tar.xz ]; then
        echo " - Backup Detected for Pixel Launcher" >> $logfile
        print "  Do you want to install Pixel Launcher?"
        print "  (Backup detected, no internet needed)"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        no_vk "ENABLE_PIXEL_LAUNCHER"
        if $VKSEL; then
            REMOVE="$REMOVE $PL $TR $QS $LW $TW $KW"
            if [ "$(cat /sdcard/Pixelify/version/pl-$NEWAPI.txt)" != "$PLVERSION" ]; then
                echo " - New Version Backup Detected for Pixel Launcher" >> $logfile
                echo " - Old version:$(cat /sdcard/Pixelify/version/pl-$NEWAPI.txt), New Version:  $PLVERSION " >> $logfile
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
                        echo " - Downloading and Installing New Backup for Pixel Launcher" >> $logfile
                        rm -rf /sdcard/Pixelify/backup/pl-$API.tar.xz
                        rm -rf /sdcard/Pixelify/version/pl-$API.txt
                        cd $MODPATH/files
                        if [ $NEW_PL -eq 1 ]; then
                            $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pl-new-$NEWAPI.tar.xz -O &> /proc/self/fd/$OUTFD
                            mv pl-new-$NEWAPI.tar.xz pl-$NEWAPI.tar.xz
                        else
                            $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pl-$API.tar.xz -O &> /proc/self/fd/$OUTFD
                        fi
                        cd /
                        print "- Creating Backup"
                        print ""
                        cp -f $MODPATH/files/pl-$NEWAPI.tar.xz /sdcard/Pixelify/backup/pl-$NEWAPI.tar.xz
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

            if [ $API -ge 31 ]; then
                tar -xf /sdcard/Pixelify/backup/pl-$NEWAPI.tar.xz -C $MODPATH/system$product
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
        no_vk "ENABLE_PIXEL_LAUNCHER"
        if $VKSEL; then
            online
            if [ $internet -eq 1 ]; then
                print "- Downloading Pixel Launcher"
                echo " - Downloading and Installing Pixel Launcher" >> $logfile
                print ""
                cd $MODPATH/files
                if [ $NEW_PL -eq 1 ]; then
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pl-new-$NEWAPI.tar.xz -O &> /proc/self/fd/$OUTFD
                    mv pl-new-$NEWAPI.tar.xz pl-$NEWAPI.tar.xz
                else
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pl-$API.tar.xz -O &> /proc/self/fd/$OUTFD
                fi
                cd /
                print ""
                print "- Installing Pixel Launcher"
                if [ $API -ge 31 ]; then
                    tar -xf $MODPATH/files/pl-$NEWAPI.tar.xz -C $MODPATH/system$product
                else
                    tar -xf $MODPATH/files/pl-$API.tar.xz -C $MODPATH/system$product/priv-app
                fi

                REMOVE="$REMOVE $PL $TR $QS $LW $TW $KW"
                print ""
                print "  Do you want to create backup of Pixel Launcher?"
                print "  so that you don't need redownload it everytime."
                print "   Vol Up += Yes"
                print "   Vol Down += No"
                no_vk "BACKUP_PIXEL_LAUNCHER"
                if $VKSEL; then
                    print "- Creating Backup"
                    mkdir -p /sdcard/Pixelify/backup
                    rm -rf /sdcard/Pixelify/backup/pl-$NEWAPI.tar.xz
                    cp -f $MODPATH/files/pl-$API.tar.xz /sdcard/Pixelify/backup/pl-$NEWAPI.tar.xz
                    print ""
                    mkdir -p /sdcard/Pixelify/version
                    echo " - Creating Backup for Pixel Launcher" >> $logfile
                    echo "$PLVERSION" >> /sdcard/Pixelify/version/pl-$NEWAPI.txt
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

if [ $API -ge 10000 ]; then
    PCS=$(find /system -name *PixelCameraServices* | grep -v overlay | grep -v "\.")

    if [ -f /sdcard/Pixelify/backup/pcs.tar.xz ]; then
        echo " - Backup Detected for Pixel Camera Services" >> $logfile
        print "  Do you want to install Pixel Camera Services?"
        print "  (Backup detected, no internet needed)"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        no_vk "ENABLE_PCS"
        if $VKSEL; then
            REMOVE="$REMOVE $PCS"
            if [ "$(cat /sdcard/Pixelify/version/pcs.txt)" != "$PCSVERSION" ]; then
                echo " - New Version Backup Detected forPixel Camera Services" >> $logfile
                echo " - Old version:$(cat /sdcard/Pixelify/version/pl-$NEWAPI.txt), New Version:  $PCSVERSION " >> $logfile
                print "  (Network Connection Needed)"
                print "  New version Detected "
                print "  Do you Want to update or use Old Backup?"
                print "  Version: $PCSVERSION"
                print "  Size: $PCSSIZE"
                print "   Vol Up += Update"
                print "   Vol Down += Use old backup"
                no_vk "UPDATE_PCS"
                if $VKSEL; then
                    online
                    if [ $internet -eq 1 ]; then
                        echo " - Downloading and Installing New Backup for Pixel Camera Services" >> $logfile
                        rm -rf /sdcard/Pixelify/backup/pcs.tar.xz
                        rm -rf /sdcard/Pixelify/version/pcs.txt
                        cd $MODPATH/files
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pcs.tar.xz -O &> /proc/self/fd/$OUTFD
                        cd /
                        print "- Creating Backup"
                        print ""
                        cp -f $MODPATH/files/pcs.tar.xz /sdcard/Pixelify/backup/pcs.tar.xz
                        echo " - Creating Backup for Pixel Camera Services" >> $logfile
                        echo "$PCSVERSION" >> /sdcard/Pixelify/version/pcs.txt
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
            print "- Installing Pixel Camera Services"
            print ""

            tar -xf /sdcard/Pixelify/backup/pcs.tar.xz -C $MODPATH/system
            echo "ro.vendor.camera.extensions.package=com.google.android.apps.camera.services" >> $MODPATH/system.prop
            echo "ro.vendor.camera.extensions.service=com.google.android.apps.camera.services.extensions.service.PixelExtensions" >> $MODPATH/system.prop

        else
            echo " - Skipping Pixel Camera Services" >> $logfile
        fi
    else
        print "  (Network Connection Needed)"
        print "  Do you want to install and Download Pixel Camera Services?"
        print "  Size: $PCSSIZE"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        no_vk "ENABLE_PCS"
        if $VKSEL; then
            online
            if [ $internet -eq 1 ]; then
                print "- Downloading Pixel Camera Services"
                echo " - Downloading and Installing Pixel Camera Services" >> $logfile
                print ""
                cd $MODPATH/files
                $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pcs.tar.xz -O &> /proc/self/fd/$OUTFD
                cd /
                print ""
                print "- Installing Pixel Camera Services"
                tar -xf $MODPATH/files/pcs.tar.xz -C $MODPATH/system
           	 	echo "ro.vendor.camera.extensions.package=com.google.android.apps.camera.services" >> $MODPATH/system.prop
            	echo "ro.vendor.camera.extensions.service=com.google.android.apps.camera.services.extensions.service.PixelExtensions" >> $MODPATH/system.prop

                REMOVE="$REMOVE $PCS"
                print ""
                print "  Do you want to create backup of Pixel Camera Services?"
                print "  so that you don't need redownload it everytime."
                print "   Vol Up += Yes"
                print "   Vol Down += No"
                no_vk "BACKUP_PCS"
                if $VKSEL; then
                    print "- Creating Backup"
                    mkdir -p /sdcard/Pixelify/backup
                    rm -rf /sdcard/Pixelify/backup/pcs.tar.xz
                    cp -f $MODPATH/files/pcs.tar.xz /sdcard/Pixelify/backup/pcs.tar.xz
                    print ""
                    mkdir -p /sdcard/Pixelify/version
                    echo " - Creating Backup for Pixel Camera Services" >> $logfile
                    echo "$PCSVERSION" >> /sdcard/Pixelify/version/pcs.txt
                    print " - Done"
                    print ""
                fi
            else
                print "!! Warning !!"
                print " No internet detected"
                print ""
                print "- Skipping Pixel Camera Services"
                print ""
                echo " - Skipping Pixel Camera Services due to no internet" >> $logfile
            fi
        else
            echo " - Skipping Pixel Camera Services" >> $logfile
        fi
    fi
else
    echo " - Skipping Pixel Camera Services" >> $logfile
fi

if [ $API -ge 28 ]; then
    print "  Do you want to install Google settings service?"
    # print "  (Battery Widget)"
    print "    Vol Up += Yes"
    print "    Vol Down += No"
    no_vk "ENABLE_GSI"
    if $VKSEL; then
        SI=$(find /system -name *SettingsIntelligence* | grep -v overlay | grep -v "\.")
        db_edit com.google.android.settings.intelligence boolVal 1 "RoutinesPrototype__enable_wifi_driven_bootstrap" "RoutinesPrototype__is_action_notifications_enabled" "RoutinesPrototype__is_activities_enabled" "RoutinesPrototype__is_module_enabled" "RoutinesPrototype__is_manual_location_rule_adding_enabled" "RoutinesPrototype__is_routine_inference_enabled" "BatteryWidget__is_widget_enabled" "BatteryWidget__is_enabled"
        tar -xf $MODPATH/files/sig.tar.xz -C $MODPATH/system$product/priv-app
        # cp -f $MODPATH/files/PixelifySettingsIntelligenceGoogleOverlay.apk $MODPATH/system/product/overlay/PixelifySettingsIntelligenceGoogleOverlay.apk
        # REMOVE="$REMOVE $SI"
    else
        echo " - Skipping Google settings intelligence" >> $logfile
    fi
fi

if [ $API -ge 30 ]; then
    print "  Do you want to install Extreme Battery Saver (Flipendo)?"
    print "    Vol Up += Yes"
    print "    Vol Down += No"
    no_vk "ENABLE_EXTREME_BATTERY_SAVER"
    if $VKSEL; then
        print "- Installing Extreme Battery Saver (Flipendo)"
        echo " - Installing Extreme Battery Saver (Flipendo)" >> $logfile
        cp -f $MODPATH/files/PixelifyFilpendo.apk $MODPATH/system/product/overlay/PixelifyFilpendo.apk
        if [ $NEWAPI -ge 31 ]; then
        	tar -xf $MODPATH/files/flip-31.tar.xz -C $MODPATH/system
    	else
    		tar -xf $MODPATH/files/flip-$API.tar.xz -C $MODPATH/system
    	fi
        FLIPENDO=$(find /system -name Flipendo)
        REMOVE="$REMOVE $FLIPENDO"
    else
        echo " - Skipping Extreme Battery Saver (Flipendo)" >> $logfile
    fi
fi

DISABLE_GBOARD_GMS=0

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


GBOARD=/data/data/com.google.android.inputmethod.latin/shared_prefs/flag_value.xml
if [ ! -z "$(pm list packages | grep com.google.android.inputmethod.latin)" ]; then
    print ""
    print " GBoard is installed."
    print "- Enabling Smart Compose"
    print "- Enabling Redesigned Ui"
    # print "- Enabling Lens for Gboard"
    print "- Enabling NGA Voice typing (If Nga is installed)"
    
    bool_patch nga $GBOARD
    bool_patch redesign $GBOARD
    bool_patch lens $GBOARD
    bool_patch generation $GBOARD
    bool_patch multiword $GBOARD
    bool_patch voice_promo $GBOARD
    bool_patch silk $GBOARD
    bool_patch enable_email_provider_completion $GBOARD
    bool_patch enable_multiword_predictions $GBOARD
    bool_patch_false disable_multiword_autocompletion $GBOARD
    bool_patch enable_inline_suggestions_on_decoder_side $GBOARD
    bool_patch enable_core_typing_experience_indicator_on_composing_text $GBOARD
    bool_patch enable_inline_suggestions_on_client_side $GBOARD
    bool_patch enable_core_typing_experience_indicator_on_candidates $GBOARD
    long_patch inline_suggestion_experiment_version 4 $GBOARD
    long_patch user_history_learning_strategies 1 $GBOARD
    long_patch crank_max_char_num_limit 100 $GBOARD
    long_patch crank_min_char_num_limit 5 $GBOARD
    long_patch keyboard_redesign 1 $GBOARD
    bool_patch fast_access_bar $GBOARD
    bool_patch tiresias $GBOARD
    bool_patch agsa $GBOARD
    bool_patch enable_voice $GBOARD
    bool_patch personalization $GBOARD
    bool_patch lm $GBOARD
    bool_patch feature_cards $GBOARD
    bool_patch dynamic_art $GBOARD
    bool_patch multilingual $GBOARD
    bool_patch show_suggestions_for_selected_text_while_dictating $GBOARD
    #bool_patch enable_highlight_voice_reconversion_composing_text $GBOARD
    #bool_patch enable_handling_concepts_for_contextual_bitmoji $GBOARD
    bool_patch enable_preemptive_decode $GBOARD
    bool_patch translate $GBOARD
    bool_patch tflite $GBOARD
    bool_patch enable_show_inline_suggestions_in_popup_view $GBOARD
    bool_patch enable_nebulae_materializer_v2 $GBOARD
    #bool_patch use_scrollable_candidate_for_voice $GBOARD
    bool_patch_false force_key_shadows $GBOARD
    bool_patch floating $GBOARD
    bool_patch split $GBOARD
    bool_patch grammar $GBOARD
    bool_patch spell_checker $GBOARD
    bool_patch deprecate_search $GBOARD
    bool_patch hide_composing_underline $GBOARD
    bool_patch emojify $GBOARD
    bool_patch enable_grammar_checker $GBOARD
    string_patch enable_emojify_language_tags "en" $GBOARD
    long_patch grammar_checker_min_sentence_length 3 $GBOARD
    string_patch grammar_checker_manifest_uri "https://www.gstatic.com/android/keyboard/spell_checker/experiment/memory_fix/metadata_cpu_2021102041.json" $GBOARD
    string_patch emojify_app_allowlist "com.android.mms,com.discord,com.facebook.katana,com.facebook.lite,com.facebook.orca,com.google.android.apps.dynamite,com.google.android.apps.messaging,com.google.android.youtube,com.instagram.android,com.snapchat.android,com.twitter.android,com.verizon.messaging.vzmsgs,com.viber.voip,com.whatsapp,com.zhiliaoapp.musically,jp.naver.line.android,org.telegram.messenger,tw.nekomimi.nekogram,org.telegram.BifToGram" $GBOARD

    $sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.inputmethod.latin#com.google.android.inputmethod.latin'"
    if [ $DISABLE_GBOARD_GMS -eq 0 ]; then
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin boolVal 1 "show_branding_on_space" "enable_grammar_checker" "emojify_enable_fallback_pattern" "enable_emojify_settings_option" "notify_emoji_candidate_availability" "enable_emojify_settings_option" "nga_enable_spoken_emoji_sticky_variant" "enable_emoji_predictor_tflite_engine" "enable_personalization_tracer" "enable_twiddler_multiword_engine" "enable_voice_ellipsis" "hide_composing_underline" "lm_personalization_enabled" "notify_emoji_candidate_availability" "enable_feature_split_brella" "tiresias_enabled" "enable_p13n_on_nwp_tflite_engine" "show_suggestions_for_selected_text_while_dictating" "enable_handle_emoticon_for_expression_candidates" "enable_expressive_concept_model" "show_contextual_emoji_kitchen_in_expression_moment" "enable_text_to_one_tap_expressions" "enable_expression_candidate_precaching_for_bitmoji" "enable_expression_content_cache" "enable_handle_bitmoji_for_expression_candidates" "enable_emoji_to_expression_tappable_ui" "enable_expression_moment_push_up_animation" "enable_handle_expression_moment_standard_emoji_kitchen" "enable_trigger_spell_check_in_composing" "enable_trigger_spell_check_in_sentence" "translate_new_ui" "auto_show_translate" "offline_translate" "enable_nga_ime_api" "enable_email_provider_completion" "enable_inline_suggestions_tooltip_v2" "crank_trigger_decoder_inline_prediction_first" "enable_multiword_suggestions_as_inline_from_crank_cifg" "enable_floating_keyboard_v2" "enable_multiword_predictions_from_user_history" "enable_single_word_suggestions_as_inline_from_crank_cifg" "enable_matched_predictions_as_inline_from_crank_cifg" "enable_single_word_predictions_as_inline_from_crank_cifg" "enable_inline_suggestions_space_tooltip" "enable_multiword_predictions_as_inline_from_crank_cifg" "enable_user_history_predictions_as_inline_from_crank_cifg" "crank_trigger_decoder_inline_completion_first" "enable_inline_suggestions_on_decoder_side" "enable_core_typing_experience_indicator_on_composing_text" "enable_inline_suggestions_on_client_side" "enable_core_typing_experience_indicator_on_candidates" "nga_enable_undo_delete" "nga_enable_sticky_mic" "nga_enable_spoken_emoji_sticky_variant" "nga_enable_mic_onboarding_animation" "nga_enable_mic_button_when_dictation_eligible" "enable_nga"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin intVal 2000 "inline_suggestion_dismiss_tooltip_delay_time_millis"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin intVal 4 "inline_suggestion_experiment_version"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin stringVal "https://www.gstatic.com/android/keyboard/spell_checker/experiment/memory_fix/metadata_cpu_2021102041.json" "grammar_checker_manifest_uri"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin stringVal "en" "enable_emojify_language_tags"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin intVal 0 "show_branding_interval_seconds"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin intVal 86400000 "branding_fadeout_delay_ms"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin intVal 3 "grammar_checker_min_sentence_length"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin stringVal "com.android.mms,com.discord,com.facebook.katana,com.facebook.lite,com.facebook.orca,com.google.android.apps.dynamite,com.google.android.apps.messaging,com.google.android.youtube,com.instagram.android,com.snapchat.android,com.twitter.android,com.verizon.messaging.vzmsgs,com.viber.voip,com.whatsapp,com.zhiliaoapp.musically,jp.naver.line.android,org.telegram.messenger,tw.nekomimi.nekogram,org.telegram.BifToGram" "emojify_app_allowlist"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin intVal 1 "user_history_learning_strategies" "keyboard_redesign_subset_features_new_user_timestamp"
    fi

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

install_tts() {
    print ""
    print "- Google TTS is not installed as a system app !!"
    print "- Making Google TTS as a system app"
    echo " - Making Google TTS system app" >> $logfile
    mkdir -p $MODPATH/system$product/app/GoogleTTS
    if [ -f /$app/com.google.android.tts*/base.apk ]; then
	    cp -r ~/$app/com.google.android.tts*/. $MODPATH/system$product/app/GoogleTTS
	    mv $MODPATH/system$product/app/GoogleTTS/base.apk $MODPATH/system$product/app/GoogleTTS/GoogleTTS.apk
    else
    	cp -r ~/data/adb/modules/Pixelify/system/product/app/GoogleTTS/. $MODPATH/system$product/app/GoogleTTS
    fi
    rm -rf $MODPATH/system$product/app/GoogleTTS/oat
    cp -f $MODPATH/files/PixeliflyTTS.apk $MODPATH/system/product/overlay/PixeliflyTTS.apk
    
}

if [ ! -z $(pm list packages com.google.android.tts) ]; then
    if [ -z $(pm list packages -s com.google.android.tts) ] && [ ! -f /data/adb/modules/Pixelify/system/product/app/GoogleTTS/GoogleTTS.apk ]; then
    	install_tts
    elif [ -f /data/adb/modules/Pixelify/system$product/app/GoogleTTS/GoogleTTS.apk ]; then
		install_tts
    fi
else
	print ""
    print " ! Warning !"
    print " - It is recommended to install Google TTS"
    print " - If you face any problem regarding call screening or call recording"
    print " - Then Install GoogleTTS via playstore"
    print " - Reinstall module to make it system app"
    print ""
fi

if [ $TENSOR -eq 0 ]; then
$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.apps.recorder'"
db_edit com.google.android.apps.recorder boolVal 0 "Experiment__soda_transcriber"
fi

$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.apps.wellbeing.device#com.google.android.apps.wellbeing'"
db_edit com.google.android.apps.wellbeing.device#com.google.android.apps.wellbeing boolVal 1 "ScreenTimeWidget__enable_pin_screen_time_widget_intent" "ScreenTimeWidget__enable_screen_time_widget"

if [ -f $gser ]; then
for i in "fitness.micro.show_fitness_promo" "fitness.micro.enable_active_mode_heart_rate" "fitness.micro.enable_active_mode_media_control" "photos:enable_backup_promo" "search_allow_voice_search_hints" "googletts:use_lstm"; do
    $sqlite $gser "DELETE FROM overrides WHERE name='$i'"
    # $sqlite $gser "INSERT INTO overrides(name, value) VALUES('$i', 'true')"
done
for i in "voice_search:advanced_features_enabled"; do
    $sqlite $gser "DELETE FROM overrides WHERE name='$i'"
    # $sqlite $gser "INSERT INTO overrides(name, value) VALUES('$i', '1')"
done
fi

set_perm_app() {
    out=$($MODPATH/addon/aapt d permissions $1)
    path="$(echo "$1" | sed 's/\/priv-app.*//')"
    name=$(echo $out | grep package: | cut -d' ' -f2)
    perm="$(echo $out | grep uses-permission:)"
    if [ ! -z "$perm" ]; then
        echo " - Generatings permission for package: $name" >> $logfile
        mkdir -p $path/etc/permissions
        echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>" >> $path/etc/permissions/privapp-permissions-$name.xml
        echo "<!-- " >> $path/etc/permissions/privapp-permissions-$name.xml
        echo " Generated by Pixelify Module " >> $path/etc/permissions/privapp-permissions-$name.xml
        echo "-->" >> $path/etc/permissions/privapp-permissions-$name.xml
        echo "<permissions>" >> $path/etc/permissions/privapp-permissions-$name.xml
        echo "    <privapp-permissions package=\"${name}\">" >> $path/etc/permissions/privapp-permissions-$name.xml
        for i in $perm; do
            s=$(echo $i | grep name= | cut -d= -f2 | sed "s/'/\"/g")
            if [ ! -z $s ]; then
                echo "        <permission name=$s/>" >> $path/etc/permissions/privapp-permissions-$name.xml
            fi
        done
        if [ "$name" == "com.google.android.apps.nexuslauncher" ]; then
            echo "        <permission name=\"android.permission.PACKAGE_USAGE_STATS\"/>" >> $path/etc/permissions/privapp-permissions-$name.xml
        elif [ "$name" == "com.google.android.as.oss" ]; then
            echo "        <permission name=\"android.permission.ACCESS_WIFI_STATE\"/>" >> $path/etc/permissions/privapp-permissions-$name.xml
            echo "        <permission name=\"android.permission.CHANGE_WIFI_STATE\"/>" >> $path/etc/permissions/privapp-permissions-$name.xml
        fi
        echo "    </privapp-permissions>" >> $path/etc/permissions/privapp-permissions-$name.xml
        echo "</permissions>" >> $path/etc/permissions/privapp-permissions-$name.xml
        chmod 0644 $path/etc/permissions/privapp-permissions-$name.xml
    fi
}

# Permissions for apps
for j in $MODPATH/system/*/priv-app/*/*.apk; do
    set_perm_app $j
done
for j in $MODPATH/system/priv-app/*/*.apk; do
    set_perm_app $j
done

font1='  <family name="google-sans">
    <font weight="400" style="normal">GoogleSans-Regular.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="18.0"/>
      <axis tag="wght" stylevalue="400"/>
    </font>
    <font weight="500" style="normal">GoogleSans-Regular.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="18.0"/>
      <axis tag="wght" stylevalue="500"/>
    </font>
    <font weight="600" style="normal">GoogleSans-Regular.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="18.0"/>
      <axis tag="wght" stylevalue="600"/>
    </font>
    <font weight="700" style="normal">GoogleSans-Regular.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="18.0"/>
      <axis tag="wght" stylevalue="700"/>
    </font>
    <font weight="400" style="italic">GoogleSans-Italic.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="18.0"/>
      <axis tag="wght" stylevalue="400"/>
    </font>
    <font weight="500" style="italic">GoogleSans-Italic.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="18.0"/>
      <axis tag="wght" stylevalue="500"/>
    </font>
    <font weight="600" style="italic">GoogleSans-Italic.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="18.0"/>
      <axis tag="wght" stylevalue="600"/>
    </font>
    <font weight="700" style="italic">GoogleSans-Italic.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="18.0"/>
      <axis tag="wght" stylevalue="700"/>
    </font>
  </family>'

font2='  <family name="google-sans-medium">
    <font weight="500" style="normal">GoogleSans-Regular.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="18.0"/>
      <axis tag="wght" stylevalue="500"/>
    </font>
  </family>'

font3='  <family name="google-sans-bold">
    <font weight="700" style="normal">GoogleSans-Regular.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="18.0"/>
      <axis tag="wght" stylevalue="700"/>
    </font>
  </family>'

font4='  <family name="google-sans-text">
    <font weight="400" style="normal">GoogleSans-Regular.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="17.0"/>
      <axis tag="wght" stylevalue="400"/>
    </font>
    <font weight="500" style="normal">GoogleSans-Regular.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="17.0"/>
      <axis tag="wght" stylevalue="500"/>
    </font>
    <font weight="600" style="normal">GoogleSans-Regular.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="17.0"/>
      <axis tag="wght" stylevalue="600"/>
    </font>
    <font weight="700" style="normal">GoogleSans-Regular.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="17.0"/>
      <axis tag="wght" stylevalue="700"/>
    </font>
    <font weight="400" style="italic">GoogleSans-Italic.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="17.0"/>
      <axis tag="wght" stylevalue="400"/>
    </font>
    <font weight="500" style="italic">GoogleSans-Italic.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="17.0"/>
      <axis tag="wght" stylevalue="500"/>
    </font>
    <font weight="600" style="italic">GoogleSans-Italic.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="17.0"/>
      <axis tag="wght" stylevalue="600"/>
    </font>
    <font weight="700" style="italic">GoogleSans-Italic.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="17.0"/>
      <axis tag="wght" stylevalue="700"/>
    </font>
  </family>'

font5='  <family name="google-sans-text-medium">
    <font weight="500" style="normal">GoogleSans-Regular.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="17.0"/>
      <axis tag="wght" stylevalue="500"/>
    </font>
  </family>'

font6='  <family name="google-sans-text-bold">
    <font weight="700" style="normal">GoogleSans-Regular.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="17.0"/>
      <axis tag="wght" stylevalue="700"/>
    </font>
  </family>'

font7='  <family name="google-sans-text-italic">
    <font weight="400" style="italic">GoogleSans-Italic.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="17.0"/>
      <axis tag="wght" stylevalue="400"/>
    </font>
  </family>'

font8='  <family name="google-sans-text-medium-italic">
    <font weight="500" style="italic">GoogleSans-Italic.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="17.0"/>
      <axis tag="wght" stylevalue="500"/>
    </font>
  </family>'

font9='  <family name="google-sans-text-bold-italic">
    <font weight="700" style="italic">GoogleSans-Italic.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="17.0"/>
      <axis tag="wght" stylevalue="700"/>
    </font>
  </family>'

add_font() {
    if [ -z "$(grep \"$1\" $MODPATH/system/etc/fonts.xml)" ]; then
        sed -i -e 's/<\/familyset>//g' $MODPATH/system/etc/fonts.xml
        echo "$2" >>  $MODPATH/system/etc/fonts.xml
        echo "</familyset>" >> $MODPATH/system/etc/fonts.xml
    fi
}

# if [ -f /system/etc/fonts.xml ]; then
#     cp -f /system/etc/fonts.xml $MODPATH/system/etc/fonts.xml
#     add_font google-sans "$font1"
#     add_font google-sans-medium "$font2"
#     add_font google-sans-bold "$font3"
#     add_font google-sans-text "$font4"
#     add_font google-sans-text-medium "$font5"
#     add_font google-sans-text-bold "$font6"
#     add_font google-sans-text-italic "$font7"
#     add_font google-sans-text-medium-italic "$font8"
#     add_font google-sans-text-bold-italic "$font9"
# fi


sound_patch='    <!-- Multiple sound_model_config tags can be listed, each with unique
         vendor_uuid. -->
    <sound_model_config>
        <param vendor_uuid="7038ddc8-30f2-11e6-b0ac-40a8f03d3f15" />
        <param execution_type="WDSP" /> <!-- value: "WDSP" "ADSP" "DYNAMIC" -->
        <param library="none" />
        <param max_cpe_phrases="1" />
        <param max_cpe_users="1" />
        <gcs_usecase>
            <param uid="0x1" />
            <param load_sound_model_ids="0x18000001, 0x1, 0x18000100" />
            <param start_engine_ids="0x18000001, 0x1, 0x18000101" />
            <param request_detection_ids="0x18000001, 0x4, 0x18000106" />
            <param detection_event_ids="0x18000001, 0x1, 0x00012C29" />
            <param read_cmd_ids="0x00020013, 0x1, 0x00020015" />
            <param read_rsp_ids="0x00020013, 0x1, 0x00020016" />
        </gcs_usecase>
        <!--  kw_duration is in milli seconds. It is valid only for FTRT
            transfer mode -->
        <param capture_keyword="PCM_raw, FTRT, 2000" />
        <param client_capture_read_delay="2000" />
    </sound_model_config>

    <!-- music -->
    <sound_model_config>
        <param vendor_uuid="9f6ad62a-1f0b-11e7-87c5-40a8f03d3f15" />
        <param execution_type="WDSP" /> <!-- value: "WDSP" "ADSP" "DYNAMIC" -->
        <param library="none" />
        <gcs_usecase>
            <param uid="0x2" />
            <param load_sound_model_ids="0x18000001, 0x1, 0x18000102" />
            <param start_engine_ids="0x18000001, 0x1, 0x18000103" />
            <param request_detection_ids="0x18000001, 0x4, 0x18000107" />
            <param custom_config_ids="0x18000001, 0x1, 0x18000106" />
            <param detection_event_ids="0x18000001, 0x1, 0x00012C29" />
            <param read_cmd_ids="0x00020013, 0x2, 0x00020015" />
            <param read_rsp_ids="0x00020013, 0x2, 0x00020016" />
        </gcs_usecase>
        <!--  kw_duration is in milli seconds. It is valid only for FTRT
            transfer mode -->
        <param capture_keyword="MULAW_raw, FTRT, 4000" />
        <param client_capture_read_delay="2000" />
    </sound_model_config>

    <sound_model_config>
        <param vendor_uuid="2fc815fa-4a42-11e7-99bd-40a8f03d3f15" />
        <param execution_type="WDSP" /> <!-- value: "WDSP" "ADSP" "DYNAMIC" -->
        <param library="none" />
        <gcs_usecase>
            <param uid="0x3" />
            <param load_sound_model_ids="0x18000001, 0x1, 0x18000104" />
            <param start_engine_ids="0x18000001, 0x1, 0x18000105" />
            <param detection_event_ids="0x18000001, 0x1, 0x00012C29" />
        </gcs_usecase>
        <!--  kw_duration is in milli seconds. It is valid only for FTRT
            transfer mode -->
        <param capture_keyword="PCM_raw, FTRT, 0" />
        <param client_capture_read_delay="0" />
    </sound_model_config>'


# if [ $NOT_REQ_SOUND_PATCH -eq 0 ] && [  -f /vendor/etc/sound_trigger_platform_info.xml ]; then
#     mkdir -p $MODPATH/system/vendor/etc
#     cp -f $MODPATH/files/sound_trigger_configuration.xml $MODPATH/system/vendor/etc/sound_trigger_configuration.xml
#     cp -f /vendor/etc/sound_trigger_platform_info.xml $MODPATH/system/vendor/etc/sound_trigger_platform_info.xml
#     if [ -z "$(grep \"9f6ad62a-1f0b-11e7-87c5-40a8f03d3f15\" $MODPATH/system/vendor/etc/sound_trigger_platform_info.xml)" ]; then
#         sed -i -e 's/<\/sound_trigger_platform_info>//g' $MODPATH/system/vendor/etc/sound_trigger_platform_info.xml
#         echo "$sound_patch" >>  $MODPATH/system/vendor/etc/sound_trigger_platform_info.xml
#         echo "</sound_trigger_platform_info>" >> $MODPATH/system/vendor/etc/sound_trigger_platform_info.xml
#     fi
# fi

#if [ -f $SPDB ]; then
#    $sqlite $SPDB "UPDATE pending_downloads SET requires_unmetered_network='0' WHERE superpack_name='spelling_correction'"
#    $sqlite $SPDB "UPDATE pending_downloads SET requires_idle='0' WHERE superpack_name='spelling_correction'"
#fi

REMOVE="$(echo "$REMOVE" | tr ' ' '\n' | sort -u)"
REPLACE="$REMOVE"

set_perm_recursive $MODPATH 0 0 0755 0644

for i in $MODPATH/system/vendor/overlay $MODPATH/system$product/overlay $MODPATH/system$product/priv-app/* $MODPATH/system$product/app/*; do
    set_perm_recursive $i 0 0 0755 0644
done

#Clean Up
rm -rf $MODPATH/files
rm -rf $MODPATH/spoof.prop
rm -rf $MODPATH/inc.prop

# Disable features as per API
if [ $NEWAPI -ge 32 ]; then
    rm -rf $MODPATH/system/product/overlay/PixeliflyPixel12.apk
fi

if [ $API -ge 31 ]; then
    rm -rf $MODPATH/system/product/overlay/PixelifyPixel.apk
    rm -rf $MODPATH/system/product/overlay/PixeliflyApi30.apk
    sed -i -e 's/<feature name="com.google.android.feature.ZERO_TOUCH" \/>/<!-- <feature name="com.google.android.feature.ZERO_TOUCH" \/> -->/g' $MODPATH/system/product/etc/sysconfig/pixelify.xml
    if [ $WREM -eq 1 ]; then
        rm -rf $MODPATH/system/product/priv-app/WallpaperPickerGoogleRelease
    fi
fi

if [ $API -le 30 ]; then
    rm -rf $MODPATH/system$product/overlay/PixeliflyPixelS.apk
fi

if [ $API -le 29 ]; then
    sed -i -e "s/device_config/#device_config/g" $MODPATH/service.sh
    # sed -i -e "s/sleep/#sleep/g" $MODPATH/service.sh
    rm -rf $MODPATH/system$product/priv-app/SimpleDeviceConfig
fi

if [ $API -le 27 ]; then
    sed -i -e "s/bool_patch AdaptiveCharging__v1_enabled/#bool_patch AdaptiveCharging__v1_enabled/g" $MODPATH/service.sh
fi

rm -rf $MODPATH/system/product/data
# rm -rf /data/davik-cache/*
# rm -rf /data/resources-cache/*

rm -rf $pix/apps_temp.txt $MODPATH/zygisk_1
mv $pix/app2.txt $pix/app.txt

echo " 
- Replacing apps $REMOVE
" >> $logfile 

echo " ---- Installation Finished ----" >> $logfile

print ""
print "- Done"
print ""
print " - Installation logs were saved as /sdcard/Pixelify/logs.txt"
print ""