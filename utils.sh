#!/system/bin/sh

# Check which platform should be used
check_install_type() {
    ui_print "- Riru API version: $RIRU_API"
    if [ "$RIRU_API" -lt $RIRU_MODULE_MIN_API_VERSION ]; then
        ui_print "! Riru $RIRU_MODULE_MIN_RIRU_VERSION_NAME or above is required."
        if [ "$MAGISK_VER_CODE" -ge 24000 ]; then
            MODULE_TYPE=2
            ui_print "- Switching to Magisk Zygisk"
        else
            ui_print "- Using Normal version"
        fi
    else
        MODULE_TYPE=3
        ui_print "- Using Riru instead of Zygisk"
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
        if [ $API -eq 31 ] || [ $API -eq 32 ]; then
            DPVERSION=$(echo "$ver" | grep asi-new-31 | cut -d'=' -f2)
            DPSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/asi-new-31.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb)"
        elif [ $API -eq 33 ]; then
            DPVERSION=$(echo "$ver" | grep asi-new-33 | cut -d'=' -f2)
            DPSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/asi-new-33.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb)"
        fi
        if [ $NEW_JN_PL -eq 1 ] && [ $API -eq 32 ]; then
            PLVERSION=$(echo "$ver" | grep plx-32 | cut -d'=' -f2)
            PLSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pl-j-new-32.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
        elif [ $NEW_PL -eq 1 ]; then
            PLVERSION=$(echo "$ver" | grep pl-new-$API | cut -d'=' -f2)
            PLSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pl-new-$API.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
        else
            PLVERSION=$(echo "$ver" | grep pl-$API | cut -d'=' -f2)
            PLSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pl-$API.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
        fi
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
        rm -rf $pix/nga.txt
        rm -rf $pix/pixel.txt
        rm -rf $pix/dp.txt
        rm -rf $pix/osr.txt
        rm -rf $pix/pl-$API.txt
        echo "$PCSVERSION" >>$pix/pcs.txt
        echo "$NGAVERSION" >>$pix/nga.txt
        echo "$LWVERSION" >>$pix/pixel.txt
        echo "$DPVERSION" >>$pix/dp.txt
        echo "$OSRVERSION" >>$pix/osr.txt
        echo "$PLVERSION" >>$pix/pl-$API.txt
        OSRSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/osr.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
        LWSIZE="$($MODPATH/addon/curl -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pixel.tar.xz | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
    else
        echo "! Warning, Cannot able to fetch package version, using saved version instead" >>$logfile
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
    fi
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
        print ""
        print "  Selected: Volume Up"
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
            print "  Selected: Volume Up"
            print ""
            sed -i -e "s/${CURR} \[\-/${CURR} \[\O/g" $logfile
            return 0
        elif [ $SEL -eq $DOWN ]; then
            print ""
            print "  Selected: Volume Down"
            print ""
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
    type=$2
    val=$3
    name=$1
    shift
    shift
    shift
    # echo "- $name patching started" >> $logfile
    for i in $@; do
        # echo "Patching $i to $val" >> $logfile
        $sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='$name' AND name='$i'"
        $sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, $type, committed) VALUES('$name', '', '$i', 0, $val, 0)"
        $sqlite $gms "UPDATE Flags SET $type='$val' WHERE packageName='$name' AND name='$i'"
        # for j in $gacc; do
        # $sqlite $gms "INSERT INTO FlagOverrides(packageName, user, name, flagType, $type, committed) VALUES('$name', '$j', '$i', 0, $val, 0)"
        # done
    done
    # echo "- $name patching done" >> $logfile
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
        print " -  Applying Fix for OOS 12"
        cd $MODPATH/system/product/
        cp -rf $MODPATH/system/product/. $MODPATH/system
        cd $MODPATH/system/system_ext/
        cp -rf $MODPATH/system/system_ext/. ../system
        cd /
        rm -rf $MODPATH/system/product $MODPATH/system/system_ext
        mkdir -p $MODPATH/vendor/overlay
        cp -rf $MODPATH/system/overlay/. $MODPATH/vendor/overlay
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
    cp -f $MODPATH/files/PixeliflyTTS.apk $MODPATH/system/product/overlay/PixeliflyTTS.apk

}

patch_gboard() {
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
    bool_patch show_branding_on_space $GBOARD
    bool_patch spell_checker $GBOARD
    bool_patch deprecate_search $GBOARD
    bool_patch hide_composing_underline $GBOARD
    bool_patch emojify $GBOARD
    bool_patch enable_grammar_checker $GBOARD
    string_patch enable_emojify_language_tags "en" $GBOARD
    cp -Tf $GBOARD $NEW_GBOARD
}

is_monet() {
    if [ ! -z $(getprop persist.bootanim.color1) ]; then
        MONET_BOOTANIMATION=1
        print "  (Monet bootanimation rom detected)"
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
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/osr.tar.xz -O &>/proc/self/fd/$OUTFD
                    cd /
                    print ""
                    print "- Creating Backup"
                    print ""
                    cp -Tf $MODPATH/files/osr.tar.xz /sdcard/Pixelify/backup/osr.tar.xz
                    echo "$OSRVERSION" >>/sdcard/Pixelify/version/osr.txt
                else
                    print "!! Warning !!"
                    print " No internet detected"
                    print ""
                    print "- Using Old backup for now."
                    print ""
                    echo " - using old backup for Google offline speech recognition due to no internet" >>$logfile
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
                $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/osr.tar.xz -O &>/proc/self/fd/$OUTFD
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
                print "!! Warning !!"
                print " No internet detected"
                print ""
                print "- Skipping Google offline speech recognition."
                print ""
                echo " - skipping Google offline speech recognition due to no internet" >>$logfile
            fi
        else
            echo " - skipping Google offline speech recognition" >>$logfile
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
        if [ ! -z "$(grep PIXEL_2020_ $i)" ] || [ ! -z "$(grep PIXEL_2021_ $i)" ] || [ ! -z "$(grep PIXEL_2022_ $i)" ]; then
            [ ! -f $MODPATH/system/product/etc/sysconfig/$i ] && cat /system/product/etc/sysconfig/$i | grep -v PIXEL_2020_ | grep -v PIXEL_2021_ | grep -v PIXEL_2022_ >$MODPATH/system/product/etc/sysconfig/$i
            echo " - Fixing Photos Original quality by editing $i" >>$logfile
        fi
    done
    if [ -f /data/adb/modules/Pixelify/system/product/etc/sysconfig ]; then
        for i in /data/adb/modules/Pixelify/system/product/etc/sysconfig/*; do
            if [ ! -f $MODPATH/system/product/etc/sysconfig/$i ]; then
                cp -f /data/adb/modules/Pixelify/system/product/etc/sysconfig/$i $MODPATH/system/product/etc/sysconfig/$i
                echo " - Fixing Photos Original quality by editing $i" >>$logfile
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

ok_google_hotword() {
    if [ $API -ge 30 ]; then
        print ""
        print "  (NOTE: If Ok Google working fine then dont enable it)"
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
            tar -xf $MODPATH/files/hotword.tar.xz -C $MODPATH
        fi
    fi
}
