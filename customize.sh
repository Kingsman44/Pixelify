#!/system/bin/sh

. $MODPATH/vars.sh || abort
. $MODPATH/utils.sh || abort

[ -z "$MAGISKTMP" ] && MAGISKTMP=/sbin

if [ -f $MAGISK_CURRENT_RIRU_MODULE_PATH/util_functions.sh ]; then
    ui_print "- Load $MAGISK_CURRENT_RIRU_MODULE_PATH/util_functions.sh"
    # shellcheck disable=SC1090
    . $MAGISK_CURRENT_RIRU_MODULE_PATH/util_functions.sh
    check_install_type
elif [ -f /data/adb/riru/util_functions.sh ]; then
    ui_print "- Load /data/adb/riru/util_functions.sh"
    . /data/adb/riru/util_functions.sh
    check_install_type
else
    if [ "$MAGISK_VER_CODE" -ge 24000 ]; then
        MODULE_TYPE=2
        ui_print "- Installation Type: Zygisk"
    else
        ui_print "- Installation Type: Normal Magisk"
    fi
fi

if [ $MODULE_TYPE -eq 2 ]; then
    mv "$ZYGISK_LIB_PATH" "$MODPATH/zygisk"
elif [ $MODULE_TYPE -eq 3 ]; then

    enforce_install_from_magisk_app
    api_level_arch_detect

    [ -z "$IS64BIT" ] && IS64BIT=false
    mkdir "$MODPATH/riru"

    if [ "$ABI32" == "armeabi-v7a" ]; then
        mv -f "$RIRU_LIB_PATH/armeabi-v7a" "$MODPATH/riru/lib"
        $IS64BIT && mv -f "$RIRU_LIB_PATH/arm64-v8a" "$MODPATH/riru/lib64"
    else
        mv -f "$RIRU_LIB_PATH/x86" "$MODPATH/riru/lib"
        $IS64BIT && mv -f "$RIRU_LIB_PATH/x86_64" "$MODPATH/riru/lib64"
    fi
fi

if [ $API -le 23 ]; then
    ui_print " x Minimum requirements doesn't meet"
    ui_print " x Android version: 7.0+"
    exit 1
fi

rm -rf $MODPATH/lib

# Check architecture
if [ "$ARCH" != "arm" ] && [ "$ARCH" != "arm64" ] && [ "$ARCH" != "x86" ] && [ "$ARCH" != "x64" ]; then
    abort " x Unsupported platform: $ARCH"
fi

alias keycheck="$MODPATH/addon/keycheck"
sqlite=$MODPATH/addon/sqlite3
VOL_KEYS="$(grep 'DEVICE_USES_VOLUME_KEY=' $MODPATH/module.prop | cut -d= -f2)"

chmod 0755 $sqlite

if [ ! -f $MODPATH/addon/curl ]; then
    mkdir -p $MODPATH/addon
    cp -f /system/bin/curl $MODPATH/addon/curl
    cp -f /system/bin/sqlite3 $MODPATH/addon/sqlite3
    cp -f /system/bin/curl $MODPATH/addon/curl
    cp -f /system/bin/dumpsys $MODPATH/addon/dumpsys
    chmod 0755 $MODPATH/addon/*
fi

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

if [ -z $exact_prop ] && [ ! -z "$(getprop org.elixir.version)" ]; then
    exact_prop="org.pixelexperience.device"
fi

rm -rf $logfile

echo "=============
   Pixelify $(cat $MODPATH/module.prop | grep version= | cut -d= -f2)
   SDK version: $API
=============
---- Installation Logs Started ----
" >>$logfile

tar -xf $MODPATH/files/system.tar.xz -C $MODPATH

chmod 0755 $MODPATH/addon/*

if [ $API -ge 31 ] && [ -d /system_ext/oplus ]; then
    TARGET_DEVICE_OP12=1
elif [ $API -ge 31 ] && [ ! -z "$(getprop ro.build.version.oneui)" ]; then
    TARGET_DEVICE_ONEUI=1
fi

online

mkdir -p /sdcard/Pixelify

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

if [ $ENABLE_OSR -eq 1 ]; then
    NGAVERSIONP=1.3
fi

sec_patch="$(getprop ro.build.version.security_patch)"
build_date="$(getprop ro.build.date.utc)"
# Greater then DEC patch 2022 or Android version 12L or greater
if [ $API -ge 32 ]; then
    NEW_PL=1
elif [ $(echo $sec_patch | cut -d- -f1) -ge 2022 ] && [ $API -ge 31 ]; then
    NEW_PL=1
elif [ $(echo $sec_patch | cut -d- -f1) -eq 2021 ] && [ $(echo $sec_patch | cut -d- -f2) -ge 12 ] && [ $API -ge 31 ]; then
    NEW_PL=1
fi

# Greater then JUN patch 2022
if [ $API -eq 32 ]; then
    if [ $(echo $sec_patch | cut -d- -f1) -le 2021 ]; then
        if [ $(date -d @$build_date +'%Y') -eq 2022 ] && [ $(date -d @$build_date +'%m' | cut -d- -f1) -ge 6 ]; then
            NEW_JN_PL=1
            NEW_PL=0
        elif [ $(date -d @$build_date +'%Y') -ge 2023 ]; then
            NEW_JN_PL=1
            NEW_PL=0
        fi
    else
        if [ $(echo $sec_patch | cut -d- -f1) -eq 2022 ] && [ $(echo $sec_patch | cut -d- -f2) -ge 6 ]; then
            NEW_JN_PL=1
            NEW_PL=0
        elif [ $(echo $sec_patch | cut -d- -f1) -ge 2023 ] && [ $API -eq 32 ]; then
            NEW_JN_PL=1
            NEW_PL=0
        fi
    fi
fi

if [ $NEW_JN_PL -eq 1 ]; then
    echo "- Pixel Launcher version required: A12L Jun" >>$logfile
elif [ $NEW_PL -eq 1 ]; then
    echo "- Pixel Launcher version required: NEW" >>$logfile
else
    echo "- Pixel Launcher version required: Normal" >>$logfile
fi

echo "
- Device info -
Codename: $(getprop ro.product.vendor.name)
Model: $(getprop ro.product.vendor.model)
security patch: $sec_patch
Magisk version: $MAGISK_VER_CODE" >>$logfile

if [ $API -eq 33 ]; then
    echo "Android version: 13" >>$logfile
    WNEED=1
    DPSIZE="52 Mb"
    WSIZE="2.2 Mb"
    PLSIZE="11 Mb"
    DPVERSIONP=2.6
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

echo " - Device info -
" >>$logfile

# Fetch latest version
fetch_version

OSRVERSION=$(cat $pix/osr.txt)
NGAVERSION=$(cat $pix/nga.txt)
LWVERSION=$(cat $pix/pixel.txt)
DPVERSION=$(cat $pix/dp.txt)
# DPSVERSION=$(cat $pix/dps.txt)
PCSVERSION=$(cat $pix/pcs.txt)
PLVERSION=$(cat $pix/pl-$API.txt)

if [ $TENSOR -eq 1 ]; then
    echo "- Tensor chip Detected..." >>$logfile
fi

if [ "$(getprop ro.product.vendor.name)" == "coral" ] || [ "$(getprop ro.product.vendor.name)" == "flame" ]; then
    echo "- Pixel 4/XL Detected !" >>$logfile
    if [ $MODULE_TYPE -eq 2 ]; then
        for i in $MODPATH/zygisk/*; do
            sed -i -e "s/com.google.android.xx/com.google.android.as/g" $i
        done
    elif [ $MODULE_TYPE -eq 3 ]; then
        for i in $MODPATH/riru/*/*; do
            sed -i -e "s/com.google.android.xx/com.google.android.as/g" $i
        done
    fi
fi

echo "
- NGA version: $NGAVERSION
- Pixel Live Wallpapers version: $NGAVERSION
- Device Personalisation Services version: $DPVERSION
- Pixel Launcher ($API) version: $PLVERSION
" >>$logfile

chmod -R 0755 $MODPATH/addon
chmod 0644 $MODPATH/files/*.xz

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

mkdir -p $MODPATH/system$product/priv-app
mkdir -p $MODPATH/system$product/app

if [ $API -ge 30 ]; then
    app=/data/app/*
else
    app=/data/app
fi

print ""
print "- Detected Arch: $ARCH"
print "- Detected SDK : $API"
RAM=$(grep MemTotal /proc/meminfo | tr -dc '0-9')
print "- Detected Ram: $RAM"
print ""
if [ $RAM -le "6000000" ]; then
    rm -rf $MODPATH/system$product/etc/sysconfig/GoogleCamera_6gb_or_more_ram.xml
    echo " - Removing GoogleCamera_6gb_or_more_ram.xml as device has less than 6Gb Ram" >>$logfile
fi

DIALER1=$(find /system -name *Dialer.apk)

GOOGLE=$(find /system -name Velvet.apk)

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

if [ $API -ge 28 ]; then
    TUR=$(find /system -name Turbo*.apk | grep -v overlay)
    REMOVE="$REMOVE $TUR"
fi

if [ -f /sdcard/Pixelify/config.prop ]; then
    vk_loc="/sdcard/Pixelify/config.prop"
else
    vk_loc="$MODPATH/config.prop"
fi

# Have user option to skip vol keys
if [ "$VOL_KEYS" -eq 0 ]; then
    print "- Skipping Vol Keys -"
    print ""
    print " Using config: $vk_loc"
    VKSEL=no_vksel
else
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

print ""
print "- Installing Pixelify Module"
print "- Extracting Files...."
print ""
echo "- Extracting Files ..." >>$logfile
if [ $API -ge 28 ]; then
    tar -xf $MODPATH/files/tur.tar.xz -C $MODPATH/system$product/priv-app
fi

if [ ! -z "$(getprop ro.rom.version | grep Oxygen)" ] || [ ! -z "$(getprop ro.miui.ui.version.code)" ] || [ ! -z "$(getprop ro.build.version.oneui)" ] && [ $API -le 30 ]; then
    echo " - Oxygen OS or MiUI or One Ui Rom Detected" >>$logfile
    SHOW_GSS=0
fi

if [ -f /sdcard/Pixelify/config.prop ] && [ $VOL_KEYS -eq 1 ]; then
    print "  (Config detected)"
    print "  Do you want to use config for installation?"
    print "   Vol Up += Yes"
    print "   Vol Down += No"
    if $VKSEL; then
        VKSEL=no_vksel
    fi
fi

# Allow now to force enable network
FIRST_ONLINE_TIME=1

echo "$var_menu" >>$logfile

if [ ! -z $exact_prop ] && [ $API -ge 31 ] && [ $BETA_BUILD -eq 1 ]; then
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
        echo " " >>$MODPATH/system.prop
        echo "$exact_prop=redfin" >>$MODPATH/system.prop
    fi
fi

[ $MAGISK_VER_CODE -ge 24000 ] && ZYGISK_P=1
if [ $TENSOR -eq 1 ]; then
    print "(TENSOR CHIPSET DETECTED)"
    print "  Do you want to enable Google Photos Unlimited Backup?"
    print "  Note: Magic Eraser will only work on the Photos app provided through my GitHub page!"
    print "   Vol Up += Yes"
    print "   Vol Down += No"
    no_vk "ENABLE_TENSOR_UNLIMITED"
    if $VKSEL; then
        echo "- Enabling Unlimited storage in this Tensor chipset device" >>$logfile
        drop_sys
    else
        echo "- Disabling Unlimited storage in this Tensor chipset device" >>$logfile
        rm -rf $MODPATH/zygisk $MODPATH/zygisk_1
    fi
elif [ $MAGISK_VER_CODE -ge 24000 ]; then
    drop_sys
else
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
        echo " - Spoofing device to $(grep ro.product.model $MODPATH/spoof.prop | cut -d'=' -f2) ( $(grep ro.product.device $MODPATH/spoof.prop | cut -d'=' -f2) )" >>$logfile
        cat $MODPATH/spoof.prop >>$MODPATH/system.prop
    else
        echo " - Ignoring spoofing device" >>$logfile
    fi
fi

if [ ! -z $(pm list packages -s | grep com.google.android.as) ]; then
    echo " - Device Personalisation Services is not installed or not installed as system app" >>$logfile
    if [ -z $(cat $pix/apps_temp.txt | grep "dp-$API") ]; then
        if [ $API -eq 30 ] && [ ! -z $($MODPATH/addon/dumpsys package com.google.android.as | grep versionName | grep pixel5) ]; then
            echo " - Ignoring Device Personalisation Services due to Pixel 5 version already installed" >>$logfile
            DPAS=0
        elif [ $API -le 29 ]; then
            DPAS=0
            echo " - Ignoring Device Personalisation Services because it's already installed" >>$logfile
        fi
    fi
fi

if [ $API -le 27 ]; then
    echo " - Disabling Device Personalisation Services installation due to the api not supported" >>$logfile
    DPAS=0
fi

if [ "$(getprop ro.product.vendor.manufacturer)" == "samsung" ]; then
    if [ ! -z "$(getprop ro.build.PDA)" ]; then
        echo " - Disabling Device Personalisation Services installation on samsung devices" >>$logfile
        DPAS=0
    fi
fi

[ -f /product/etc/firmware/music_detector.sound_model ] && rm -rf $MODPATH/system/etc/firmware && NOT_REQ_SOUND_PATCH=1

$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.platform.device_personalization_services'"
db_edit com.google.android.platform.device_personalization_services boolVal 1 " Translate__enable_language_profile_quick_update" "SmartDictation__enable_selection_filtering" "SmartRecCompose__enable_compose_tc" "Translate__beta_audio_to_text_languages_in_live_caption" "Translate__enable_chronicle_migration" "Translate__use_translate_kit_streaming_api" "SpeechRecognitionService__resumable_diarization_enabled" "Echo__smartspace_enable_grocery" "Echo_smartspace__enable_is_debug" "Echo_smartspace__enable_hotel_smartspace_aiai" "Echo_smartspace__enable_flight_landing_smartspace_aiai" "Echo__smartspace_enable_dwb_bedtime_predictor" "Translate__translation_service_enabled" "Echo__avatar_enable_feature" "SmartDictation__enable_biasing_for_commands" "SmartDictation__enable_alternatives_from_past_corrections" "SmartRecPixelSearch__enable_gboard_suggestion" "SmartRecPixelSearch__enable_spelling_correction" "Captions__enable_language_detection" "Echo__search_enable_mdp_play_results" "Echo__search_enable_superpacks_play_results" "Echo__search_enable_assistant_quick_phrases_settings" "Echo__smartspace_enable_battery_notification_parser" "Echo__smartspace_enable_ridesharing_eta" "Echo__smartspace_enable_food_delivery_eta" "Echo__smartspace_enable_eta_doordash" "SmartDictation__enable_alternatives_from_past_corrections" "SmartDictation__enable_alternatives_from_speech_hypotheses" "SmartDictation__enable_biasing_for_commands" "SmartDictation__enable_biasing_for_contacts" "SmartDictation__enable_biasing_for_contacts_learned_from_past_corrections" "SmartDictation__enable_biasing_for_interests_model" "SmartDictation__enable_biasing_for_past_correction" "SmartDictation__enable_biasing_for_screen_context" "SmartDictation__enable_personalized_biasing_on_locked_device" "SmartDictation__enable_selection_filtering" "Echo__search_enable_apps" "Captions__text_transform_augmented_input" "Captions__enable_augmented_modality" "Captions__enable_augmented_modality_input" "Echo__enable_headphones_suggestions_from_agsa" "NowPlaying__youtube_export_enabled" "Overview__enable_lens_r_overview_long_press" "Overview__enable_lens_r_overview_select_mode" "Overview__enable_lens_r_overview_translate_action" "Echo__smartspace_enable_doorbell" "Echo__smartspace_enable_earthquake_alert_predictor" "Echo__smartspace_enable_echo_settings" "Echo__smartspace_enable_light_predictor" "Echo__smartspace_enable_paired_device_predictor" "Echo__smartspace_enable_safety_check_predictor" "Echo__smartspace_enable_echo_unified_settings" "Echo__smartspace_enable_dark_launch_outlook_events" "Echo__smartspace_enable_step_predictor" "Echo__smartspace_enable_nap" "Echo__smartspace_enable_paired_device_connections" "Echo__smartspace_dedupe_fast_pair_notification" "Echo__smartspace_enable_nudge" "Echo__smartspace_enable_package_delivery" "Echo__smartspace_enable_outlook_events" "Echo__smartspace_gaia_twiddler" "Echo__smartspace_enable_eta_lyft" "Echo__smartspace_enable_sensitive_notification_twiddler" "Screenshot__enable_covid_card_action" "Screenshot__enable_lens_screenshots_search_action" "Screenshot__enable_lens_screenshots_similar_styles_action" "Screenshot__enable_lens_screenshots_translate_action" "Screenshot__enable_quick_share_smart_action" "Screenshot__enable_screenshot_notification_smart_actions" "Screenshot__enable_add_to_wallet_title" "Screenshot__can_use_gms_core_to_save_boarding_pass" "Screenshot__can_use_gpay_to_save_boarding_pass" "Echo__smartspace_enable_cross_device_timer" "Echo__smartspace_show_cross_device_timer_label" "Settings__enable_internal_settings" "People__enable_call_log_signals" "People__enable_contacts" "People__enable_dictation_client" "People__enable_hybrid_hotseat_client" "People__enable_notification_common" "People__enable_notification_signals" "People__enable_package_tracker" "People__enable_people_pecan" "People__enable_people_search_content" "People__enable_priority_suggestion_client" "People__enable_profile_signals" "People__enable_sharesheet_client" "People__enable_sms_signals" "GellerDataShare__enable_data_capture" "GellerDataShare__enable_data_fetch" "GellerDataShare__enable_settings_opt_in_switch" "SmartRecOverviewChips__enable_smartrec_for_overview_chips" "SmartRecOverviewChips__enable_settings_card_generator" "SmartRecOverviewChips__enable_reflection_generator" "SmartRecOverviewChips__enable_action_boost_generator" "SmartRecQuickSearchBox__enable_action_boost_generator" "SmartRecOverviewChips__enable_matchmaker_generator" "Echo__smartspace_enable_subcard_logging" "Echo__enable_widget_recommendations" "Echo__search_play_enable_spell_correction" "Echo__silo_enable_persistence" "Echo__settings_search_debug" "Echo__enable_people_module" "Echo__enable_nudge_debug_mode"
# db_edit com.google.android.platform.device_personalization_services boolVal 0  "SmartRecPixelSearch__spelling_checker_superpacks_require_device_idle" "SmartRecPixelSearch__spelling_checker_superpacks_require_unmetered_connection"
db_edit com.google.android.platform.launcher boolVal 1 "ENABLE_SMARTSPACE_ENHANCED" "ENABLE_WIDGETS_PICKER_AIAI_SEARCH" "enable_one_search" "inject_web_top"

if [ $DPAS -eq 1 ]; then
    echo " - Installing Android System Intelligence" >>$logfile
    if [ -f /sdcard/Pixelify/backup/dp-$API.tar.xz ]; then
        echo " - Backup Detected for Android System Intelligence" >>$logfile
        REMOVE="$REMOVE $DP"
        if [ "$(cat /sdcard/Pixelify/version/dp-$API.txt)" != "$DPVERSION" ] || [ $SEND_DPS -eq 1 ] || [ ! -f /sdcard/Pixelify/version/dp-$API.txt ] ]; then
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
                if [ $internet -eq 1 ]; then
                    echo " - Downloading and installing new backup for Android System Intelligence" >>$logfile
                    cd $MODPATH/files
                    rm -rf /sdcard/Pixelify/backup/dp-$API.tar.xz /sdcard/Pixelify/backup/dp-net-$API.tar.xz /sdcard/Pixelify/version/dp.txt /sdcard/Pixelify/version/dp-$API.txt
                    if [ $API -eq 31 ] || [ $API -eq 32 ]; then
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/asi-new-31.tar.xz -o dp-$API.tar.xz &>/proc/self/fd/$OUTFD
                    elif [ $API -ge 33 ]; then
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/asi-new-$API.tar.xz -o dp-$API.tar.xz &>/proc/self/fd/$OUTFD
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
        now_playing
        print "- Installing Android System Intelligence"
        print ""
        cp -f $MODPATH/files/PixeliflyDPS.apk $MODPATH/system/product/overlay/PixeliflyDPS.apk
        tar -xf /sdcard/Pixelify/backup/dp-$API.tar.xz -C $MODPATH/system$product/priv-app
        echo dp-$API >$pix/app2.txt
    else
        print ""
        echo " - No backup Detected for Android System Intelligence" >>$logfile
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
                echo " - Downloading and installing Android System Intelligence" >>$logfile
                print ""
                cd $MODPATH/files
                if [ $API -ge 31 ]; then
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/asi-new-31.tar.xz -o dp-$API.tar.xz &>/proc/self/fd/$OUTFD
                else
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/dp-$API.tar.xz -O &>/proc/self/fd/$OUTFD
                fi
                cd /
                now_playing
                print ""
                print "- Installing Android System Intelligence"
                cp -f $MODPATH/files/PixeliflyDPS.apk $MODPATH/system/product/overlay/PixeliflyDPS.apk
                tar -xf $MODPATH/files/dp-$API.tar.xz -C $MODPATH/system$product/priv-app
                echo dp-$API >$pix/app2.txt
                REMOVE="$REMOVE $DP"
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

# Google Dialer
if [ -d /data/data/$DIALER ]; then
    print "  Do you want to install Google Dialer features?"
    print "   - Includes Call Screening, Call Recording, Hold for Me, Direct My Call"
    print "   (For all Countries)"
    print "    Vol Up += Yes"
    print "    Vol Down += No"
    no_vk "ENABLE_DIALER_FEATURES"
    if $VKSEL; then
        echo " - Installing Google Dialer features" >>$logfile
        sed -i -e "s/CallScreening=0/CallScreening=1/g" $MODPATH/var.prop
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

        db_edit com.google.android.dialer floatVal "1.0" "G__call_screen_audio_stitching_downlink_volume_multiplier"
        db_edit com.google.android.dialer floatVal "0.6" "G__call_screen_audio_stitching_uplink_volume_multiplier"
        db_edit com.google.android.dialer intVal "1000" "G__embedding_generation_step_size"
        # db_edit com.google.android.dialer stringVal 'CgxhdGxhcy1tb2RlbHMSpAESYmh0dHBzOi8vZGwuZ29vZ2xlLmNvbS9oZm0vWkpiM2xJODEybzM3UnFMTVFwYnlRRWo5ZjcwYU9FRm40SjJ5ckNwblNRWWlpSlBiS0hKQkFORHVjb0lONDA5Zy92MjUuemlwIMWr0QgqKDUxY2MzOTA3NGNiZmQ5NzBkMWIxYmJmMWMxZmEyMmJhYjgwMDdiYzg6D2RldGVjdGlvbl9tb2RlbBiAxgpQt/WviwZqCAgAEAIggPUk' "G__atlas_mdd_ph_config"
        if [ $CUSTOM_CALL_SCREEN -eq 0 ]; then
            print " "
            print "- Please set your language to"
            print "  English (United States) for call screening to work"
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

        carr="$(getprop gsm.sim.operator.numeric)"
        carrier=${#carr}
        case $carrier in
        6)
            sed -i -e "s/310004/${carr}/g" $MODPATH/files/com.google.android.dialer
            ;;
        5)
            sed -i -e "s/21403/${carr}/g" $MODPATH/files/com.google.android.dialer
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
            echo " - Adding Country ($carr_coun) patch for Call Recording and Hold for me, Direct My Call" >>$logfile
            if [ -z $(echo "AU US JP" | grep $carr_coun) ]; then
                sed -i -e "s/YY/${carr_coun}/g" $MODPATH/files/com.google.android.dialer
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
            print "- Making Google Dialer a system app"
            echo " - Making Google Dialer a system app" >>$logfile
            print ""
            cp -r ~/$app/com.google.android.dialer*/. $MODPATH/system$product/priv-app/GoogleDialer
            mv $MODPATH/system$product/priv-app/GoogleDialer/base.apk $MODPATH/system$product/priv-app/GoogleDialer/GoogleDialer.apk
            rm -rf $MODPATH/system$product/priv-app/GoogleDialer/oat
        elif [ -f /data/adb/modules/Pixelify/system/product/app/GoogleDialer/GoogleDialer.apk ]; then
            print ""
            print "- Google Dialer is not installed as a system app !!"
            print "- Making Google Dialer a system app"
            echo " - Making Google Dialer a system app" >>$logfile
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

if [ -d /data/data/com.google.android.googlequicksearchbox ] && [ $API -ge 29 ] && [ $TARGET_DEVICE_ONEUI -eq 0 ]; then
    print "  Google is installed."
    print "  Do you want to installed Next generation assistant?"
    print "   Vol Up += Yes"
    print "   Vol Down += No"
    no_vk "ENABLE_NGA"
    if $VKSEL; then
        echo " - Installing Next generation assistant" >>$logfile
        if [ -f /sdcard/Pixelify/backup/nga.tar.xz ] || [ -f /sdcard/Pixelify/backup/NgaResources.apk ]; then
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
                    online
                    if [ $internet -eq 1 ]; then
                        echo " - Downloading, Installing and creating backup NGA Resources" >>$logfile
                        rm -rf /sdcard/Pixelify/backup/NgaResources.apk
                        rm -rf /sdcard/Pixelify/backup/nga.tar.xz
                        rm -rf /sdcard/Pixelify/version/nga.txt
                        cd $MODPATH/files
                        if [ $ENABLE_OSR -eq 1 ]; then
                            $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/nga-new.tar.xz -o nga.tar.xz &>/proc/self/fd/$OUTFD
                        else
                            $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/nga.tar.xz -o nga.tar.xz &>/proc/self/fd/$OUTFD
                        fi
                        cd /
                        print ""
                        print "- Creating Backup"
                        print ""
                        cp -Tf $MODPATH/files/nga.tar.xz /sdcard/Pixelify/backup/nga.tar.xz
                        echo "$NGAVERSION" >>/sdcard/Pixelify/version/nga.txt
                    else
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

        $sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.googlequicksearchbox'"
        # db_edit com.google.android.googlequicksearchbox boolVal 0 "45351541" "9670" "8888" "15052" "45363987" "45363985" "45359819"
        db_edit com.google.android.googlequicksearchbox boolVal 1 "9243"
        db_edit com.google.android.googlequicksearchbox stringVal 'Pixel 7 Pro,Pixel 7,Pixel 6a,Pixel 6,Pixel 6 Pro,Pixel 5,Pixel 3XL' '17074'
        db_edit com.google.android.googlequicksearchbox stringVal 'Oriole,oriole,Raven,raven,Pixel 6,Pixel 6 Pro,redfin,Redfin,Pixel 5,crosshatch,Pixel 3XL,Pixel 7 Pro,Pixel 7,Redmi Note 4,mido' '45353661'

        cp -f $MODPATH/files/nga.xml $MODPATH/system$product/etc/sysconfig/nga.xml
        cp -f $MODPATH/files/PixeliflyGA.apk $MODPATH/system/product/overlay/PixeliflyGA.apk
        ok_google_hotword
        if [ $ENABLE_OSR -eq 1 ]; then
            osr_ins
        fi
        is_velvet="$(grep velvet= $FORCE_FILE | cut -d= -f2)"
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
            print "- Making Google a system app"
            echo " - Making Google a system app" >>$logfile
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
                print "- Making Google a system app"
                echo " - Making Google a system app" >>$logfile
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
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pixel.tar.xz -O &>/proc/self/fd/$OUTFD
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
            install_wallpaper
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
                $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pixel.tar.xz -O &>/proc/self/fd/$OUTFD
                cd /
                print ""
                print "- Installing Pixel LiveWallpapers"
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
                install_wallpaper
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
        if [ $TARGET_DEVICE_OP12 -eq 1 ]; then
            REMOVE="$REMOVE /system/product/media/bootanimation.zip /system/product/media/bootanimation-dark.zip"
        fi
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
            cp -f $MODPATH/$MODPATH/bootanimation.zip $MODPATH/$MODPATH/bootanimation-dark.zip
        fi
    else
        echo " - Skipping Pixel Bootanimation" >>$logfile
        rm -rf $MODPATH/system$product/media/boot*.zip
    fi
else
    rm -rf $MODPATH/system$product/media/boot*.zip
fi

# Pixel Launcher
if [ $API -ge 29 ] && [ $TARGET_DEVICE_OP12 -eq 0 ]; then
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
                        if [ $NEW_JN_PL -eq 1 ] && [ $API -eq 32 ]; then
                            $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pl-j-new-$API.tar.xz -O &>/proc/self/fd/$OUTFD
                            mv pl-j-new-$API.tar.xz pl-$API.tar.xz
                        elif [ $NEW_PL -eq 1 ]; then
                            $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pl-new-$API.tar.xz -O &>/proc/self/fd/$OUTFD
                            mv pl-new-$API.tar.xz pl-$API.tar.xz
                        else
                            $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pl-$API.tar.xz -O &>/proc/self/fd/$OUTFD
                        fi
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

            if [ $API -ge 31 ]; then
                tar -xf /sdcard/Pixelify/backup/pl-$API.tar.xz -C $MODPATH/system$product
            else
                tar -xf /sdcard/Pixelify/backup/pl-$API.tar.xz -C $MODPATH/system$product/priv-app
            fi

            if [ $WALL_DID -eq 0 ]; then
                install_wallpaper
            fi
        else
            echo " - Skipping Pixel Launcher" >>$logfile
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
                echo " - Downloading and Installing Pixel Launcher" >>$logfile
                print ""
                cd $MODPATH/files
                if [ $NEW_JN_PL -eq 1 ] && [ $API -eq 32 ]; then
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pl-j-new-32.tar.xz -O &>/proc/self/fd/$OUTFD
                    mv pl-j-new-$API.tar.xz pl-$API.tar.xz
                elif [ $NEW_PL -eq 1 ]; then
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pl-new-$API.tar.xz -O &>/proc/self/fd/$OUTFD
                    mv pl-new-$API.tar.xz pl-$API.tar.xz
                else
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pl-$API.tar.xz -O &>/proc/self/fd/$OUTFD
                fi
                cd /
                print ""
                print "- Installing Pixel Launcher"
                if [ $API -ge 31 ]; then
                    tar -xf $MODPATH/files/pl-$API.tar.xz -C $MODPATH/system$product
                else
                    tar -xf $MODPATH/files/pl-$API.tar.xz -C $MODPATH/system$product/priv-app
                fi

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
                    install_wallpaper
                fi
            else
                print " ! No internet detected"
                print ""
                print " ! Skipping Pixel launcher"
                print ""
                echo " ! Skipping Pixel Launcher due to no internet" >>$logfile
                rm -rf $MODPATH/system/product/overlay/PixelLauncherOverlay.apk
            fi
        else
            echo " - Skipping Pixel Launcher" >>$logfile
            rm -rf $MODPATH/system/product/overlay/PixelLauncherOverlay.apk
        fi
    fi
else
    echo " - Skipping Pixel Launcher" >>$logfile
    rm -rf $MODPATH/system/product/overlay/PixelLauncherOverlay.apk
fi

# Adding Google san font.
# print ""
# print "  (NOTE: Playstore or Google or GMS crashes then dont enable it)"
# print "  Do you want add Google San Fonts?"
# print "    Vol Up += Yes"
# print "    Vol Down += No"
# no_vk "GSAN_FONT"
# if $VKSEL; then
#     patch_font
# else
#     rm -rf $MODPATH/system/product/overlay/PixelifyGsan*.apk
#     rm -rf $MODPATH/system/product/overlay/GInterOverlay.apk
# fi
rm -rf $MODPATH/system/product/overlay/PixelifyGsan*.apk
rm -rf $MODPATH/system/product/overlay/GInterOverlay.apk
rm -rf $MODPATH/system/fonts

# Google Settings service
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
        if [ $API -ge 31 ]; then
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

    $sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.inputmethod.latin#com.google.android.inputmethod.latin'"
    if [ $DISABLE_GBOARD_GMS -eq 0 ]; then
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin boolVal 1 "grammer_checker_enable_language_detector" "enable_nav_redesign" "show_branding_on_space" "enable_grammar_checker" "emojify_enable_fallback_pattern" "enable_emojify_settings_option" "notify_emoji_candidate_availability" "enable_emojify_settings_option" "nga_enable_spoken_emoji_sticky_variant" "enable_emoji_predictor_tflite_engine" "enable_personalization_tracer" "enable_twiddler_multiword_engine" "enable_voice_ellipsis" "hide_composing_underline" "lm_personalization_enabled" "notify_emoji_candidate_availability" "enable_feature_split_brella" "tiresias_enabled" "enable_p13n_on_nwp_tflite_engine" "show_suggestions_for_selected_text_while_dictating" "enable_handle_emoticon_for_expression_candidates" "enable_expressive_concept_model" "show_contextual_emoji_kitchen_in_expression_moment" "enable_text_to_one_tap_expressions" "enable_expression_candidate_precaching_for_bitmoji" "enable_expression_content_cache" "enable_handle_bitmoji_for_expression_candidates" "enable_emoji_to_expression_tappable_ui" "enable_expression_moment_push_up_animation" "enable_handle_expression_moment_standard_emoji_kitchen" "enable_trigger_spell_check_in_composing" "enable_trigger_spell_check_in_sentence" "translate_new_ui" "auto_show_translate" "offline_translate" "enable_nga_ime_api" "enable_email_provider_completion" "enable_inline_suggestions_tooltip_v2" "crank_trigger_decoder_inline_prediction_first" "enable_multiword_suggestions_as_inline_from_crank_cifg" "enable_floating_keyboard_v2" "enable_multiword_predictions_from_user_history" "enable_single_word_suggestions_as_inline_from_crank_cifg" "enable_matched_predictions_as_inline_from_crank_cifg" "enable_single_word_predictions_as_inline_from_crank_cifg" "enable_inline_suggestions_space_tooltip" "enable_multiword_predictions_as_inline_from_crank_cifg" "enable_user_history_predictions_as_inline_from_crank_cifg" "crank_trigger_decoder_inline_completion_first" "enable_inline_suggestions_on_decoder_side" "enable_core_typing_experience_indicator_on_composing_text" "enable_inline_suggestions_on_client_side" "enable_core_typing_experience_indicator_on_candidates" "nga_enable_undo_delete" "nga_enable_sticky_mic" "nga_enable_spoken_emoji_sticky_variant" "nga_enable_mic_onboarding_animation" "nga_enable_mic_button_when_dictation_eligible" "enable_nga"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin intVal 2000 "inline_suggestion_dismiss_tooltip_delay_time_millis"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin intVal 4 "inline_suggestion_experiment_version"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin stringVal "https://www.gstatic.com/android/keyboard/spell_checker/experiment/memory_fix/metadata_cpu_2021102041.json" "grammar_checker_manifest_uri"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin stringVal "en" "enable_emojify_language_tags"
        # G Logo
        print ""
        print "  Do you want enable G logo in google keyboard?"
        print "  Note: Enabling it will not show you languages in spacebar"
        print "    Vol Up += Yes"
        print "    Vol Down += No"
        no_vk "G_LOGO"
        if $VKSEL; then
            db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin intVal 0 "show_branding_interval_seconds"
            db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin intVal 86400000 "branding_fadeout_delay_ms"
        fi
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin intVal 3 "grammar_checker_min_sentence_length"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin stringVal "com.android.mms,com.discord,com.facebook.katana,com.facebook.lite,com.facebook.orca,com.google.android.apps.dynamite,com.google.android.apps.messaging,com.google.android.youtube,com.instagram.android,com.snapchat.android,com.twitter.android,com.verizon.messaging.vzmsgs,com.viber.voip,com.whatsapp,com.zhiliaoapp.musically,jp.naver.line.android,org.telegram.messenger,tw.nekomimi.nekogram,org.telegram.BifToGram" "emojify_app_allowlist"
        db_edit com.google.android.inputmethod.latin#com.google.android.inputmethod.latin intVal 1 "enable_nga_language_download" "user_history_learning_strategies" "keyboard_redesign_subset_features_new_user_timestamp"
    fi

    if [ -z $(pm list packages -s com.google.android.inputmethod.latin) ] && [ -z "$(cat $pix/apps_temp.txt | grep gboard)" ]; then
        print "- GBoard is not installed as a system app !!"
        print "- Making Gboard a system app"
        echo " - Making Google Keyboard a system app" >>$logfile
        cp -r ~/$app/com.google.android.inputmethod.latin*/. $MODPATH/system/product/app/LatinIMEGooglePrebuilt
        mv $MODPATH/system/product/app/LatinIMEGooglePrebuilt/base.apk $MODPATH/system/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk
        rm -rf $MODPATH/system/product/app/LatinIMEGooglePrebuilt/oat
        #mv $MODPATH/files/privapp-permissions-com.google.android.inputmethod.latin.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.inputmethod.latin.xml
        echo "gboard" >>$pix/app2.txt
    elif [ ! -z "$(cat $pix/apps_temp.txt | grep gboard)" ]; then
        print "- GBoard is not installed as a system app !!"
        echo " - Making Google Keyboard as system app" >>$logfile
        print "- Making Gboard a system app"
        cp -r ~/$app/com.google.android.inputmethod.latin*/. $MODPATH/system/product/app/LatinIMEGooglePrebuilt
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

# Digital Wellbeing
$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.apps.wellbeing.device#com.google.android.apps.wellbeing'"
db_edit com.google.android.apps.wellbeing.device#com.google.android.apps.wellbeing boolVal 1 "ScreenTimeWidget__enable_pin_screen_time_widget_intent" "ScreenTimeWidget__enable_screen_time_widget"

# Google translate
$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.apps.translate'"
db_edit $gms com.google.android.apps.translate boolVal 1 "Widgets__enable_quick_actions_widget" "Widgets__enable_saved_history_widget"

# Google settings Services
$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.settings.intelligence'"
db_edit com.google.android.settings.intelligence boolVal 1 "RoutinesPrototype__enable_wifi_driven_bootstrap" "RoutinesPrototype__is_action_notifications_enabled" "RoutinesPrototype__is_activities_enabled" "RoutinesPrototype__is_module_enabled" "RoutinesPrototype__is_manual_location_rule_adding_enabled" "RoutinesPrototype__is_routine_inference_enabled" "BatteryWidget__is_widget_enabled" "BatteryWidget__is_enabled"

# Fix Precise Location
$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.platform.privacy'"
db_edit $gms com.google.android.platform.privacy boolVal 1 "location_accuracy_enabled" "permissions_hub_enabled" "privacy_dashboard_7_day_toggle"

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
    rm -rf $MODPATH/system$product/priv-app/SimpleDeviceConfig
fi

if [ $API -le 27 ]; then
    sed -i -e "s/bool_patch AdaptiveCharging__v1_enabled/#bool_patch AdaptiveCharging__v1_enabled/g" $MODPATH/service.sh
fi

# OOS 12 Fix
oos_fix

# Setting permisions
set_perm_recursive $MODPATH 0 0 0755 0644

for i in $MODPATH/system/vendor/overlay $MODPATH/system$product/overlay $MODPATH/system$product/priv-app/* $MODPATH/system$product/app/*; do
    set_perm_recursive $i 0 0 0755 0644
done

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

#Clean Up
rm -rf $MODPATH/files
rm -rf $MODPATH/spoof.prop
rm -rf $MODPATH/inc.prop

# create Uninstaller
[ -f $PIXELIFYUNS ] && rm -rf $PIXELIFYUNS
mkdir -p $PIXELIFYUNS
mv $MODPATH/module-uninstaller.prop $PIXELIFYUNS/module.prop
mv $MODPATH/service-uninstaller.sh $PIXELIFYUNS/service.sh
cp -f $MODPATH/deviceconfig.txt $PIXELIFYUNS/deviceconfig.txt
cp -r $MODPATH/addon $PIXELIFYUNS

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
