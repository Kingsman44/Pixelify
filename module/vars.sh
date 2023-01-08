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
# Riru vars end

# 1 - Normal, 2 - Zygisk, 3 - Riru
MODULE_TYPE=1
CURR="NONE"
REMOVE=""

if [ -z $API ]; then
  API=$(getprop ro.build.version.sdk)
fi

# Versions
PCSVERSION=1
NEW_JN_PL=0
DPVERSIONP=1
LWVERSIONP=1.8
PLVERSIONP=1
NGAVERSIONP=1.3

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
TARGET_DEVICE_ONEUI=0
TARGET_DEVICE_OP12=0
WALL_DID=0
WNEED=0
WREM=1
ZYGISK_P=0
PIXEL_SPOOF=0
TARGET_LOGGING=0
LOS_FIX=0
REQ_FIX=0
NEW_D_PL=0

# Tensor
if [[ "$(getprop ro.soc.model)" == "Tensor" || "$(getprop ro.soc.model)" == "GS201" ]]; then
  TENSOR=1
  RIRU_LIB_PATH="$MODPATH/lib/riru_tensor"
  ZYGISK_LIB_PATH="$MODPATH/lib/zygisk_tensor"
else
  TENSOR=0
  RIRU_LIB_PATH="$MODPATH/lib/riru"
  ZYGISK_LIB_PATH="$MODPATH/lib/zygisk"
fi

# Default Locations
if [ -d /data/data/com.google.android.gms ]; then
DE_DATA=/data/data
else
DE_DATA=/data/user/0
fi

PIXELIFYUNS=/data/adb/modules/PixelifyUninstaller
FIT=$DE_DATA/com.google.android.apps.fitness/shared_prefs/growthkit_phenotype_prefs.xml
TURBO=$DE_DATA/com.google.android.apps.turbo/shared_prefs/phenotypeFlags.xml
DIALER=com.google.android.dialer
GBOARD=$DE_DATA/com.google.android.inputmethod.latin/shared_prefs/flag_value.xml
PL_PREF=$DE_DATA/com.google.android.apps.nexuslauncher/shared_prefs/com.android.launcher3.prefs.xml
NEW_GBOARD=$DE_DATA/com.google.android.inputmethod.latin/shared_prefs/flag_override.xml
FORCE_FILE="/sdcard/Pixelify/apps.txt"
SPDB="$DE_DATA/com.google.android.as/databases/superpacks.db"
DIALER_PREF=$DE_DATA/com.google.android.dialer/shared_prefs/dialer_phenotype_flags.xml
GOOGLE_PREF=$DE_DATA/com.google.android.googlequicksearchbox/shared_prefs/GEL.GSAPrefs.xml
gms=$DE_DATA/com.google.android.gms/databases/phenotype.db
gser=$DE_DATA/com.google.android.gsf/databases/gservices.db
gah=$DE_DATA/com.google.android.gms/databases/google_account_history.db
pix=/data/pixelify
logfile=/sdcard/Pixelify/logs.txt
PHOTOS_PREF=$DE_DATA/com.google.android.apps.photos/shared_prefs/com.google.android.apps.photos.phenotype.xml

if [ $API -le 28 ]; then
    product=
else
    product=/product
fi

# Patching flags 
ASI_FLAGS="AmbientContext__enable
AmbientContext__enable_quick_tap
Captions__enable_augmented_modality
Captions__enable_augmented_modality_input
Captions__text_transform_augmented_input
Cell__enable_search_events
Cell__enable_smartspace_events
EchoSearch__enable_dota
EchoSearch__enable_dota_asset
EchoSearch__enable_horizontal_people_shortcuts
EchoSearch__enable_packer_fallback_targets_parallel_run
EchoSearch__enable_pnb
EchoSearch__enable_search_fa_logging
EchoSearch__enable_shortcut_filter
EchoSmartspace__check_notification_visibility
EchoSmartspace__enable_add_internal_feedback_button
EchoSmartspace__enable_flight_landing_smartspace_aiai
EchoSmartspace__enable_hotel_smartspace_aiai
EchoSmartspace__enable_media_recs_for_driving
EchoSmartspace__enable_predictor_expiration
EchoSmartspace__runtastic_check_pause_action
EchoSmartspace__runtastic_is_ongoing_default_true
EchoSmartspace__smartspace_enable_daily_forecast
EchoSmartspace__smartspace_enable_timely_reminder
EchoSmartspace__strava_check_stop_action
Echo__avatar_enable_feature
Echo__enable_headphones_suggestions_from_agsa
Echo__enable_people_module
Echo__enable_widget_recommendations
Echo__search_enable_all_fallback_results
Echo__search_enable_allowlist
Echo__search_enable_app_fetcher_v2
Echo__search_enable_app_search_tips
Echo__search_enable_app_usage_stats_ranking
Echo__search_enable_application_header_type
Echo__search_enable_apps
Echo__search_enable_appsearch_tips_ranking_improvement
Echo__search_enable_assistant_quick_phrases_settings
Echo__search_enable_bc_smartspace_settings
Echo__search_enable_bc_translate_settings
Echo__search_enable_eventstore
Echo__search_enable_everything_else_above_web
Echo__search_enable_fetcher_optimization_using_result_types
Echo__search_enable_filter_pending_jobs
Echo__search_enable_mdp_play_results
Echo__search_enable_play
Echo__search_enable_play_alleyoop
Echo__search_enable_scraping
Echo__search_enable_search_in_app_icon
Echo__search_enable_settings_corpus
Echo__search_enable_shortcuts
Echo__search_enable_superpacks_app_terms
Echo__search_enable_superpacks_play_results
Echo__search_enable_top_hit_row
Echo__search_enable_widget_corpus
Echo__search_play_enable_spell_correction
Echo__smartspace_dedupe_fast_pair_notification
Echo__smartspace_enable_async_icon
Echo__smartspace_enable_battery_notification_parser
Echo__smartspace_enable_bedtime_active_predictor
Echo__smartspace_enable_bedtime_reminder_predictor
Echo__smartspace_enable_bluetooth_metadata_parser
Echo__smartspace_enable_cross_device_timer
Echo__smartspace_enable_dark_launch_outlook_events
Echo__smartspace_enable_doorbell
Echo__smartspace_enable_doorbell_context_wrapper
Echo__smartspace_enable_doorbell_extras
Echo__smartspace_enable_dwb_bedtime_predictor
Echo__smartspace_enable_earthquake_alert_predictor
Echo__smartspace_enable_echo_settings
Echo__smartspace_enable_echo_unified_settings
Echo__smartspace_enable_eta_doordash
Echo__smartspace_enable_eta_lyft
Echo__smartspace_enable_food_delivery_eta
Echo__smartspace_enable_grocery
Echo__smartspace_enable_media_wake_lock_acquire
Echo__smartspace_enable_nap
Echo__smartspace_enable_nudge
Echo__smartspace_enable_outlook_events
Echo__smartspace_enable_package_delivery
Echo__smartspace_enable_paired_device_connections
Echo__smartspace_enable_paired_device_predictor
Echo__smartspace_enable_ridesharing_eta
Echo__smartspace_enable_safety_check_predictor
Echo__smartspace_enable_score_ranker
Echo__smartspace_enable_sensitive_notification_twiddler
Echo__smartspace_enable_step_predictor
Echo__smartspace_enable_subcard_logging
Echo__smartspace_gaia_twiddler
Echo__smartspace_show_cross_device_timer_label
Echo__smartspace_use_flashlight_action_chip
Echo_search__enable_dota
Echo_smartspace__enable_flight_landing_smartspace_aiai
Echo_smartspace__enable_hotel_smartspace_aiai
Echo_smartspace__smartspace_enable_daily_forecast
Echo_smartspace__smartspace_enable_timely_reminder
FederatedAssistant__enable_speech_personalization_caching
FederatedAssistant__enable_speech_personalization_inference
FederatedAssistant__enable_speech_personalization_training
Hopper__enable_active_notification_tracker
Hopper__enable_auto_expiration
Hopper__enable_connector
Hopper__enable_conversation_blocklist
Hopper__enable_observer
Hopper__enable_priority_suggestions
Hopper__enable_smart_action
Hopper__enable_smart_reply
Hopper__enable_text_predictor
Hopper__enable_time_based_expiration
NowPlaying__youtube_export_enabled
Notification__enable_journey_feature_vectors	
Notification__enable_mdd_playsnapshot	
Notification__enable_notification_collection	
Notification__enable_notification_journey
Overview__enable_lens_r_overview_long_press
Overview__enable_lens_r_overview_select_mode
Overview__enable_lens_r_overview_translate_action
People__enable_call_log_signals
People__enable_contacts
People__enable_dictation_client
People__enable_hybrid_hotseat_client
People__enable_notification_common
People__enable_notification_signals
People__enable_package_tracker
People__enable_people_pecan
People__enable_people_search_content
People__enable_priority_suggestion_client
People__enable_profile_signals
People__enable_sharesheet_client
People__enable_sms_signals
QuickTapMdd__enable_quick_tap
QuickTap__enable_quick_tap
Screenshot__can_use_gms_core_to_save_boarding_pass
Screenshot__can_use_gpay_to_save_boarding_pass
Screenshot__enable_add_to_wallet_title
Screenshot__enable_covid_card_action
Screenshot__enable_lens_screenshots_search_action
Screenshot__enable_lens_screenshots_similar_styles_action
Screenshot__enable_lens_screenshots_translate_action
Screenshot__enable_quick_share_smart_action
Screenshot__enable_screenshot_notification_smart_actions
SmartDictation__enable_alternatives_from_past_corrections
SmartDictation__enable_alternatives_from_speech_hypotheses
SmartDictation__enable_biasing_for_commands
SmartDictation__enable_biasing_for_contacts
SmartDictation__enable_biasing_for_contacts_learned_from_past_corrections
SmartDictation__enable_biasing_for_interests_model
SmartDictation__enable_biasing_for_past_correction
SmartDictation__enable_biasing_for_screen_context
SmartDictation__enable_selection_filtering
SmartRecCompose__enable_aiai_tc_generator
SmartRecCompose__enable_compose_action_filter
SmartRecCompose__enable_compose_tc
SmartRecCompose__enable_deep_clu_model
SmartRecOverviewChips__enable_action_boost_generator
SmartRecOverviewChips__enable_matchmaker_generator
SmartRecOverviewChips__enable_reflection_generator
SmartRecOverviewChips__enable_settings_card_generator
SmartRecOverviewChips__enable_smartrec_for_overview_chips
SmartRecPixelSearch__enable_aiai_tc_generator
SmartRecPixelSearch__enable_all_fallbacks
SmartRecPixelSearch__enable_appaction_generator
SmartRecPixelSearch__enable_assistant_geller_data_index
SmartRecPixelSearch__enable_assistant_generator
SmartRecPixelSearch__enable_assistant_personalized_deeplinks
SmartRecPixelSearch__enable_assistant_vertical_generator
SmartRecPixelSearch__enable_chrometab_generator
SmartRecPixelSearch__enable_corpora_via_search_context
SmartRecPixelSearch__enable_entity_annotation_generator
SmartRecPixelSearch__enable_entity_based_action_generation
SmartRecPixelSearch__enable_gboard_suggestion
SmartRecPixelSearch__enable_nasa_for_search
SmartRecPixelSearch__enable_navigational_sites_generator
SmartRecPixelSearch__enable_screenshot_generator
SmartRecPixelSearch__enable_screenshot_thumbnail_cache
SmartRecPixelSearch__enable_search_on_contacts
SmartRecPixelSearch__enable_spelling_correction
SmartRecQuickSearchBox__enable_action_boost_generator
SmartSelect__enable_smart_select_paste_package_signal
SmartSelect__enable_smart_select_training_manager_populations
SpeechPack__speech_recognition_service_settings_enabled
Translate__translation_service_enabled"

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
G__speak_easy_use_soda_asr
G__enable_call_screen_data_in_call_log
G__enable_embedding_spam_revelio
G__show_call_screen_recording_player_in_call_log
G__enable_default_dialer
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
G__new_voicemail_fragment_enabled
G__call_screen_audio_listener_enabled
enable_sigil
Xatu__xatu_enable_show_ahead
enable_tincan
enable_stir_shaken
enable_time_keeper_active_download
G__enable_patronus_spam"

GBOARD_FLAGS="crank_trigger_decoder_inline_completion_first
crank_trigger_decoder_inline_prediction_first
emojify_enable_fallback_pattern
enable_core_typing_experience_indicator_on_candidates
enable_core_typing_experience_indicator_on_composing_text
enable_downloadable_spell_checker_model
enable_email_provider_completion
enable_emoji_predictor_tflite_engine
enable_emoji_to_expression
enable_emoji_to_expression_tappable_ui
enable_emojify
enable_emojify_settings_option
enable_expression_candidate_precaching_for_bitmoji
enable_expression_content_cache
enable_expression_moment_push_up_animation
enable_expressive_concept_model
enable_feature_split_brella
enable_floating_keyboard_v2
enable_grammar_checker
enable_grammar_checker_on_webview
enable_handle_bitmoji_for_expression_candidates
enable_handle_emoticon_for_expression_candidates
enable_handle_expression_moment_standard_emoji_kitchen
enable_inline_suggestions_on_client_side
enable_inline_suggestions_on_decoder_side
enable_inline_suggestions_space_tooltip
enable_inline_suggestions_tooltip_v2
enable_matched_predictions_as_inline_from_crank_cifg
enable_multiword_predictions_as_inline_from_crank_cifg
enable_multiword_predictions_from_user_history
enable_multiword_suggestions_as_inline_from_crank_cifg
enable_nav_redesign
enable_nga
enable_nga_ime_api
enable_nga_language_picker_on_monolang_keyboard
enable_nga_punctuation_correction
enable_ondevice_voice
enable_single_word_predictions_as_inline_from_crank_cifg
enable_stylus_widget
enable_text_to_one_tap_expressions
enable_trigger_spell_check_in_composing
enable_trigger_spell_check_in_sentence
enable_twiddler_multiword_engine
enable_user_history_predictions_as_inline_from_crank_cifg
enable_voice_ellipsis
hide_composing_underline
nga_enable_mic_button_when_dictation_eligible
nga_enable_mic_onboarding_animation
nga_enable_spoken_emoji_sticky_variant
nga_enable_sticky_mic
nga_enable_undo_delete
notify_emoji_candidate_availability
offline_translate
show_contextual_emoji_kitchen_in_expression_moment
show_suggestions_for_selected_text_while_dictating
translate_new_ui"

GSS_FLAGS="BatteryHi__is_enabled
BatteryUsage__is_enabled
BatteryWidget__is_widget_enabled
BatteryWidget__is_enabled
RoutinesPrototype__enable_wifi_driven_bootstrap
RoutinesPrototype__is_action_notifications_enabled
RoutinesPrototype__is_activities_enabled
RoutinesPrototype__is_module_enabled
RoutinesPrototype__is_manual_location_rule_adding_enabled
RoutinesPrototype__is_routine_inference_enabled
RoutinesPrototype__is_slices_enabled"

S_HUB_FLAGS="45351680
45351680
45353325
45353325
45354067
45354067
45354137
45354137
45354219
45354219
45354289
45354289
45354290
45354290
45354291
45354291
45354292
45354292
45355361
45355361
45356900
45356900
45356902
45356902
45357909
45357909
45359057
45359057
45359104
45359104
45359152
45359152
45359153
45359153
45359172
45359172
45359404
45359404
45359407
45359407
45362747
45362747
45351680
45353325
45354067
45354137
45354219
45354289
45354290
45354291
45354292
45355361
45356900
45356902
45357909
45359057
45359104
45359152
45359153
45359172
45359404
45359407
45362747
45351680
45353325
45354067
45354137
45354219
45354289
45354290
45354291
45354292
45355361
45356900
45356902
45357909
45359057
45359104
45359152
45359153
45359172
45359404
45359407
45362747"

overide_spoof=""
spoof_message=""

if [ $API -eq 32 ]; then
  overide_spoof="org.pixelexperience.device
org.evolution.device
ro.bliss.device
ro.cherish.device
ro.lighthouse.device
ro.ssos.device
ro.spark.device
ro.potato.device"
elif [ $API -eq 33 ]; then
  overide_spoof="org.pixelexperience.device
ro.bliss.device
ro.cherish.device
ro.lighthouse.device
ro.ssos.device
ro.spark.device
org.voidui.device
ro.derp.device
ro.aosap.device"
fi

device_spoof=""
pixel_spoof=""
if [ $API -ge 32 ]; then
  device_spoof="ro.xtended.version
ro.crdroid.build.version
ro.catalyst.version
ro.rice.version
ro.voltage.version
org.evolution.device"

  pixel_spoof="org.eternityos.version
org.lessaospos.version
org.elixir.version
org.blaze.version
ro.conquer.version
org.eternityos.version
org.yapp.version
ro.bootleggers.version"
fi

exact_prop=""

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
ENABLE_PHOTOS_UNLIMITED [-]
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
ENABLE_GSI [-]
DISABLE_GBOARD_GMS_OVERRIDE [-]
ENABLE_EXTREME_BATTERY_SAVER [-]
========================
"
