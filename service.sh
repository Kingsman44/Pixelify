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
export TURBO=/data/data/com.google.android.apps.turbo/shared_prefs/phenotypeFlags.xml

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
bool_patch lens $GBOARD
bool_patch generation $GBOARD
bool_patch multiword $GBOARD
bool_patch core_typing $GBOARD

# Google
if [ -f $GOOGLE_PREF ]; then
string_patch flag.13477 redfin $GOOGLE_PREF
string_patch flag.14205 "*=nga_pop" $GOOGLE_PREF
chmod 0660 /data/data/com.google.android.googlequicksearchbox/shared_prefs
fi

# GoogleFit
bool_patch DeviceStateFeature $FIT
bool_patch TestingFeature $FIT
bool_patch Sync__sync_after_promo_shown $FIT
bool_patch Sync__use_experiment_flag_from_promo $FIT
bool_patch Promotions $FIT

bool_patch AdaptiveCharging__v1_enabled $TURBO
bool_patch AdaptiveBattery $TURBO

# DevicePersonalization
device_config put device_personalization_services AdaptiveAudio__enable_adaptive_audio true
device_config put device_personalization_services AdaptiveAudio__show_promo_notificatio true
device_config put device_personalization_services Autofill__enable true
device_config put device_personalization_services NotificationAssistant__enable_service true
device_config put device_personalization_services Captions__surface_sound_events true
device_config put device_personalization_services Captions__enable_augmented_music true
device_config put device_personalization_services Captions__enable_caption_call true

# AdaptiveCharging
device_config put adaptive_charging adaptive_charging_enabled true