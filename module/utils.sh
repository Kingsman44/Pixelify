#!/system/bin/sh

# Check which platform should be used
check_install_type() {
    ui_print "- Riru API version: $RIRU_API"
    if [ "$RIRU_API" -lt $RIRU_MODULE_MIN_API_VERSION ]; then
        ui_print "! Riru $RIRU_MODULE_MIN_RIRU_VERSION_NAME or above is required."
        if [ "$MAGISK_VER_CODE" -ge 24000 ]; then
            MODULE_TYPE=2
            ui_print "- Changing installation mode to zygisk"
            ui_print "- Installation Type: Zygisk"
        else
            ui_print "- Changing installation mode to normal magisk"
            ui_print "- Installation Type: Normal Magisk"
        fi
    else
        MODULE_TYPE=3
        ui_print "- Installation Type: Riru"
    fi
}

# This function will be used when util_functions.sh not exists
enforce_install_from_magisk_app() {
    if $BOOTMODE; then
        ui_print "- Installing from Magisk app"
    else
        ui_print "*********************************************************"
        ui_print "! Install from recovery is NOT supported"
        ui_print "! Some recovery has broken implementations, install with such recovery will finally cause Riru or Riru modules not working"
        ui_print "! Please install from Magisk app"
        abort "*********************************************************"
    fi
}

print() {
    ui_print "$@"
    sleep 0.3
}

online_mb() {
    while read B dummy; do
        [ $B -lt 1024 ] && echo ${B} && break
        KB=$(((B + 512) / 1024))
        [ $KB -lt 1024 ] && echo ${KB} && break
        MB=$(((KB + 512) / 1024))
        echo ${MB}
    done
}

fetch_version() {
    if [ $internet -eq 1 ]; then
        echo "- Fetching version of online packages" >>$logfile
        ver=$($MODPATH/addon/curl -s https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/version.txt)
        if [ $ENABLE_OSR -eq 1 ] || [ $DOES_NOT_REQ_SPEECH_PACK -eq 1 ]; then
            if [ $API -eq 30 ] || [ $API -ge 33 ]; then
                NGAVERSION=$(echo "$ver" | grep ngd-$API | cut -d'=' -f2)
                NGASIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/nga-new-$API.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
            else
                NGAVERSION=$(echo "$ver" | grep ngd-31 | cut -d'=' -f2)
                NGASIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/nga-new-31.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
            fi
        else
            NGAVERSION=$(echo "$ver" | grep nga | cut -d'=' -f2)
            NGASIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/nga.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
        fi
        LWVERSION=$(echo "$ver" | grep wallpaper | cut -d'=' -f2)
        OSRVERSION=$(echo "$ver" | grep os-new | cut -d'=' -f2)
        DPVERSION=$(echo "$ver" | grep dp-$API | cut -d'=' -f2)
        PCSVERSION=$(echo "$ver" | grep pcs | cut -d'=' -f2)
        GPH8VERSION=$(echo "$ver" | grep gph8 | cut -d'=' -f2)
        GPH8SIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/gphotos8.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
        PCSSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pcs.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
        DPSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/dp-$API.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb)"
        if [ $API -eq 31 ] || [ $API -eq 32 ]; then
            DPVERSION=$(echo "$ver" | grep asi-new-31 | cut -d'=' -f2)
            DPSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/asi-new-31.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb)"
        elif [ $API -eq 33 ]; then
            DPVERSION=$(echo "$ver" | grep asis-new-33 | cut -d'=' -f2)
            DPSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/asis-new-33.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb)"
        elif [ $API -eq 34 ]; then
            DPVERSION=$(echo "$ver" | grep asis-new-34 | cut -d'=' -f2)
            DPSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/asis-new-34.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb)"
        fi
        if [ $REQ_NEW_WLP -eq 1 ]; then
            WLPVERSION="$(echo "$ver" | grep wpg-new-$API | cut -d'=' -f2)"
            WLPSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/wpg-new-$API.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
        else
            WLPVERSION="$(echo "$ver" | grep wpg-$API | cut -d'=' -f2)"
            WLPSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/wpg-$API.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
        fi
        PLVERSION=$(echo "$ver" | grep pl_$API-$PL_VERSION | cut -d'=' -f2)
        PLSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/PixelLauncher/$API/$PL_VERSION.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
        if [ -z "$PLVERSION" ]; then
            echo "! Cannot fetch latest version of Pixel Launcher" >>$logfile
            PLVERSION=$PLVERSIONP
        fi
        if [ -z "$DPVERSION" ]; then
            echo "! Cannot fetch latest version of Android System Intelligence" >>$logfile
            DPVERSION=$DPVERSIONP
        fi
        if [ -z "$OSRVERSION" ]; then
            echo "! Cannot fetch latest version of OSR" >>$logfile
            OSRVERSION=$OSRVERSIONP
        fi
        if [ -z "$LWVERSION" ]; then
            echo "! Cannot fetch latest version of Live Wallpapers" >>$logfile
            LWVERSION=$LWVERSIONP
        fi
        if [ -z "$WLPVERSION" ]; then
            echo "! Cannot fetch latest version of Live Wallpapers" >>$logfile
            WLPVERSION=$WLPVERSIONP
        fi
        if [ -z "$GPH8VERSION" ]; then
            echo "! Cannot fetch latest version of Google photos" >>$logfile
            GPH8VERSION=$GPH8VERSIONP
        fi
        rm -rf $pix/nga.txt
        rm -rf $pix/pixel.txt
        rm -rf $pix/dp.txt
        rm -rf $pix/osr.txt
        rm -rf $pix/pl-$API.txt
        rm -rf $pix/wlp-$API.txt
        echo "$PCSVERSION" >>$pix/pcs.txt
        echo "$NGAVERSION" >>$pix/nga.txt
        echo "$LWVERSION" >>$pix/pixel.txt
        echo "$DPVERSION" >>$pix/dp.txt
        echo "$OSRVERSION" >>$pix/osr.txt
        echo "$PLVERSION" >>$pix/pl-$API.txt
        echo "$WLPVERSION" >>$pix/wlp-$API.txt
        echo "$GPH8VERSION" >>$pix/gph8.txt
        OSRSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/os-new.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
        LWSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pixel.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
    else
        echo " ! Cannot able to fetch package version, using saved version instead" >>$logfile
        if [ ! -f $pix/nga.txt ]; then
            echo "$NGAVERSIONP" >>$pix/nga.txt
        fi
        if [ ! -f $pix/osr.txt ]; then
            echo "$OSRVERSIONP" >>$pix/nga.txt
        fi
        if [ ! -f $pix/pcs.txt ]; then
            echo "$PCSVERSIONP" >>$pix/pcs.txt
        fi
        if [ ! -f $pix/pixel.txt ]; then
            echo "$LWVERSIONP" >>$pix/pixel.txt
        fi
        if [ ! -f $pix/dp.txt ]; then
            echo "$DPVERSIONP" >>$pix/dp.txt
        fi
        if [ ! -f $pix/pl-$API.txt ]; then
            echo "$PLVERSIONP" >>$pix/pl-$API.txt
        fi
        if [ ! -f $pix/wlp-$API.txt ]; then
            echo "$WLPVERSIONP" >>$pix/wlp-$API.txt
        fi
    fi
}

set_version() {
    OSRVERSION=$(cat $pix/osr.txt)
    NGAVERSION=$(cat $pix/nga.txt)
    LWVERSION=$(cat $pix/pixel.txt)
    DPVERSION=$(cat $pix/dp.txt)
    PCSVERSION=$(cat $pix/pcs.txt)
    PLVERSION=$(cat $pix/pl-$API.txt)
    WLPVERSION=$(cat $pix/wlp-$API.txt)
}

online() {
    s=$($MODPATH/addon/curl -s -I http://www.google.com --connect-timeout 5 | grep "ok")
    if [ ! -z "$s" ]; then
        internet=1
        echo " - Network is Online" >>$logfile
    elif [ $FORCED_ONLINE -eq 1 ]; then
        internet=1
        echo " - Network is forced to be online" >>$logfile
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
        echo "- Network is Offline" >>$logfile
    fi
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
            sed -i -e "s/${find}/${write}/g" $file
        done
    fi
}

pref_patch() {
    file=$4
    name=$1
    value=$2
    type=$3
    if [ -f $file ]; then
        exist="$(grep "\"$name\"" $file | grep $type)"
        if [ ! -z "$exist" ]; then
            old_value=$(echo "$exist" | cut -d\" -f4)
            if [ ! -z "$old_value" ]; then
                sed -i -e "s/\"$name\" value=\"$old_value\"/\"$name\" value=\"$value\"/g" $file
            else
                old_value="$(echo "$exist" | cut -d\> -f2 | cut -d\< -f1)"
                if [ ! -z "$old_value" ]; then
                    sed -i -e "s/\"$name\">$old_value</\"$name\">$value</g" $file
                fi
            fi
        else
            if [ $type != "string" ]; then
                sed -i -e "/<\/map>/i\
<$type name=\"$name\" value=\"$value\" \/>" $file
            else
                sed -i -e "/<\/map>/i\
<$type name=\"$name\">$value<\/$type>" $file
            fi
        fi
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
            str=$(grep $i $3 | grep long | cut -c 17- | cut -d'"' -f1-2)
            str1=$(grep $i $3 | grep long | cut -c 17- | cut -d'"' -f1-3)
            add="$str\"$2"
            if [ ! "$add" == "$str1" ]; then
                sed -i -e "s/${str1}/${add}/g" $file
            fi
        done
    fi
}

abort1() {
    echo "Installation Failed: $1" >>$logfile
    abort "$1"
}

keytest() {
    print "- Vol Key Test"
    print "    Press a Vol Key:"
    if (timeout 5 /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" >$TMPDIR/events); then
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
        /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" >$TMPDIR/events
        if ($(cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null)); then
            break
        fi
    done
    if ($(cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null)); then
        if [ $TURN_OFF_SEL_VOL_PROMPT -eq 0 ]; then
            print ""
            print "  Selected: Volume Up"
            print ""
        fi
        sed -i -e "s/${CURR} \[\-/${CURR} \[\O/g" $logfile
        return 0
    else
        if [ $TURN_OFF_SEL_VOL_PROMPT -eq 0 ]; then
            print ""
            print "  Selected: Volume Down"
            print ""
        fi
        sed -i -e "s/${CURR} \[\-/${CURR} \[\X/g" $logfile
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
            if [ $TURN_OFF_SEL_VOL_PROMPT -eq 0 ]; then
                print ""
                print "  Selected: Volume Up"
                print ""
            fi
            sed -i -e "s/${CURR} \[\-/${CURR} \[\O/g" $logfile
            return 0
        elif [ $SEL -eq $DOWN ]; then
            if [ $TURN_OFF_SEL_VOL_PROMPT -eq 0 ]; then
                print ""
                print "  Selected: Volume Down"
                print ""
            fi
            sed -i -e "s/${CURR} \[\-/${CURR} \[\X/g" $logfile
            return 1
        fi
    done
}

no_vk() {
    CURR="$1"
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
        sed -i -e "s/${CURR} \[\-/${CURR} \[\O/g" $logfile
        return 0
    else
        print ""
        print "  Selected: Volume Down"
        print ""
        sed -i -e "s/${CURR} \[\-/${CURR} \[\X/g" $logfile
        return 1
    fi
}

db_edit() {
    sleep .05
    name=$1
    type=$2
    if [ $type == "extensionVal" ]; then
        val=$4
        all_flags=$3
    else
        val=$3
        shift
        shift
        shift
        all_flags=$@
    fi
    OFLAGS="$("$sqlite" "$gms" "SELECT * FROM FlagOverrides WHERE packageName='$name';")"
    if [ $type == "stringVal" ]; then
        val="'$val'"
    fi
    echo "" >>$flaglogfile
    echo "========================" >>$flaglogfile
    echo "- $name patching started" >>$flaglogfile
    for i in $all_flags; do
        FF="$(echo \"$OFLAGS\" | grep $i | head -1)"
        UPDATEFLAGS=0
        echo "" >>$flaglogfile
        echo "Flag Name: $name" >>$flaglogfile
        if [ -z "$FF" ]; then
            UPDATEFLAGS=1
        elif [ "$(echo \"$FF\" | cut -d\| -f6)" != "$val" ]; then
            UPDATEFLAGS=1
            mkdir -p $MODPATH/flags
            rm -rf $MODPATH/sql.txt
            touch $MODPATH/sql.txt
            $sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='$name' AND name='$i'" &>$MODPATH/sql.txt
            echo "different value of $i present" >>$flaglogfile
            echo "Patching Status: $(cat $MODPATH/sql.txt)" >>$flaglogfile
            if [ ! -z "$(cat $MODPATH/sql.txt | grep 'Error:')" ]; then
                mkdir -p $MODPATH/flags_$type/$name
                echo "$val" >>$MODPATH/flags_$type/$name/$i
                UPDATEFLAGS=0
                echo "Error removing different value of $i" >>$flaglogfile
            fi
        else
            echo "Flag $i already present" >>$flaglogfile
        fi
        if [ $UPDATEFLAGS -eq 1 ]; then
            #$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='$name' AND name='$i'"
            #sleep .001
            rm -rf $MODPATH/sql.txt
            touch $MODPATH/sql.txt
            if [ $type == "extensionVal" ]; then
                $sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, extensionVal, committed) VALUES('$name', '', '$i', 0, x'$val', 0)" &>$MODPATH/sql.txt
            else
                $sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, $type, committed) VALUES('$name', '', '$i', 0, $val, 0)" &>$MODPATH/sql.txt
            fi
            echo "patching $i" >>$flaglogfile
            echo "Patching Status: $(cat $MODPATH/sql.txt)" >>$flaglogfile
            if [ ! -z "$(cat $MODPATH/sql.txt | grep 'Error:')" ]; then
                mkdir -p $MODPATH/flags_$type/$name
                echo "Error Patching $i adding it for next boot" >>$flaglogfile
                echo "$val" >>$MODPATH/flags_$type/$name/$i
                return
            fi
            sleep .001
            #$sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, $type, committed) VALUES('$name', '', '$i', 0, $val, 1)"
            #sleep .001
            #$sqlite $gms "UPDATE Flags SET $type='$val' WHERE packageName='$name' AND name='$i'"
            for j in $gacc; do
                rm -rf $MODPATH/sql.txt
                touch $MODPATH/sql.txt
                if [ $type == "extensionVal" ]; then
                    $sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, $type, committed) VALUES('$name', '$j', '$i', 0, x'$val', 0)" &>$MODPATH/sql.txt
                else
                    $sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, $type, committed) VALUES('$name', '$j', '$i', 0, $val, 0)" &>$MODPATH/sql.txt
                fi
                if [ ! -z "$(cat $MODPATH/sql.txt | grep 'Error:')" ]; then
                    mkdir -p $MODPATH/flags_$type/$name
                    echo "$val" >>$MODPATH/flags_$type/$name/$i
                    echo "Error Patching $i adding it for next boot" >>$flaglogfile
                    return
                fi
                sleep .001
            done
        fi
    done
    echo "- $name patching done" >>$flaglogfile
    echo "========================" >>$flaglogfile
}

db_edit_bin() {
    sleep 0.05
    rm -rf $MODPATH/sql.txt
    touch $MODPATH/sql.txt
    echo "patching $2 for $1" >>$flaglogfile
    $sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='$1' AND name='$2'" &>$MODPATH/sql.txt
    if [ ! -z "$(cat $MODPATH/sql.txt | grep 'Error:')" ]; then
        mkdir -p $MODPATH/flags_bin/$1
        echo "$3" >>$MODPATH/flags_bin/$1/$2
        echo "Error removing $2 adding it for next boot" >>$flaglogfile
        echo "$(cat $MODPATH/sql.txt)" >>$flaglogfile
        return
    fi
    rm -rf $MODPATH/sql.txt
    touch $MODPATH/sql.txt
    $sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, extensionVal, committed) VALUES('$1', '', '$2', 0, x'$3', 0)" &>$MODPATH/sql.txt
    if [ ! -z "$(cat $MODPATH/sql.txt | grep 'Error:')" ]; then
        mkdir -p $MODPATH/flags_bin/$1
        echo "$3" >>$MODPATH/flags_bin/$1/$2
        echo "Error Patching $2 adding it for next boot" >>$flaglogfile
        echo "$(cat $MODPATH/sql.txt)" >>$flaglogfile
        return
    fi
    #$sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, extensionVal, committed) VALUES('$1', '', '$2', 0, x'$3', 1)"
    #$sqlite $gms "UPDATE Flags SET extensionVal=x'$3' WHERE packageName='$1' AND name='$2'"
    for j in $gacc; do
        j=${j/.db/}
        rm -rf $MODPATH/sql.txt
        touch $MODPATH/sql.txt
        $sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, extensionVal, committed) VALUES('$1', '$j', '$2', 0, x'$3', 0)" &>$MODPATH/sql.txt
        if [ ! -z "$(cat $MODPATH/sql.txt | grep 'Error:')" ]; then
            mkdir -p $MODPATH/flags_bin/$1
            echo "$3" >>$MODPATH/flags_bin/$1/$2
            return
        fi
    done
}

sound_trigger_patch() {
    if [ $NOT_REQ_SOUND_PATCH -eq 0 ] && [ -f /vendor/etc/sound_trigger_platform_info.xml ]; then
        mkdir -p $MODPATH/system/vendor/etc
        cp -f $MODPATH/files/sound_trigger_configuration.xml $MODPATH/system/vendor/etc/sound_trigger_configuration.xml
        cp -f /vendor/etc/sound_trigger_platform_info.xml $MODPATH/system/vendor/etc/sound_trigger_platform_info.xml
        if [ -z "$(grep \"9f6ad62a-1f0b-11e7-87c5-40a8f03d3f15\" $MODPATH/system/vendor/etc/sound_trigger_platform_info.xml)" ]; then
            sed -i -e 's/<\/sound_trigger_platform_info>//g' $MODPATH/system/vendor/etc/sound_trigger_platform_info.xml
            echo "$sound_patch" >>$MODPATH/system/vendor/etc/sound_trigger_platform_info.xml
            echo "</sound_trigger_platform_info>" >>$MODPATH/system/vendor/etc/sound_trigger_platform_info.xml
        fi
    fi
}

add_font() {
    if [ -z "$(grep \"$1\" $MODPATH/system/etc/fonts.xml)" ]; then
        sed -i -e 's/<\/familyset>//g' $MODPATH/system/etc/fonts.xml
        echo "$2" >>$MODPATH/system/etc/fonts.xml
        echo "</familyset>" >>$MODPATH/system/etc/fonts.xml
    fi
}

patch_font() {
    if [ -f /system/etc/fonts.xml ]; then
        cp -f /system/etc/fonts.xml $MODPATH/system/etc/fonts.xml
        add_font google-sans "$font1"
        add_font google-sans-medium "$font2"
        add_font google-sans-bold "$font3"
        add_font google-sans-text "$font4"
        add_font google-sans-text-medium "$font5"
        add_font google-sans-text-bold "$font6"
        add_font google-sans-text-italic "$font7"
        add_font google-sans-text-medium-italic "$font8"
        add_font google-sans-text-bold-italic "$font9"
        add_font google-sans-italics-bold "$font10"
        add_font google-sans-italics-medium "$font11"
        add_font google-sans-italics "$font12"

        add_font google-sans-inter "$gfont1"
        add_font google-sans-medium-inter "$gfont2"
        add_font google-sans-bold-inter "$gfont3"
        add_font google-sans-text-inter "$gfont4"
        add_font google-sans-text-medium-inter "$gfont5"
        add_font google-sans-text-bold-inter "$gfont6"
        add_font google-sans-text-italic-inter "$gfont7"
        add_font google-sans-text-medium-italic-inter "$gfont8"
        add_font google-sans-text-bold-italic-inter "$gfont9"
    fi
}

set_perm_app() {
    out=$($MODPATH/addon/aapt d permissions $1)
    path="$(echo "$1" | sed 's/\/priv-app.*//')"
    name=$(echo $out | grep package: | cut -d' ' -f2)
    perm="$(echo $out | grep uses-permission:)"
    if [ ! -z "$perm" ]; then
        echo " - Generatings permission for package: $name" >>$logfile
        mkdir -p $path/etc/permissions
        echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>" >>$path/etc/permissions/privapp-permissions-$name.xml
        echo "<!-- " >>$path/etc/permissions/privapp-permissions-$name.xml
        echo " Generated by Pixelify Module " >>$path/etc/permissions/privapp-permissions-$name.xml
        echo "-->" >>$path/etc/permissions/privapp-permissions-$name.xml
        echo "<permissions>" >>$path/etc/permissions/privapp-permissions-$name.xml
        echo "    <privapp-permissions package=\"${name}\">" >>$path/etc/permissions/privapp-permissions-$name.xml
        for i in $perm; do
            s=$(echo $i | grep name= | cut -d= -f2 | sed "s/'/\"/g")
            if [ ! -z $s ]; then
                pm grant $name $s &>/dev/null
                echo "        <permission name=$s/>" >>$path/etc/permissions/privapp-permissions-$name.xml
            fi
        done
        if [ "$name" == "com.google.android.apps.nexuslauncher" ]; then
            echo "        <permission name=\"android.permission.PACKAGE_USAGE_STATS\"/>" >>$path/etc/permissions/privapp-permissions-$name.xml
        elif [ "$name" == "com.google.android.as.oss" ]; then
            echo "        <permission name=\"android.permission.ACCESS_WIFI_STATE\"/>" >>$path/etc/permissions/privapp-permissions-$name.xml
            echo "        <permission name=\"android.permission.CHANGE_WIFI_STATE\"/>" >>$path/etc/permissions/privapp-permissions-$name.xml
        fi
        echo "    </privapp-permissions>" >>$path/etc/permissions/privapp-permissions-$name.xml
        echo "</permissions>" >>$path/etc/permissions/privapp-permissions-$name.xml
        chmod 0644 $path/etc/permissions/privapp-permissions-$name.xml
    fi
}

oos_fix() {
    if [ $TARGET_DEVICE_OP12 -eq 1 ]; then
        echo " - Apply fixup for OOS 12/ Color OS 12" >>$logfile
        print ""
        print " -  Applying Compability Fixes"
        cd $MODPATH/system/product/
        cp -rf $MODPATH/system/product/. $MODPATH/system
        cd $MODPATH/system/system_ext/
        cp -rf $MODPATH/system/system_ext/. ../system
        cd /
        rm -rf $MODPATH/system/product $MODPATH/system/system_ext
        mkdir -p $MODPATH/vendor/overlay
        mv $MODPATH/system/overlay $MODPATH/system/vendor/overlay
        #Copy each apk on it on folder.
        for i in $MODPATH/system/vendor/overlay/*; do
            name=$i
            name=${name/$MODPATH\/system\/vendor\/overlay\//}
            name=${name/.apk/}
            if [ -f $i ]; then
                mkdir -p $MODPATH/system/vendor/overlay/$name
                mv $i $MODPATH/system/vendor/overlay/$name
                chmod 0755 $MODPATH/system/vendor/overlay/$name
                chmod 0644 $MODPATH/system/vendor/overlay/$name/*
            fi
        done
        chmod 0755 $MODPATH/system/vendor/overlay
        rm -rf $MODPATH/system/overlay
        REMOVE="$(echo $REMOVE | tr ' ' '\n' | grep -v '/product' | grep -v '/system_ext')"
    fi
}

install_tts() {
    print ""
    print "- Google TTS is not installed as a system app !!"
    print "- Making Google TTS a system app"
    echo " - Making Google TTS a system app" >>$logfile
    mkdir -p $MODPATH/system$product/app/GoogleTTS
    if [ -f /$app/com.google.android.tts*/base.apk ]; then
        cp -r ~/$app/com.google.android.tts*/. $MODPATH/system$product/app/GoogleTTS
        mv $MODPATH/system$product/app/GoogleTTS/base.apk $MODPATH/system$product/app/GoogleTTS/GoogleTTS.apk
    else
        cp -r ~/data/adb/modules/Pixelify/system/product/app/GoogleTTS/. $MODPATH/system$product/app/GoogleTTS
    fi
    rm -rf $MODPATH/system$product/app/GoogleTTS/oat
    cp -f $MODPATH/files/PixelifyTTS.apk $MODPATH/system/product/overlay/PixelifyTTS.apk

}

pl_fix() {
    if [ $LOS_FIX -eq 1 ]; then
        mkdir -p /data/data/com.google.android.apps.nexuslauncher
        if [ ! -f $PL_PREF ]; then
            echo "<?xml version='1.0' encoding='utf-8' standalone='yes' ?>" >>$PL_PREF
            echo '<map>
    <int name="launcher.home_bounce_count" value="3" />
    <boolean name="launcher.apps_view_shown" value="true" />
    <boolean name="pref_allowChromeTabResult" value="false" />
    <boolean name="pref_allowWebResultAga" value="true" />
    <int name="ALL_APPS_SEARCH_CORPUS_PREFERENCE" value="206719" />
    <boolean name="pref_allowWidgetsResult" value="false" />
    <int name="migration_src_device_type" value="0" />
    <boolean name="pref_search_show_keyboard" value="false" />
    <boolean name="pref_allowPeopleResult" value="true" />
    <boolean name="pref_enable_minus_one" value="true" />
    <string name="migration_src_workspace_size">5,5</string>
    <boolean name="pref_search_show_hidden_targets" value="false" />
    <boolean name="pref_allowWebSuggestChrome" value="false" />
    <boolean name="pref_allowPixelTipsResult" value="true" />
    <string name="idp_grid_name">normal</string>
    <boolean name="pref_allowScreenshotResult" value="true" />
    <boolean name="pref_allowMemoryResult" value="true" />
    <boolean name="pref_allowShortcutResult" value="true" />
    <boolean name="pref_allowRotation" value="false" />
    <boolean name="launcher.select_tip_seen" value="true" />
    <boolean name="pref_allowWebResult" value="true" />
    <boolean name="pref_allowSettingsResult" value="true" />
    <int name="migration_src_hotseat_count" value="5" />
    <int name="launcher.hotseat_discovery_tip_count" value="5" />
    <boolean name="pref_add_icon_to_home" value="true" />
    <string name="migration_src_db_file">launcher.db</string>
    <boolean name="pref_overview_action_suggestions" value="false" />
    <boolean name="pref_allowPlayResult" value="true" />
    <int name="launcher.all_apps_visited_count" value="10" />
</map>' >>$PL_PREF
        else
            pref_patch pref_overview_action_suggestions false boolean $PL_PREF
        fi
        am force-stop com.google.android.apps.nexuslauncher
    fi
}

patch_gboard() {
    for flag in $GBOARD_FLAGS; do
        bool_patch $flag $GBOARD
    done
    # bool_patch nga $GBOARD
    # bool_patch redesign $GBOARD
    # bool_patch lens $GBOARD
    # bool_patch generation $GBOARD
    # bool_patch multiword $GBOARD
    # bool_patch voice_promo $GBOARD
    # bool_patch silk $GBOARD
    # bool_patch enable_email_provider_completion $GBOARD
    # bool_patch enable_multiword_predictions $GBOARD
    # bool_patch_false disable_multiword_autocompletion $GBOARD
    # bool_patch enable_inline_suggestions_on_decoder_side $GBOARD
    # bool_patch enable_core_typing_experience_indicator_on_composing_text $GBOARD
    # bool_patch enable_inline_suggestions_on_client_side $GBOARD
    # bool_patch enable_core_typing_experience_indicator_on_candidates $GBOARD
    # long_patch inline_suggestion_experiment_version 4 $GBOARD
    # long_patch user_history_learning_strategies 1 $GBOARD
    # long_patch crank_max_char_num_limit 100 $GBOARD
    # long_patch crank_min_char_num_limit 5 $GBOARD
    # long_patch keyboard_redesign 1 $GBOARD
    # bool_patch fast_access_bar $GBOARD
    # bool_patch tiresias $GBOARD
    # bool_patch agsa $GBOARD
    # bool_patch enable_voice $GBOARD
    # bool_patch personalization $GBOARD
    # bool_patch lm $GBOARD
    # bool_patch feature_cards $GBOARD
    # bool_patch dynamic_art $GBOARD
    # bool_patch multilingual $GBOARD
    # bool_patch show_suggestions_for_selected_text_while_dictating $GBOARD
    # #bool_patch enable_highlight_voice_reconversion_composing_text $GBOARD
    # #bool_patch enable_handling_concepts_for_contextual_bitmoji $GBOARD
    # bool_patch enable_preemptive_decode $GBOARD
    # bool_patch translate $GBOARD
    # bool_patch tflite $GBOARD
    # bool_patch enable_show_inline_suggestions_in_popup_view $GBOARD
    # bool_patch enable_nebulae_materializer_v2 $GBOARD
    # #bool_patch use_scrollable_candidate_for_voice $GBOARD
    # bool_patch_false force_key_shadows $GBOARD
    # bool_patch floating $GBOARD
    # bool_patch split $GBOARD
    # bool_patch grammar $GBOARD
    # bool_patch show_branding_on_space $GBOARD
    # bool_patch spell_checker $GBOARD
    # bool_patch deprecate_search $GBOARD
    # bool_patch hide_composing_underline $GBOARD
    # bool_patch emojify $GBOARD
    # bool_patch enable_grammar_checker $GBOARD
    # string_patch enable_emojify_language_tags "en" $GBOARD
    cp -Tf $GBOARD $NEW_GBOARD
}

is_monet() {
    if [ ! -z $(getprop persist.bootanim.color1) ]; then
        MONET_BOOTANIMATION=1
        print "  (Monet bootanimation rom detected)"
    fi
}

install_wallpaper_with_backup() {
    if [ $WNEED -eq 1 ]; then
        if [ -f /sdcard/Pixelify/backup/wlp-$API.tar.xz ]; then
            echo " - Backup Detected for Styles and Wallpaper" >>$logfile
            print "  Do you want to install Styles and Wallpaper?"
            print "  (Backup detected, no internet needed)"
            print "   Vol Up += Yes"
            print "   Vol Down += No"
            no_vk "DOWNLOAD_WLP"
            if $VKSEL; then
                if [ "$(cat /sdcard/Pixelify/version/wlp-$API.txt)" != "$WLPVERSION" ]; then
                    echo " - New Version Backup Detected for Pixel Launcher" >>$logfile
                    echo " - Old version:$(cat /sdcard/Pixelify/version/pl-$API.txt), New Version:  $WLPVERSION " >>$logfile
                    print "  (Network Connection Needed)"
                    print "  New version Detected "
                    print "  Do you Want to update or use Old Backup?"
                    print "  Version: $WLPVERSION"
                    print "  Size: $WLPSIZE"
                    print "   Vol Up += Update"
                    print "   Vol Down += Use old backup"
                    no_vk "UPDATE_WLP"
                    if $VKSEL; then
                        online
                        if [ $internet -eq 1 ]; then
                            print "- Downloading Styles and Wallpapers"
                            echo " - Downloading and installing Styles and Wallpapers" >>$logfile
                            cd $MODPATH/files
                            if [ $REQ_NEW_WLP -eq 1 ]; then
                                $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/wpg-new-$API.tar.xz -O &>/proc/self/fd/$OUTFD
                                mv wpg-new-$API.tar.xz wlp-$API.tar.xz
                            else
                                $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/wpg-$API.tar.xz -O &>/proc/self/fd/$OUTFD
                                mv wpg-$API.tar.xz wlp-$API.tar.xz
                            fi
                            cd /
                            rm -rf /sdcard/Pixelify/backup/wlp-$API.tar.xz
                            cp -f $MODPATH/files/wlp-$API.tar.xz /sdcard/Pixelify/backup/wlp-$API.tar.xz
                            rm -rf /sdcard/Pixelify/version/wlp-$API.txt
                            echo "$WLPVERSION" >>/sdcard/Pixelify/version/wlp-$API.txt
                            #rm -rf $MODPATH/system$product/priv-app/WallpaperPickerGoogleRelease
                            # pm install $MODPATH/system$product/priv-app/WallpaperPickerGoogleRelease/*.apk
                        fi
                    fi
                fi
                print ""
                print " - Installing Styles and Wallpaper"
                WREM=0
                if [ $API -eq 34 ] || [ $REQ_NEW_WLP -eq 1 ]; then
                    tar -xf /sdcard/Pixelify/backup/wlp-$API.tar.xz -C $MODPATH/system$product
                else
                    tar -xf /sdcard/Pixelify/backup/wlp-$API.tar.xz -C $MODPATH/system$product/priv-app
                fi
                if [ $API -ge 31 ]; then
                    mkdir -p $MODPATH/system/product/app/PixelThemesStub
                    rm -rf $MODPATH/system/product/app/PixelThemesStub/PixelThemesStub.apk
                    [ $API -eq 34 ] && mv $MODPATH/files/PixelThemesStub_14.apk $MODPATH/system/product/app/PixelThemesStub/PixelThemesStub.apk
                    [ $API -eq 33 ] && mv $MODPATH/files/PixelThemesStub13.apk $MODPATH/system/product/app/PixelThemesStub/PixelThemesStub.apk
                    [ $API -le 32 ] && mv $MODPATH/files/PixelThemesStub.apk $MODPATH/system/product/app/PixelThemesStub/PixelThemesStub.apk
                fi
                if [ $API -eq 34 ]; then
                    mkdir -p $MODPATH/system/product/app/PixelThemesStub2022_and_newer
                    mv $MODPATH/files/PixelThemesStub2022_and_newer_14.apk $MODPATH/system/product/app/PixelThemesStub2022_and_newer/PixelThemesStub2022_and_newer.apk
                fi
                # pm install $MODPATH/system$product/priv-app/WallpaperPickerGoogleRelease/*.apk
                #WREM=0
            else
                echo " - Skipping Styles and Wallpaper" >>$logfile
            fi
        else
            print "  (Network Connection Needed)"
            print "  Do you want to install and Download Styles and Wallpaper?"
            print "  Size: $WLPSIZE"
            print "   Vol Up += Yes"
            print "   Vol Down += No"
            no_vk "ENABLE_WLP"
            if $VKSEL; then
                online
                if [ $internet -eq 1 ]; then
                    print "- Downloading Styles and Wallpapers"
                    echo " - Downloading and installing Styles and Wallpapers" >>$logfile
                    cd $MODPATH/files
                    if [ $REQ_NEW_WLP -eq 1 ]; then
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/wpg-new-$API.tar.xz -O &>/proc/self/fd/$OUTFD
                        mv wpg-new-$API.tar.xz wlp-$API.tar.xz
                    else
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/wpg-$API.tar.xz -O &>/proc/self/fd/$OUTFD
                        mv wpg-$API.tar.xz wlp-$API.tar.xz
                    fi
                    cd /
                    rm -rf $MODPATH/system$product/priv-app/WallpaperPickerGoogleRelease
                    print ""
                    print "- Installing Styles and Wallpapers"
                    print ""
                    if [ $API -eq 34 ] || [ $REQ_NEW_WLP -eq 1 ]; then
                        tar -xf $MODPATH/files/wlp-$API.tar.xz -C $MODPATH/system$product
                    else
                        tar -xf $MODPATH/files/wlp-$API.tar.xz -C $MODPATH/system$product/priv-app
                    fi
                    if [ $API -ge 31 ]; then
                        mkdir -p $MODPATH/system/product/app/PixelThemesStub
                        rm -rf $MODPATH/system/product/app/PixelThemesStub/PixelThemesStub.apk
                        [ $API -eq 34 ] && mv $MODPATH/files/PixelThemesStub_14.apk $MODPATH/system/product/app/PixelThemesStub/PixelThemesStub.apk
                        [ $API -eq 33 ] && mv $MODPATH/files/PixelThemesStub13.apk $MODPATH/system/product/app/PixelThemesStub/PixelThemesStub.apk
                        [ $API -le 32 ] && mv $MODPATH/files/PixelThemesStub.apk $MODPATH/system/product/app/PixelThemesStub/PixelThemesStub.apk
                    fi
                    if [ $API -eq 34 ]; then
                        mkdir -p $MODPATH/system/product/app/PixelThemesStub2022_and_newer
                        mv $MODPATH/files/PixelThemesStub2022_and_newer_14.apk $MODPATH/system/product/app/PixelThemesStub2022_and_newer/PixelThemesStub2022_and_newer.apk
                    fi
                    # pm install $MODPATH/system$product/priv-app/WallpaperPickerGoogleRelease/*.apk
                    WREM=0
                    print ""
                    print "  Do you want to create backup of Styles and Wallpaper?"
                    print "  so that you don't need redownload it every time."
                    print "   Vol Up += Yes"
                    print "   Vol Down += No"
                    no_vk "BACKUP_WLP"
                    if $VKSEL; then
                        print "- Creating Backup"
                        mkdir -p /sdcard/Pixelify/backup
                        rm -rf /sdcard/Pixelify/backup/wlp-$API.tar.xz
                        cp -f $MODPATH/files/wlp-$API.tar.xz /sdcard/Pixelify/backup/wlp-$API.tar.xz
                        print ""
                        mkdir -p /sdcard/Pixelify/version
                        echo " - Creating Backup for Styles and wallpaper" >>$logfile
                        echo "$WLPVERSION" >>/sdcard/Pixelify/version/wlp-$API.txt
                        print " - Done"
                        print ""
                    fi
                else
                    print " ! No internet detected"
                    print ""
                    print " ! Skipping Styles and Wallpaper"
                    print ""
                    echo " ! Skipping Styles and Wallpaper" >>$logfile
                    rm -rf $MODPATH/system/product/app/PixelThemesStub
                fi
            else
                echo " - Skipping Styles and Wallpaper" >>$logfile
                rm -rf $MODPATH/system/product/app/PixelThemesStub
            fi
        fi
    else
        echo " - Skipping Styles and Wallpaper" >>$logfile
        rm -rf $MODPATH/system/product/app/PixelThemesStub
    fi
}

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
                echo " - Downloading and installing Styles and Wallpapers" >>$logfile
                cd $MODPATH/files
                $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/wpg-$API.tar.xz -O &>/proc/self/fd/$OUTFD
                cd /
                rm -rf $MODPATH/system$product/priv-app/WallpaperPickerGoogleRelease
                print ""
                print "- Installing Styles and Wallpapers"
                print ""
                tar -xf $MODPATH/files/wpg-$API.tar.xz -C $MODPATH/system$product/priv-app
                if [ $API -ge 31 ]; then
                    mkdir -p $MODPATH/system/product/app/PixelThemesStub
                    rm -rf $MODPATH/system/product/app/PixelThemesStub/PixelThemesStub.apk
                    [ $API -eq 33 ] && mv $MODPATH/files/PixelThemesStub13.apk $MODPATH/system/product/app/PixelThemesStub/PixelThemesStub.apk
                    [ $API -le 32 ] && mv $MODPATH/files/PixelThemesStub.apk $MODPATH/system/product/app/PixelThemesStub/PixelThemesStub.apk
                fi
                # pm install $MODPATH/system$product/priv-app/WallpaperPickerGoogleRelease/*.apk
                WREM=0
            fi
        else
            rm -rf $MODPATH/system/product/app/PixelThemesStub
        fi
    else
        rm -rf $MODPATH/system/product/app/PixelThemesStub
    fi
}

osr_ins() {
    if [ -f /sdcard/Pixelify/backup/osr.tar.xz ]; then
        if [ "$(cat /sdcard/Pixelify/version/osr.txt)" != "$OSRVERSION" ]; then
            echo " - New Version Detected for Google offline speech recognition" >>$logfile
            echo " - Installed version: $(cat /sdcard/Pixelify/version/osr.txt) , New Version: $OSRVERSION " >>$logfile
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
                    echo " - Downloading, Installing and creating backup Google offline speech recogonition" >>$logfile
                    rm -rf /sdcard/Pixelify/backup/osr.tar.xz
                    rm -rf /sdcard/Pixelify/version/osr.txt
                    cd $MODPATH/files
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/os-new.tar.xz -O &>/proc/self/fd/$OUTFD
                    mv os-new.tar.xz osr.tar.xz
                    cd /
                    print ""
                    print "- Creating Backup"
                    print ""
                    cp -Tf $MODPATH/files/osr.tar.xz /sdcard/Pixelify/backup/osr.tar.xz
                    echo "$OSRVERSION" >>/sdcard/Pixelify/version/osr.txt
                else
                    print " ! No internet detected"
                    print ""
                    print " ! Using Old backup for now."
                    print ""
                    echo " ! using old backup for Google offline speech recognition due to no internet" >>$logfile
                fi
            else
                echo " - using old backup for Google offline speech recognition" >>$logfile
            fi
        fi
        print "- Installing Google offline speech recognition from backups"
        print ""
        tar -xf /sdcard/Pixelify/backup/osr.tar.xz -C $MODPATH/system/product

        for i in /data/data/com.google.android.tts/files/datadownload/shared/public/datadownloadfile_*; do
            if [ ! -z "$(grep 'en-US' $i/metadata)" ]; then
                rm -rf $i/*
                cp -r $MODPATH/system/product/usr/srec/en-US/. $i
                echo " - Fixing OSR for Google TTs" >>$logfile
            fi
        done

        # Remove 70xx or 50xx because it gonna available from systen side
        rm -rf /data/data/com.google.android.googlequicksearchbox/app_g3_models/en-US
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
                echo " - Downloading and Installing Google offline speech recognition" >>$logfile
                print "  Downloading Google offline speech recognition"
                cd $MODPATH/files
                $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/os-new.tar.xz -O &>/proc/self/fd/$OUTFD
                mv os-new.tar.xz osr.tar.xz
                cd /
                print " "
                print "  Extracting Google offline speech recognition"
                tar -xf $MODPATH/files/osr.tar.xz -C $MODPATH/system/product

                for i in /data/data/com.google.android.tts/files/datadownload/shared/public/datadownloadfile_*; do
                    if [ ! -z "$(grep 'en-US' $i/metadata)" ]; then
                        rm -rf $i/*
                        cp -r $MODPATH/system/product/usr/srec/en-US/. $i
                        echo " - Fixing OSR for Google TTS" >>$logfile
                    fi
                done

                # Remove 70xx or 50xx because it gonna available from system side
                rm -rf /data/data/com.google.android.googlequicksearchbox/app_g3_models/en-US

                print ""
                print "  Do you want to create backup of Google offline speech recognition"
                print "  so that you don't need redownload it everytime."
                print "   Vol Up += Yes"
                print "   Vol Down += No"
                no_vk "BACKUP_OSR"
                if $VKSEL; then
                    echo " - Creating backup for Google offline speech recognition" >>$logfile
                    print "- Creating Backup"
                    mkdir -p /sdcard/Pixelify/backup
                    rm -rf /sdcard/Pixelify/backup/osr.tar.xz
                    cp -f $MODPATH/files/osr.tar.xz /sdcard/Pixelify/backup/osr.tar.xz
                    mkdir -p /sdcard/Pixelify/version
                    echo "$OSRVERSION" >>/sdcard/Pixelify/version/osr.txt
                    print ""
                    print "- Google offline speech recognition installation complete"
                    print ""
                fi
            else
                print " ! No internet detected"
                print ""
                print " ! Skipping Google offline speech recognition."
                print ""
                echo " ! Skipping Google offline speech recognition due to no internet" >>$logfile
            fi
        else
            echo " - Skipping Google offline speech recognition" >>$logfile
        fi
    fi
}

gphotos8() {
    if [ -f /sdcard/Pixelify/backup/gphotos8.tar.xz ]; then
        if [ "$(cat /sdcard/Pixelify/version/gphotos8.txt)" != "$GPH8VERSION" ]; then
            echo " - New Version Detected for Google Photos" >>$logfile
            echo " - Installed version: $(cat /sdcard/Pixelify/version/gphotos8.txt) , New Version: $GPH8VERSION " >>$logfile
            print "  (Network Connection Needed)"
            print "  New version of Google Photos detected."
            print "  Do you Want to update or use Old Backup?"
            print "  Version: $GPH8VERSION"
            print "  Size: $GPH8SIZE"
            print "   Vol Up += Update"
            print "   Vol Down += Use old backup"
            no_vk "UPDATE_GOOGLE_PHOTOS"
            if $VKSEL; then
                online
                if [ $internet -eq 1 ]; then
                    echo " - Downloading, Installing and creating backup Google offline speech recogonition" >>$logfile
                    rm -rf /sdcard/Pixelify/backup/gphotos8.tar.xz
                    rm -rf /sdcard/Pixelify/version/gphotos8.txt
                    cd $MODPATH/files
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/gphotos8.tar.xz -O &>/proc/self/fd/$OUTFD
                    cd /
                    print ""
                    print "- Creating Backup"
                    print ""
                    cp -Tf $MODPATH/files/gphotos8.tar.xz /sdcard/Pixelify/backup/gphotos8.tar.xz
                    echo "$GPH8VERSION" >>/sdcard/Pixelify/version/gphotos8.txt
                else
                    print " ! No internet detected"
                    print ""
                    print " ! Using Old backup for now."
                    print ""
                    echo " ! using old backup for Google Photos due to no internet" >>$logfile
                fi
            else
                echo " - using old backup for Google Photos" >>$logfile
            fi
        fi
        print "- Installing Google Photos from backups"
        print ""
        mkdir $MODPATH/gphotos
        tar -xf /sdcard/Pixelify/backup/gphotos8.tar.xz -C $MODPATH/gphotos
        pm install $MODPATH/gphotos/*.apk
        rm -rf $MODPATH/gphotos
        print "- Please Disable Google Photos Auto Update on Playstore"
    else
        print "  (NOTE: It requires for Pixel 8 Features)"
        print "  (Network Connection Needed)"
        print "  Do you want to install and Download Google Photos"
        print "  Size: $GPH8SIZE"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        no_vk "DOWNLOAD_GOOGLE_PHOTOS"
        if $VKSEL; then
            online
            if [ $internet -eq 1 ]; then
                echo " - Downloading and Installing Google Photos" >>$logfile
                print "  Downloading Google Photos"
                cd $MODPATH/files
                $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/gphotos8.tar.xz -O &>/proc/self/fd/$OUTFD
                cd /
                print " "
                print "  Extracting Google Photos"
                mkdir $MODPATH/gphotos
                tar -xf $MODPATH/files/gphotos8.tar.xz -C $MODPATH/gphotos
                pm install $MODPATH/gphotos/*.apk
                rm -rf $MODPATH/gphotos
                print "- Please Disable Google Photos Auto Update on Playstore"

                print ""
                print "  Do you want to create backup of Google Photos"
                print "  so that you don't need redownload it everytime."
                print "   Vol Up += Yes"
                print "   Vol Down += No"
                no_vk "BACKUP_GOOGLE_PHOTOS"
                if $VKSEL; then
                    echo " - Creating backup for Google Photos" >>$logfile
                    print "- Creating Backup"
                    mkdir -p /sdcard/Pixelify/backup
                    rm -rf /sdcard/Pixelify/backup/gphotos8.tar.xz
                    cp -f $MODPATH/files/gphotos8.tar.xz /sdcard/Pixelify/backup/gphotos8.tar.xz
                    mkdir -p /sdcard/Pixelify/version
                    echo "$GPH8VERSION" >>/sdcard/Pixelify/version/gphotos8.txt
                    print ""
                    print "- Google Photos installation complete"
                    print ""
                fi
            else
                print " ! No internet detected"
                print ""
                print " ! Skipping Google Photos."
                print ""
                echo " ! Skipping Google Photos due to no internet" >>$logfile
            fi
        else
            echo " - Skipping Google Photos" >>$logfile
        fi
    fi
}

now_playing() {
    print ""
    print "  Note: If you are facing problem with audio then don't enable"
    print "  Do you want to enable Now Playing?"
    print "   Vol Up += Yes"
    print "   Vol Down += No"
    no_vk "ENABLE_NOW_PLAYING"
    if $VKSEL; then
        cp -f $MODPATH/files/PixeliflyNowPlaying.apk $MODPATH/system$product/overlay/PixeliflyNowPlaying.apk
        db_edit com.google.android.platform.device_personalization_services boolVal 1 "NowPlaying__capture_own_speaker_allowed" "NowPlaying__youtube_export_enabled" "NowPlaying__labs_personalized_shard_allowed" "NowPlaying__fast_recognition_ui_cleanup_enabled" "NowPlaying__ambient_music_on_demand_enabled" "NowPlaying__now_playing_allowed" "NowPlaying__ambient_music_handle_results_with_search" "NowPlaying__handle_ambient_music_results_with_history" "NowPlaying__favorites_enabled" "NowPlaying__history_summary_enabled" "NowPlaying__feature_users_count_enabled" "NowPlaying__ambient_music_notification_show_assistant_text" "NowPlaying__handle_ambient_music_results_with_assistant"
    else
        rm -rf $MODPATH/system/etc/firmware
    fi
}

drop_sys() {
    echo " - Enabling Google Photos Original quality unlimited storage" >>$logfile
    for i in /system/product/etc/sysconfig/*; do
        file=$i
        file=${file/\/system\/product\/etc\/sysconfig\//}
        if [ ! -z "$(grep PIXEL_2020_ $i)" ] || [ ! -z "$(grep PIXEL_2021_ $i)" ] || [ ! -z "$(grep PIXEL_2019_PRELOAD $i)" ] || [ ! -z "$(grep PIXEL_2018_PRELOAD $i)" ] || [ ! -z "$(grep PIXEL_2017_PRELOAD $i)" ] || [ ! -z "$(grep PIXEL_2022_ $i)" ]; then
            [ ! -f $MODPATH/system/product/etc/sysconfig/$file ] && cat /system/product/etc/sysconfig/$file | grep -v PIXEL_2020_ | grep -v PIXEL_2021_ | grep -v PIXEL_2022_ | grep -v PIXEL_2018_PRELOAD | grep -v PIXEL_2019_PRELOAD >$MODPATH/system/product/etc/sysconfig/$file
            echo " - Fixing Photos Original quality by editing $file in product" >>$logfile
        fi
    done
    for i in /system/etc/sysconfig/*; do
        file=$i
        file=${file/\/system\/etc\/sysconfig\//}
        if [ ! -z "$(grep PIXEL_2020_ $i)" ] || [ ! -z "$(grep PIXEL_2021_ $i)" ] || [ ! -z "$(grep PIXEL_2019_PRELOAD $i)" ] || [ ! -z "$(grep PIXEL_2018_PRELOAD $i)" ] || [ ! -z "$(grep PIXEL_2022_ $i)" ]; then
            [ ! -f $MODPATH/system/product/etc/sysconfig/$file ] && cat /system/etc/sysconfig/$file | grep -v PIXEL_2020_ | grep -v PIXEL_2021_ | grep -v PIXEL_2022_ | grep -v PIXEL_2018_PRELOAD | grep -v PIXEL_2019_PRELOAD | grep -v PIXEL_2017_PRELOAD >$MODPATH/system/etc/sysconfig/$file
            echo " - Fixing Photos Original quality by editing $file in system" >>$logfile
        fi
    done
    if [ -d /data/adb/modules/Pixelify/system/product/etc/sysconfig ]; then
        for i in /data/adb/modules/Pixelify/system/product/etc/sysconfig/*; do
            file=$i
            file=${file/\/data\/adb\/modules\/Pixelify\/system\/product\/etc\/sysconfig\//}
            if [ ! -f $MODPATH/system/product/etc/sysconfig/$file ]; then
                cp -f /data/adb/modules/Pixelify/system/product/etc/sysconfig/$file $MODPATH/system/product/etc/sysconfig/$file
                echo " - Fixing Photos Original quality by copying $file in product" >>$logfile
            fi
        done
    fi
    if [ -d /data/adb/modules/Pixelify/system/etc/sysconfig ]; then
        for i in /data/adb/modules/Pixelify/system/etc/sysconfig/*; do
            file=$i
            file=${file/\/data\/adb\/modules\/Pixelify\/system\/etc\/sysconfig\//}
            if [ ! -f $MODPATH/system/etc/sysconfig/$file ]; then
                cp -f /data/adb/modules/Pixelify/system/etc/sysconfig/$file $MODPATH/system/etc/sysconfig/$file
                echo " - Fixing Photos Original quality by copying $file in system" >>$logfile
            fi
        done
    fi
    if [ $KEEP_PIXEL_2021 -eq 0 ]; then
        rm -rf $MODPATH/system$product/etc/sysconfig/pixel_experience_2019_midyear.xml
        rm -rf $MODPATH/system$product/etc/sysconfig/pixel_experience_2020.xml
        rm -rf $MODPATH/system$product/etc/sysconfig/pixel_experience_2020_midyear.xml
        echo "$EMPTY_CONFIG" >>$MODPATH/system$product/etc/sysconfig/pixel_experience_2019_midyear.xml
        #touch $MODPATH/system$product/etc/sysconfig/pixel_experience_2019_midyear.xml
        echo "$EMPTY_CONFIG" >>$MODPATH/system$product/etc/sysconfig/pixel_experience_2020.xml
        echo "$EMPTY_CONFIG" >>$MODPATH/system$product/etc/sysconfig/pixel_experience_2020_midyear.xml
        rm -rf $MODPATH/system$product/etc/sysconfig/pixel_experience_2021.xml
        echo "$EMPTY_CONFIG" >>$MODPATH/system$product/etc/sysconfig/pixel_experience_2021.xml
        rm -rf $MODPATH/system$product/etc/sysconfig/pixel_experience_2021_midyear.xml
        echo "$EMPTY_CONFIG" >>$MODPATH/system$product/etc/sysconfig/pixel_experience_2021_midyear.xml
    elif [ $KEEP_PIXEL_2020 -eq 1 ]; then
        rm -rf $MODPATH/system$product/etc/sysconfig/pixel_experience_2021.xml
        echo "$EMPTY_CONFIG" >>$MODPATH/system$product/etc/sysconfig/pixel_experience_2021.xml
        rm -rf $MODPATH/system$product/etc/sysconfig/pixel_experience_2021_midyear.xml
        echo "$EMPTY_CONFIG" >>$MODPATH/system$product/etc/sysconfig/pixel_experience_2021_midyear.xml
    else
        echo " - Not removing Pixel 2021 experience as roms already hide for gphotos" >>$logfile
    fi
    rm -rf $MODPATH/system$product/etc/sysconfig/pixel_experience_2022.xml
    echo "$EMPTY_CONFIG" >>$MODPATH/system$product/etc/sysconfig/pixel_experience_2022.xml
    rm -rf $MODPATH/system$product/etc/sysconfig/pixel_experience_2022_midyear.xml
    echo "$EMPTY_CONFIG" >>$MODPATH/system$product/etc/sysconfig/pixel_experience_2022_midyear.xml
    rm -rf $MODPATH/system$product/etc/sysconfig/pixel_experience_2023.xml
    echo "$EMPTY_CONFIG" >>$MODPATH/system$product/etc/sysconfig/pixel_experience_2023.xml
    rm -rf $MODPATH/system$product/etc/sysconfig/pixel_experience_2023_midyear.xml
    echo "$EMPTY_CONFIG" >>$MODPATH/system$product/etc/sysconfig/pixel_experience_2023_midyear.xml
}

ok_google_hotword() {
    if [ $API -ge 28 ]; then
        print "  Do you want to add Hotword Blobs for OK GOOGLE?"
        print "   Vol Up += Yes"
        print "   Vol Down += No"
        no_vk "OK_GOOGLE_HOTWORD"
        if $VKSEL; then
            # mkdir -p $MODPATH/system/vendor/etc
            # if [ -f /data/adb/modules/Pixelify/system/vendor/etc/audio_policy_configuration.xml ]; then
            #     cp -f /data/adb/modules/Pixelify/system/vendor/etc/audio_policy_configuration.xml $MODPATH/system/vendor/etc/audio_policy_configuration.xml
            # else
            #     if [ -z "$(grep 'hotword input' /vendor/etc/audio_policy_configuration.xml)" ]; then
            #         cp -f /vendor/etc/audio_policy_configuration.xml $MODPATH/system/vendor/etc/audio_policy_configuration.xml
            #         if [ -z "$(grep "<audioPolicyConfiguration version=\"7.0\"" $MODPATH/system/vendor/etc/audio_policy_configuration.xml)" ]; then
            #             sed -i -e '
            #             /<\/mixPorts>/i\
            #                             <mixPort name="hotword input" role="sink" flags="AUDIO_INPUT_FLAG_HW_HOTWORD" maxActiveCount="0" >\
            #                                 <profile name="" format="AUDIO_FORMAT_PCM_16_BIT"\
            #                                          samplingRates="8000,11025,12000,16000,22050,24000,32000,44100,48000"\
            #                                          channelMasks="AUDIO_CHANNEL_IN_MONO AUDIO_CHANNEL_IN_STEREO"\/>\
            #                             <\/mixPort>
            #             ' $MODPATH/system/vendor/etc/audio_policy_configuration.xml
            #         else
            #             sed -i -e '
            #             /<\/mixPorts>/i\
            #                             <mixPort name="hotword input" role="sink" flags="AUDIO_INPUT_FLAG_HW_HOTWORD" maxActiveCount="0" >\
            #                                 <profile name="" format="AUDIO_FORMAT_PCM_16_BIT"\
            #                                          samplingRates="8000 11025 12000 16000 22050 24000 32000 44100 48000"\
            #                                          channelMasks="AUDIO_CHANNEL_IN_MONO AUDIO_CHANNEL_IN_STEREO"\/>\
            #                             <\/mixPort>
            #             ' $MODPATH/system/vendor/etc/audio_policy_configuration.xml
            #         fi
            #         sed -i -e '
            #         /<\/routes>/i\
            #                         <route type="mix" sink="hotword input"\
            #                                sources="Built-In Mic,Built-In Back Mic,Wired Headset Mic,BT SCO Headset Mic,FM Tuner,Telephony Rx"\/>
            #         ' $MODPATH/system/vendor/etc/audio_policy_configuration.xml
            #     fi
            # fi
            if [ $API -ge 30 ]; then
                tar -xf $MODPATH/files/hotword.tar.xz -C $MODPATH
            else
                tar -xf $MODPATH/files/hotword-9.tar.xz -C $MODPATH/system$product/priv-app
            fi
        fi
    fi
}

remove_samsung_dialer() {
    print ""
    print "  Note: It will be back when you uninstall or reinstall select NO"
    print "  Do you want to Remove Samsung Dialer?"
    print "   Vol Up += Yes"
    print "   Vol Down += No"
    no_vk "ENABLE_S_DIALER"
    if $VKSEL; then
        mkdir -p "$MODPATH/system/priv-app/SamsungDialer"
        touch $MODPATH/system/priv-app/SamsungDialer/SamsungDialer.apk
        mkdir -p "$MODPATH/system/priv-app/SamsungInCallUI"
        touch $MODPATH/system/priv-app/SamsungInCallUI/SamsungInCallUI.apk
    fi
}

# Function to check the existence of a property
check_prop() {
    if [ -z "$(getprop $1)" ]; then
        return 1
    else
        return 0
    fi
}

check_rom_type() {
    KEY_VERSION_MIUI="ro.miui.ui.version.name"
    KEY_VERSION_EMUI="ro.build.version.emui"
    KEY_VERSION_OPPO="ro.build.version.opporom"
    KEY_VERSION_VIVO="ro.vivo.os.version"
    KEY_VERSION_NUBIA="ro.build.nubia.rom.name"
    KEY_VERSION_ONEPLUS="ro.build.ota.versionname"
    KEY_VERSION_SAMSUNG="ro.channel.officehubrow"
    KEY_VERSION_ONEUI="ro.build.version.oneui"
    KEY_VERSION_BLACKSHARK="ro.blackshark.rom"
    KEY_VERSION_ROG="ro.asus.rog"
    KEY_VERSION_LENOVO="ro.zuk.product.market"
    KEY_VERSION_REALME="ro.build.version.realmeui"
    KEY_VERSION_COLOR="ro.build.version.oplusrom"
    KEY_VERSION_FLYME="ro.flyme.published"

    # Check each Android skin
    if check_prop $KEY_VERSION_SAMSUNG; then
        print "- Android OS: OneUI"
        ROM_TYPE="oneui"
    elif check_prop $KEY_VERSION_ONEUI; then
        print "- Android OS: OneUI"
        ROM_TYPE="oneui"
    elif check_prop $KEY_VERSION_ONEPLUS; then
        print "- Android OS: OxygenOS"
        ROM_TYPE="oos"
    elif check_prop $KEY_VERSION_MIUI; then
        print "- Android OS: MIUI"
        ROM_TYPE="miui"
    elif check_prop $KEY_VERSION_OPPO; then
        print "- Android OS: ColorOS (Oppo)"
        ROM_TYPE="coloros"
    elif check_prop $KEY_VERSION_REALME; then
        print "- Android OS: realme UI"
        ROM_TYPE="realmeui"
    elif check_prop $KEY_VERSION_VIVO; then
        print "- Android OS: Funtouch OS"
        ROM_TYPE="funtouch"
    elif check_prop $KEY_VERSION_EMUI; then
        ROM_TYPE="emui"
        print "- Android OS: EMUI"
    elif check_prop $KEY_VERSION_NUBIA; then
        ROM_TYPE="nubia"
        print "- Android OS: Nubia"
    elif check_prop $KEY_VERSION_BLACKSHARK; then
        ROM_TYPE="blackshark"
        print "- Android OS: Blackshark"
    elif check_prop $KEY_VERSION_ROG; then
        ROM_TYPE="rog"
        print "- Android OS: Asus Rog"
    elif check_prop $KEY_VERSION_LENOVO; then
        ROM_TYPE="lenovo"
        print "- Android OS: Lenovo"
    elif check_prop $KEY_VERSION_FLYME; then
        ROM_TYPE="flyme"
        print "- Android OS: Flyme OS"
    elif check_prop $KEY_VERSION_COLOR; then
        print "- Android OS: ColorOS (OnePlus)"
        ROM_TYPE="oplus"
    else
        ROM_TYPE="custom"
        print "- Android OS: Custom ROM or stock experience"
    fi
}
