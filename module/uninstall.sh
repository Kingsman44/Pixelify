sqlite=/data/adb/modules/Pixelify/addon/sqlite3
gms=/data/user/0/com.google.android.gms/databases/phenotype.db

rm -rf /data/data/com.google.android.dialer/shared_prefs/dialer_phenotype_flags.xml
rm -rf /data/data/com.google.android.inputmethod.latin/shared_prefs/flag_value.xml
rm -rf /data/data/com.google.android.apps.fitness/shared_prefs/growthkit_phenotype_prefs.xml
rm -rf /data/data/com.google.android.googlequicksearchbox/shared_prefs/GEL.GSAPrefs.xml
rm -rf /data/data/com.google.android.apps.turbo/shared_prefs/phenotypeFlags.xml
rm -rf /data/pixelify

chmod 0755 /data/data/com.google.android.dialer/files/phenotype

$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer'"
$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.googlequicksearchbox'"
$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.inputmethod.latin#com.google.android.inputmethod.latin'"
$sqlite $gms "DELETE FROM FlagOverrides WHERE packageName='com.google.android.apps.recorder'"

[[ -e "/data/system/package_cache" ]] && rm -rf /data/system/package_cache/*
