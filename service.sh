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
export GOOGLE_PREF=/data/data/com.google.android.googlequicksearchbox/shared_prefs/GEL.GSAPrefs.xml
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
str1=$(grep $1 $3 | grep string | cut -c 14- | cut -d'>' -f1)
for i in $str1; do
str2=$(grep $i $3 | grep string | cut -c 14- | cut -d'<' -f1)
add="$i>$2"
if [ ! "$add" == "$str2" ]; then
sed -i -e "s/${str2}/${add}/g" $file
fi
done
}

long_patch() {
file=$3
lon=$(grep $1 $3 | grep long | cut -c 17- | cut -d'"' -f1)
for i in $lon; do
str=$(grep $i $3 | grep long | cut -c 17-  | cut -d'"' -f1-2)
str1=$(grep $i $3 | grep long | cut -c 17- | cut -d'"' -f1-3)
add="$str\"$2"
if [ ! "$add" == "$str1" ]; then
sed -i -e "s/${str1}/${add}/g" $file
fi
done
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
bool_patch voice_promo $GBOARD_PREF
bool_patch silk $GBOARD_PREF
bool_patch enable_email_provider_completion $GBOARD_PREF
bool_patch enable_multiword_predictions $GBOARD_PREF
bool_patch_false disable_multiword_autocompletion $GBOARD_PREF
bool_patch crank $GBOARD_PREF
bool_patch enable_inline_suggestions_on_decoder_side $GBOARD_PREF
bool_patch enable_core_typing_experience_indicator_on_composing_text $GBOARD_PREF
bool_patch enable_inline_suggestions_on_client_side $GBOARD_PREF
bool_patch enable_core_typing_experience_indicator_on_candidates $GBOARD_PREF
long_patch inline_suggestion_experiment_version 2 $GBOARD_PREF
long_patch user_history_learning_strategies 1 $GBOARD_PREF
long_patch crank_max_char_num_limit 100 $GBOARD_PREF
long_patch crank_min_char_num_limit 5 $GBOARD_PREF
long_patch keyboard_redesign 1 $GBOARD_PREF
bool_patch enable_inline_suggestions_space_tooltip $GBOARD_PREF
bool_patch fast_access_bar $GBOARD_PREF
bool_patch tiresias $GBOARD_PREF
bool_patch agsa $GBOARD_PREF
bool_patch enable_voice $GBOARD_PREF
bool_patch personalization $GBOARD_PREF
bool_patch lm $GBOARD_PREF
bool_patch feature_cards $GBOARD_PREF
string_patch crank_inline_suggestion_language_tags "ar,de,en,es,fr,hi-IN,hi-Latn,id,it,ja,ko,nl,pl,pt,ru,th,tr,zh-CN,zh-HK,zh-TW" $GBOARD_PREF
bool_patch_false force_key_shadows $GBOARD_PREF
#bool_patch pill $GBOARD_PREF (for rounded buttons)

#google
chmod 0551 /data/data/com.google.android.googlequicksearchbox/shared_prefs
name=$(grep current_account_name /data/data/com.android.vending/shared_prefs/account_shared_prefs.xml | cut -d">" -f2 | cut -d"<" -f1)
if [ ! -z $name ]; then
string_patch GSAPrefs.google_account $name $MODPATH/files/GEL.GSAPrefs.xml
fi
cp -Tf /data/adb/modules/Pixelify/GEL.GSAPrefs.xml $GOOGLE_PREF

# GoogleFit
bool_patch DeviceStateFeature $FIT
bool_patch TestingFeature $FIT
bool_patch Sync__sync_after_promo_shown $FIT
bool_patch Sync__use_experiment_flag_from_promo $FIT
bool_patch Promotions $FIT

# Turbo
bool_patch AdaptiveCharging__v1_enabled $TURBO

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

# Wellbeing
pm enable com.google.android.apps.wellbeing/com.google.android.apps.wellbeing.walkingdetection.ui.WalkingDetectionActivity
