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
export GOOGLE_PREF=/data/data/com.google.android.googlequicksearchbox/shared_prefs/GEL.GSAPrefs.xml
export FIT=/data/data/com.google.android.apps.fitness/shared_prefs/growthkit_phenotype_prefs.xml

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

bool_patch_false() {
file=$2
line=$(grep $1 $2 | grep false | cut -c 14- | cut -d' ' -f1)
for i in $line; do
  val_false='value="true"'
  val_true='value="false"'
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
if [ ! $add == $str ]; then
sed -i -e "s/${str}/${add}/g" $file
fi
}

# Call Screening
bool_patch speak_easy $DIALER_PREF
bool_patch speakeasy $DIALER_PREF
bool_patch call_screen $DIALER_PREF
bool_patch revelio $DIALER_PREF
bool_patch record $DIALER_PREF
bool_patch atlas $DIALER_PREF
bool_patch transript $DIALER_PREF

# GBoard
bool_patch nga $GBOARD_PREF
bool_patch redesign $GBOARD_PREF
bool_patch lens $GBOARD_PREF
bool_patch generation $GBOARD_PREF
bool_patch multiword $GBOARD_PREF
bool_patch promo $GBOARD_PREF
bool_patch enable_email_provider_completion $GBOARD_PREF
bool_patch_false disable_multiword_autocompletion $GBOARD_PREF

# Google
string_patch flag.13477 redfin $GOOGLE_PREF
string_patch flag.14205 "*=nga_pop" $GOOGLE_PREF
chmod 0660 /data/data/com.google.android.googlequicksearchbox/shared_prefs

# GoogleFit
bool_patch DeviceStateFeature $FIT
bool_patch TestingFeature $FIT
bool_patch Sync__sync_after_promo_shown $FIT
bool_patch Sync__use_experiment_flag_from_promo $FIT
bool_patch Promotions $FIT

sleep 120

# DevicePersonalization
device_config put device_personalization_services AdaptiveAudio__enable_adaptive_audio true
device_config put device_personalization_services AdaptiveAudio__show_promo_notificatio true
device_config put device_personalization_services Autofill__enable true
device_config put device_personalization_services NotificationAssistant__enable_service true
device_config put device_personalization_services Captions__surface_sound_events true
device_config put device_personalization_services Captions__enable_augmented_music true

# AdaptiveCharging
device_config put adaptive_charging adaptive_charging_enabled true

# Permissions

#Dialer
pm grant com.google.android.dialer android.permission.ALLOW_ANY_CODEC_FOR_PLAYBACK
pm grant com.google.android.dialer android.permission.CAPTURE_AUDIO_OUTPUT
pm grant com.google.android.dialer android.permission.CAPTURE_VOICE_COMMUNICATION_OUTPUT
pm grant com.google.android.dialer android.permission.CONNECTIVITY_USE_RESTRICTED_NETWORKS
pm grant com.google.android.dialer android.permission.CONTROL_INCALL_EXPERIENCE
pm grant com.google.android.dialer android.permission.GET_ACCOUNTS_PRIVILEGED
pm grant com.google.android.dialer android.permission.INTERACT_ACROSS_USERS
pm grant com.google.android.dialer android.permission.MODIFY_AUDIO_ROUTING
pm grant com.google.android.dialer android.permission.MODIFY_PHONE_STATE
pm grant com.google.android.dialer android.permission.REGISTER_CONNECTION_MANAGER
pm grant com.google.android.dialer android.permission.STATUS_BAR
pm grant com.google.android.dialer android.permission.STOP_APP_SWITCHES
pm grant com.google.android.dialer android.permission.READ_PRECISE_PHONE_STATE
pm grant com.google.android.dialer android.permission.READ_PRIVILEGED_PHONE_STATE
pm grant com.google.android.dialer android.permission.WRITE_SECURE_SETTINGS
pm grant com.google.android.dialer com.android.voicemail.permission.READ_VOICEMAIL
pm grant com.google.android.dialer com.android.voicemail.permission.WRITE_VOICEMAIL
pm grant com.google.android.dialer com.google.android.dialer.permission.RECEIVE_RING_STATE

# DevicePersonalisationService
pm grant com.google.android.as android.permission.CAPTURE_AUDIO_HOTWORD
pm grant com.google.android.as android.permission.CAPTURE_AUDIO_OUTPUT
pm grant com.google.android.as android.permission.CAPTURE_MEDIA_OUTPUT
pm grant com.google.android.as android.permission.CAPTURE_VOICE_COMMUNICATION_OUTPUT
pm grant com.google.android.as android.permission.CONTROL_INCALL_EXPERIENCE
pm grant com.google.android.as android.permission.EXEMPT_FROM_AUDIO_RECORD_RESTRICTIONS
pm grant com.google.android.as android.permission.LOCATION_HARDWARE
pm grant com.google.android.as android.permission.MANAGE_SOUND_TRIGGER
pm grant com.google.android.as android.permission.MODIFY_AUDIO_ROUTING
pm grant com.google.android.as android.permission.MODIFY_PHONE_STATE
pm grant com.google.android.as android.permission.MONITOR_DEFAULT_SMS_PACKAGE
pm grant com.google.android.as android.permission.PACKAGE_USAGE_STATS
pm grant com.google.android.as android.permission.READ_OEM_UNLOCK_STATE
pm grant com.google.android.as android.permission.REQUEST_NOTIFICATION_ASSISTANT_SERVICE
pm grant com.google.android.as android.permission.START_ACTIVITIES_FROM_BACKGROUND
pm grant com.google.android.as android.permission.SUBSTITUTE_NOTIFICATION_APP_NAME
pm grant com.google.android.as android.permission.UPDATE_DEVICE_STATS
pm grant com.google.android.as android.permission.WRITE_SECURE_SETTINGS

