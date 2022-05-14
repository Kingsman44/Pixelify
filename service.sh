#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in late_start service mode

export DIALER_PREF=/data/data/com.google.android.dialer/shared_prefs/dialer_phenotype_flags.xml
export GBOARD_PREF=/data/data/com.google.android.inputmethod.latin/shared_prefs/flag_value.xml
export FIT=/data/data/com.google.android.apps.fitness/shared_prefs/growthkit_phenotype_prefs.xml
export TURBO=/data/data/com.google.android.apps.turbo/shared_prefs/phenotypeFlags.xml
export GOOGLE_PREF=/data/data/com.google.android.googlequicksearchbox/shared_prefs/GEL.GSAPrefs.xml
sqlite=$MODDIR/addon/sqlite3
chmod 0755 $sqlite3
gms=/data/user/0/com.google.android.gms/databases/phenotype.db
SPDB="/data/data/com.google.android.as/databases/superpacks.db"

G_PERM="com.google.android.googlequicksearchbox.permission.FINISH_GEL_ACTIVITY
com.google.android.apps.now.CURRENT_ACCOUNT_ACCESS
com.google.android.googlequicksearchbox.permission.C2D_MESSAGE
com.google.android.c2dm.permission.RECEIVE
android.permission.GLOBAL_SEARCH
android.permission.READ_CONTACTS
android.permission.WRITE_CONTACTS
com.android.browser.permission.READ_HISTORY_BOOKMARKS
com.android.browser.permission.WRITE_HISTORY_BOOKMARKS
android.permission.ACCESS_NETWORK_STATE
android.permission.INTERNET
com.google.android.launcher.permission.CONTENT_REDIRECT
com.google.android.launcher.permission.READ_SETTINGS
com.google.android.launcher.permission.WRITE_SETTINGS
com.google.android.launcher.permission.RECEIVE_LAUNCH_BROADCASTS
com.google.android.launcher.permission.RECEIVE_FIRST_LOAD_BROADCAST
android.permission.USE_CREDENTIALS
android.permission.MANAGE_ACCOUNTS
android.permission.WRITE_SETTINGS
com.google.android.providers.settings.permission.READ_GSETTINGS
com.google.android.providers.settings.permission.WRITE_GSETTINGS
com.google.android.providers.gsf.permission.READ_GSERVICES
com.google.android.voicesearch.SHORTCUTS_ACCESS
com.google.android.voicesearch.ACCESS_SETTINGS
com.android.browser.permission.PRELOAD
com.google.android.ears.permission.WRITE
android.permission.BROADCAST_STICKY
android.permission.MEDIA_CONTENT_CONTROL
android.permission.INTERACT_ACROSS_USERS
android.permission.INTERACT_ACROSS_PROFILES
android.permission.FOREGROUND_SERVICE
com.google.android.googlequicksearchbox.permission.PAUSE_HOTWORD
android.permission.GET_PACKAGE_SIZE
android.permission.ACCESS_WIFI_STATE
android.permission.ACCESS_NOTIFICATION_POLICY
android.permission.CHANGE_WIFI_STATE
android.permission.BLUETOOTH_ADMIN
android.permission.CHANGE_NETWORK_STATE
android.permission.READ_EXTERNAL_STORAGE
android.permission.RECEIVE_BOOT_COMPLETED
android.permission.WAKE_LOCK
android.permission.ACTIVITY_RECOGNITION
com.google.android.gms.permission.ACTIVITY_RECOGNITION
android.permission.READ_PROFILE
com.google.googlenav.friend.permission.OPT_IN
com.google.android.apps.maps.permission.PREFETCH
com.google.android.apps.maps.permission.TIMELINE_POST_VISIT_BADGE
android.permission.ACCESS_COARSE_LOCATION
android.permission.ACCESS_FINE_LOCATION
android.permission.ACCESS_BACKGROUND_LOCATION
android.permission.BLUETOOTH
android.permission.CALL_PHONE
android.permission.CALL_PRIVILEGED
android.permission.GET_ACCOUNTS
android.permission.MODIFY_AUDIO_SETTINGS
android.permission.READ_CALENDAR
android.permission.READ_CALL_LOG
android.permission.READ_SMS
android.permission.READ_PHONE_STATE
android.permission.READ_SYNC_SETTINGS
android.permission.RECORD_AUDIO
android.permission.SEND_SMS
android.permission.VIBRATE
android.permission.GET_TASKS
android.permission.REAL_GET_TASKS
android.permission.WRITE_CALENDAR
android.permission.WRITE_EXTERNAL_STORAGE
android.permission.WRITE_SMS
com.android.alarm.permission.SET_ALARM
com.google.android.apps.googlevoice.permission.AUTO_SEND
com.google.android.gm.permission.AUTO_SEND
com.google.android.gm.permission.READ_GMAIL
com.google.android.googleapps.permission.GOOGLE_AUTH.cp
com.google.android.googleapps.permission.GOOGLE_AUTH
com.google.android.hangouts.START_HANGOUT
com.google.android.voicesearch.AUDIO_FILE_ACCESS
android.permission.CAMERA
android.permission.FLASHLIGHT
android.permission.DOWNLOAD_WITHOUT_NOTIFICATION
android.permission.MANAGE_VOICE_KEYPHRASES
android.permission.MANAGE_SOUND_TRIGGER
android.permission.SOUND_TRIGGER_RUN_IN_BATTERY_SAVER
com.android.chrome.PRERENDER_URL
android.permission.CAPTURE_AUDIO_HOTWORD
android.permission.MANAGE_HOTWORD_DETECTION
android.permission.STOP_APP_SWITCHES
android.permission.SET_WALLPAPER
android.permission.SET_WALLPAPER_HINTS
android.permission.BIND_APPWIDGET
com.android.launcher.permission.INSTALL_SHORTCUT
android.permission.USE_FINGERPRINT
android.permission.CHANGE_WIFI_MULTICAST_STATE
android.permission.SYSTEM_ALERT_WINDOW
android.permission.SET_MEDIA_KEY_LISTENER
android.permission.SET_VOLUME_KEY_LONG_PRESS_LISTENER
android.permission.MANAGE_USB
android.permission.USE_FULL_SCREEN_INTENT
android.permission.PACKAGE_USAGE_STATS
com.google.android.deskclock.permission.RECEIVE_ALERT_BROADCASTS
android.permission.MODIFY_AUDIO_ROUTING
android.permission.START_ACTIVITIES_FROM_BACKGROUND
com.google.android.apps.gsa.nga.engine.stash.BROADCAST
com.google.android.apps.gsa.nga.permissions.EDIT_PREFERENCES
android.permission.ANSWER_PHONE_CALLS
android.permission.NFC
com.google.android.finsky.permission.DSE
android.permission.EXPAND_STATUS_BAR
android.permission.QUERY_ALL_PACKAGES
android.permission.CONTROL_INCALL_EXPERIENCE
android.permission.ENTER_CAR_MODE_PRIORITIZED
android.permission.WRITE_APN_SETTINGS
com.android.chrome.permission.TRANSLATE
android.permission.SCHEDULE_EXACT_ALARM
android.permission.BLUETOOTH_CONNECT
android.permission.BLUETOOTH_SCAN
android.permission.SUBSTITUTE_SHARE_TARGET_APP_NAME_AND_ICON
com.google.android.gms.permission.AD_ID
com.google.android.apps.nest.DOCK_MANAGER_SERVICE"

SET_PERM="android.permission.ACCESS_NETWORK_STATE
android.permission.GET_PACKAGE_SIZE
android.permission.READ_SEARCH_INDEXABLES
android.permission.MODIFY_PHONE_STATE
android.permission.MANAGE_FINGERPRINT
android.permission.RECEIVE_BOOT_COMPLETED
com.google.android.providers.gsf.permission.READ_GSERVICES
android.permission.SCHEDULE_EXACT_ALARM
com.google.android.settings.fuelgauge.BATTERY_SETTING
android.permission.WRITE_SETTINGS_HOMEPAGE_DATA
android.permission.ACCESS_WIFI_STATE
android.permission.BLUETOOTH
android.permission.INTERNET
android.permission.ACCESS_BACKGROUND_LOCATION
android.permission.ACCESS_FINE_LOCATION
android.permission.ACCESS_NOTIFICATION_POLICY
android.permission.READ_PHONE_STATE
android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
Manifest.permission.RECEIVE_BOOT_COMPLETED
com.google.android.settings.routines.ROUTINES_ACTIONS
android.permission.READ_DEVICE_CONFIG
android.permission.WRITE_SECURE_SETTINGS
android.permission.START_ACTIVITIES_FROM_BACKGROUND"

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

temp=""

pm_enable() {
    pm enable $1 > /dev/null 2>&1
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
            str=$(grep $i $3 | grep long | cut -c 17-  | cut -d'"' -f1-2)
            str1=$(grep $i $3 | grep long | cut -c 17- | cut -d'"' -f1-3)
            add="$str\"$2"
            if [ ! "$add" == "$str1" ]; then
                log "Setting string $i to $2"
                sed -i -e "s/${str1}/${add}/g" $file
            fi
        done
    fi
}

mkdir -p /sdcard/Pixelify

log "Service Started"


# Call Screening
bool_patch speak_easy $DIALER_PREF
bool_patch speakeasy $DIALER_PREF
bool_patch call_screen $DIALER_PREF
bool_patch revelio $DIALER_PREF
bool_patch record $DIALER_PREF
bool_patch atlas $DIALER_PREF
bool_patch transript $DIALER_PREF
cp -Tf $MODDIR/com.google.android.dialer /data/data/com.google.android.dialer/files/phenotype/com.google.android.dialer

# GBoard
bool_patch nga $GBOARD_PREF
bool_patch redesign $GBOARD_PREF
bool_patch lens $GBOARD_PREF
bool_patch generation $GBOARD_PREF
bool_patch multiword $GBOARD_PREF
bool_patch voice_promo $GBOARD_PREF
bool_patch silk $GBOARD_PREF
bool_patch enable_email_provider_completion $GBOARD_PREF
bool_patch enable_multiword_predictions $GBOARD_PREF
bool_patch_false disable_multiword_autocompletion $GBOARD_PREF
bool_patch enable_inline_suggestions_on_decoder_side $GBOARD_PREF
bool_patch enable_core_typing_experience_indicator_on_composing_text $GBOARD_PREF
bool_patch enable_inline_suggestions_on_client_side $GBOARD_PREF
bool_patch enable_core_typing_experience_indicator_on_candidates $GBOARD_PREF
long_patch inline_suggestion_experiment_version 4 $GBOARD_PREF
long_patch user_history_learning_strategies 1 $GBOARD_PREF
long_patch crank_max_char_num_limit 100 $GBOARD_PREF
long_patch crank_min_char_num_limit 5 $GBOARD_PREF
long_patch keyboard_redesign 1 $GBOARD_PREF
bool_patch fast_access_bar $GBOARD_PREF
bool_patch tiresias $GBOARD_PREF
bool_patch agsa $GBOARD_PREF
bool_patch enable_voice $GBOARD_PREF
bool_patch personalization $GBOARD_PREF
bool_patch lm $GBOARD_PREF
bool_patch feature_cards $GBOARD_PREF
bool_patch dynamic_art $GBOARD_PREF
bool_patch multilingual $GBOARD_PREF
bool_patch show_suggestions_for_selected_text_while_dictating $GBOARD_PREF
#bool_patch enable_highlight_voice_reconversion_composing_text $GBOARD_PREF
#bool_patch enable_handling_concepts_for_contextual_bitmoji $GBOARD_PREF
bool_patch enable_preemptive_decode $GBOARD_PREF
bool_patch translate $GBOARD_PREF
bool_patch tflite $GBOARD_PREF
bool_patch enable_show_inline_suggestions_in_popup_view $GBOARD_PREF
bool_patch enable_nebulae_materializer_v2 $GBOARD_PREF
#bool_patch use_scrollable_candidate_for_voice $GBOARD_PREF
bool_patch_false force_key_shadows $GBOARD_PREF
bool_patch floating $GBOARD_PREF
bool_patch split $GBOARD_PREF
bool_patch grammar $GBOARD_PREF
bool_patch spell_checker $GBOARD_PREF
bool_patch deprecate_search $GBOARD_PREF
bool_patch hide_composing_underline $GBOARD_PREF
bool_patch emojify $GBOARD_PREF
string_patch enable_emojify_language_tags "en" $GBOARD_PREF
string_patch emojify_app_allowlist "com.android.mms,com.discord,com.facebook.katana,com.facebook.lite,com.facebook.orca,com.google.android.apps.dynamite,com.google.android.apps.messaging,com.google.android.youtube,com.instagram.android,com.snapchat.android,com.twitter.android,com.verizon.messaging.vzmsgs,com.viber.voip,com.whatsapp,com.zhiliaoapp.musically,jp.naver.line.android,org.telegram.messenger,tw.nekomimi.nekogram,org.telegram.BifToGram" $GBOARD_PREF
bool_patch enable_grammar_checker $GBOARD_PREF
long_patch grammar_checker_min_sentence_length 3 $GBOARD_PREF
string_patch grammar_checker_manifest_uri "https://www.gstatic.com/android/keyboard/spell_checker/experiment/memory_fix/metadata_cpu_2021102041.json" $GBOARD_PREF

# GoogleFit
bool_patch DeviceStateFeature $FIT
bool_patch TestingFeature $FIT
bool_patch Sync__sync_after_promo_shown $FIT
bool_patch Sync__use_experiment_flag_from_promo $FIT
bool_patch Promotions $FIT
bool_patch googler $FIT
bool_patch dasher $FIT

# Turbo
bool_patch AdaptiveCharging__v1_enabled $TURBO

# Wellbeing
pm_enable com.google.android.apps.wellbeing/com.google.android.apps.wellbeing.walkingdetection.ui.WalkingDetectionActivity

while true; do
    boot=$(getprop sys.boot_completed)
    if [ "$boot" -eq 1 ]; then
        sleep 5
        break
    fi
done

# if [ -f $SPDB ]; then
#     $sqlite $SPDB "UPDATE pending_downloads SET requires_unmetered_network='0' WHERE superpack_name='spelling_correction'"
#     $sqlite $SPDB "UPDATE pending_downloads SET requires_idle='0' WHERE superpack_name='spelling_correction'"
# fi

if [ $(grep CallScreen $MODDIR/config.prop | cut -d'=' -f2) -eq 1 ]; then
    mkdir -p /data/data/com.google.android.dialer/files/phenotype
    cp -Tf $MODDIR/com.google.android.dialer /data/data/com.google.android.dialer/files/phenotype/com.google.android.dialer
    chmod 500 /data/data/com.google.android.dialer/files/phenotype
    am force-stop com.google.android.dialer
fi

if [ $(grep Live $MODDIR/config.prop | cut -d'=' -f2) -eq 1 ]; then
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

if [ -f $MODDIR/grant ]; then
    for i in $ASI_OS_PERM; do
        pm grant com.google.android.as.oss $i
    done
    for i in $ASI_PERM; do
        pm grant com.google.android.as $i
    done
    for i in $SET_PERM; do
        pm grant com.google.android.settings.intelligence $i
    done
    sed -i -e "s/gsm.sim.operator.iso-country/#gsm.sim.operator.iso-country/g" $MODDIR/system.prop
    am force-stop com.google.android.as
    rm -rf $MODDIR/grant
fi

for i in $G_PERM; do
    pm grant com.google.android.googlequicksearchbox $i
done

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

log "Service Finished"
echo "$temp" >> /sdcard/Pixelify/logs.txt
