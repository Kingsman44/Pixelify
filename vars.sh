#!/system/bin/sh

# Riru Vars
MAGISKTMP="$(magisk --path)"
RIRU_MODULE_LIB_NAME="pixelify"
RIRU_MODULE_ID_PRE24="%%%RIRU_MODULE_ID_PRE24%%%"

# Variables for customize.sh
RIRU_API=0
RIRU_MIN_COMPATIBLE_API=0
RIRU_VERSION_CODE=0
RIRU_VERSION_NAME=""

# Used by /data/adb/riru/util_functions.sh
RIRU_MODULE_API_VERSION=25
RIRU_MODULE_MIN_API_VERSION=25
RIRU_MODULE_MIN_RIRU_VERSION_NAME="v25.4.2"

if [ "$MAGISK_VER_CODE" -ge 21000 ]; then
  MAGISK_CURRENT_RIRU_MODULE_PATH=$(magisk --path)/.magisk/modules/riru-core
else
  MAGISK_CURRENT_RIRU_MODULE_PATH=/sbin/.magisk/modules/riru-core
fi
# Riru vars end

# 1 - Normal, 2 - Zygisk, 3 - Riru
MODULE_TYPE=1
NEWAPI=$API
CURR="NONE"
REMOVE=""

# Versions
PCSVERSION=1
NEW_JN_PL=0
DPVERSIONP=1
LWVERSIONP=1.6
PLVERSIONP=1
NGAVERSIONP=1.2

# Default size
PCSSIZE="15 Mb"
NGASIZE="13.6 Mb"
LWSIZE="108 Mb"
PLSIZE="5 Mb"
OSRSIZE="172 Mb"

# Default variables
FIRST_ONLINE_TIME=0
FORCED_ONLINE=0
BETA_BUILD=1
DISABLE_GBOARD_GMS=0
DPAS=1
ENABLE_OSR=1
INS_PCS=0
MONET_BOOTANIMATION=0
NEW_PL=0
NOT_REQ_SOUND_PATCH=0
NO_VK=1
OSRVERSIONP=1
SEND_DPS=0
SHOW_GSS=1
TARGET_DEVICE_OP12=0
WALL_DID=0
WNEED=0
WREM=1
ZYGISK_P=0
PIXEL_SPOOF=0
TARGET_LOGGING=0

# Tensor
if [ "$(getprop ro.soc.model)" == "Tensor" ]; then
  TENSOR=1
  RIRU_LIB_PATH="$MODPATH/lib/riru_tensor"
  ZYGISK_LIB_PATH="$MODPATH/lib/zygisk_tensor"
else
  TENSOR=0
  RIRU_LIB_PATH="$MODPATH/lib/riru"
  ZYGISK_LIB_PATH="$MODPATH/lib/zygisk"
fi

# Default Locations
FIT=/data/data/com.google.android.apps.fitness/shared_prefs/growthkit_phenotype_prefs.xml
TURBO=/data/data/com.google.android.apps.turbo/shared_prefs/phenotypeFlags.xml
DIALER=com.google.android.dialer
GBOARD=/data/data/com.google.android.inputmethod.latin/shared_prefs/flag_value.xml
FORCE_FILE="/sdcard/Pixelify/apps.txt"
SPDB="/data/data/com.google.android.as/databases/superpacks.db"
DIALER_PREF=/data/data/com.google.android.dialer/shared_prefs/dialer_phenotype_flags.xml
GOOGLE_PREF=/data/data/com.google.android.googlequicksearchbox/shared_prefs/GEL.GSAPrefs.xml
gms=/data/data/com.google.android.gms/databases/phenotype.db
gser=/data/data/com.google.android.gsf/databases/gservices.db
gah=/data/data/com.google.android.gms/databases/google_account_history.db
pix=/data/pixelify
logfile=/sdcard/Pixelify/logs.txt

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

DIALERFLAGS="
atlas_show_preview_label
G__are_embeddings_jobs_enabled
G__config_caller_id_enabled
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
enable_stir_shaken
enable_video_handover_dialog
enable_android_s_notifications
G__speak_easy_use_soda_asr
G__enable_call_screen_data_in_call_log
G__enable_embedding_spam_revelio
G__enable_primes
G__enable_primes_crash_metric
G__enable_primes_timer_metric
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

font10='  <family name="google-sans-italics-bold">
    <font weight="700" style="normal">GoogleSans-Italic.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="18.0"/>
      <axis tag="wght" stylevalue="700"/>
    </font>
  </family>'

font11='  <family name="google-sans-italics-medium">
    <font weight="500" style="normal">GoogleSans-Italic.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="18.0"/>
      <axis tag="wght" stylevalue="500"/>
    </font>
  </family>'

font12='  <family name="google-sans-italics">
    <font weight="400" style="normal">GoogleSans-Italic.ttf
      <axis tag="GRAD" stylevalue="0"/>
      <axis tag="opsz" stylevalue="18.0"/>
      <axis tag="wght" stylevalue="400"/>
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

gfont1='    <family customizationType="new-named-family" name="google-sans-inter">
      <font weight="400" style="normal">GInterVF-Roman.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="18.0"/>
        <axis tag="wght" stylevalue="400"/>
      </font>
      <font weight="500" style="normal">GInterVF-Roman.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="18.0"/>
        <axis tag="wght" stylevalue="500"/>
      </font>
      <font weight="600" style="normal">GInterVF-Roman.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="18.0"/>
        <axis tag="wght" stylevalue="600"/>
      </font>
      <font weight="700" style="normal">GInterVF-Roman.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="18.0"/>
        <axis tag="wght" stylevalue="700"/>
      </font>
      <font weight="400" style="italic">GInterVF-Italic.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="18.0"/>
        <axis tag="wght" stylevalue="400"/>
      </font>
      <font weight="500" style="italic">GInterVF-Italic.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="18.0"/>
        <axis tag="wght" stylevalue="500"/>
      </font>
      <font weight="600" style="italic">GInterVF-Italic.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="18.0"/>
        <axis tag="wght" stylevalue="600"/>
      </font>
      <font weight="700" style="italic">GInterVF-Italic.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="18.0"/>
        <axis tag="wght" stylevalue="700"/>
      </font>
    </family>'

gfont2='    <family customizationType="new-named-family" name="google-sans-medium-inter">
      <font weight="500" style="normal">GInterVF-Roman.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="18.0"/>
        <axis tag="wght" stylevalue="500"/>
      </font>
    </family>'

gfont3='    <family customizationType="new-named-family" name="google-sans-bold-inter">
      <font weight="700" style="normal">GInterVF-Roman.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="18.0"/>
        <axis tag="wght" stylevalue="700"/>
      </font>
    </family>'

gfont4='    <family customizationType="new-named-family" name="google-sans-text-inter">
      <font weight="400" style="normal">GInterVF-Roman.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="17.0"/>
        <axis tag="wght" stylevalue="400"/>
      </font>
      <font weight="500" style="normal">GInterVF-Roman.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="17.0"/>
        <axis tag="wght" stylevalue="500"/>
      </font>
      <font weight="600" style="normal">GInterVF-Roman.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="17.0"/>
        <axis tag="wght" stylevalue="600"/>
      </font>
      <font weight="700" style="normal">GInterVF-Roman.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="17.0"/>
        <axis tag="wght" stylevalue="700"/>
      </font>
      <font weight="400" style="italic">GInterVF-Italic.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="17.0"/>
        <axis tag="wght" stylevalue="400"/>
      </font>
      <font weight="500" style="italic">GInterVF-Italic.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="17.0"/>
        <axis tag="wght" stylevalue="500"/>
      </font>
      <font weight="600" style="italic">GInterVF-Italic.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="17.0"/>
        <axis tag="wght" stylevalue="600"/>
      </font>
      <font weight="700" style="italic">GInterVF-Italic.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="17.0"/>
        <axis tag="wght" stylevalue="700"/>
      </font>
    </family>'

gfont5='    <family customizationType="new-named-family" name="google-sans-text-medium-inter">
      <font weight="500" style="normal">GInterVF-Roman.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="17.0"/>
        <axis tag="wght" stylevalue="500"/>
      </font>
    </family>'

gfont6='    <family customizationType="new-named-family" name="google-sans-text-bold-inter">
      <font weight="700" style="normal">GInterVF-Roman.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="17.0"/>
        <axis tag="wght" stylevalue="700"/>
      </font>
    </family>'

gfont7='    <family customizationType="new-named-family" name="google-sans-text-italic-inter">
      <font weight="400" style="italic">GInterVF-Italic.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="17.0"/>
        <axis tag="wght" stylevalue="400"/>
      </font>
    </family>'

gfont8='    <family customizationType="new-named-family" name="google-sans-text-medium-italic-inter">
      <font weight="500" style="italic">GInterVF-Italic.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="17.0"/>
        <axis tag="wght" stylevalue="500"/>
      </font>
    </family>'

gfont9='    <family customizationType="new-named-family" name="google-sans-text-bold-italic-inter">
      <font weight="700" style="italic">GInterVF-Italic.ttf
        <axis tag="GRAD" stylevalue="0"/>
        <axis tag="opsz" stylevalue="17.0"/>
        <axis tag="wght" stylevalue="700"/>
      </font>
    </family>'

var_menu="
=====================
Installation Menu
=====================
[-] Unused in Installation
[O] Enabled
[X] Disabled
=====================
FORCE_ENABLE_ONLINE [-]
DISABLE_INTERNAL_SPOOFING [-]
ENABLE_TENSOR_UNLIMITED [-]
ENABLE_PIXEL_SPOOFING [-]
TARGET_USES_PIXEL5_SPOOF [-]
TARGET_USES_PIXEL6_SPOOF [-]
ENABLE_DPS [-]
UPDATE_DPS [-]
BACKUP_DPS [-]
ENABLE_NOW_PLAYING [-]
ENABLE_DIALER_FEATURES [-]
ADD_CALL_SCREENING_FILES [-]
BACKUP_CALL_SCREENING_FILES [-]
ENABLE_NGA [-]
UPDATE_NGA_RES [-]
DOWNLOAD_NGA_RES [-]
BACKUP_NGA [-]
DOWNLOAD_OSR [-]
UPDATE_OSR [-]
BACKUP_OSR [-]
DOWN_WGA [-]
ENABLE_LIVE_WALLPAPERS [-]
DOWNLOAD_LIVE_WALLPAPERS [-]
BACKUP_LIVE_WALLPAPERS [-]
ENABLE_BOOTANIMATION [-]
ENABLE_PIXEL_LAUNCHER [-]
UPDATE_PIXEL_LAUNCHER [-]
BACKUP_PIXEL_LAUNCHER [-]
ENABLE_PCS [-]
UPDATE_PCS [-]
BACKUP_PCS [-]
ENABLE_GSI [-]
DISABLE_GBOARD_GMS_OVERRIDE [-]
ENABLE_EXTREME_BATTERY_SAVER [-]
========================
"