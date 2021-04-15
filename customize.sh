NGAVERSION=1
LWVERSION=1
NGASIZE="135mb"
LWSIZE="81mb"

chmod -R 0755 $MODPATH/addon
chmod 0644 $MODPATH/files/*.xz
alias keycheck="$MODPATH/addon/keycheck"

mkdir $MODPATH/system/product/priv-app
mkdir $MODPATH/system/product/app

if [ $API -ge 30 ]; then
app=/data/app/*
else
app=/data/app
fi

print() {
ui_print "$@"
sleep 0.3
}

ui_print ""
print "- Detected Arch: $ARCH"
print "- Detected SDK : $API"
RAM=$( grep MemTotal /proc/meminfo | tr -dc '0-9')
print "- Detected Ram: $RAM"
ui_print ""
if [ $RAM -le "6291456" ]; then
rm -rf $MODPATH/system/product/etc/sysconfig/GoogleCamera_6gb_or_more_ram.xml
fi

if [ $ARCH != "arm64" ]; then
 abort "  Only support arm64 devices"
fi

DIALER1=$(find /system -name *Dialer.apk)

GOOGLE=$(find /system -name Velvet.apk)

if [ $API -eq "30" ]; then
if [ ! -z $(find /system -name DevicePerson*.apk) ] && [ ! -z $(find /system -name DevicePerson*.apk) ]; then
DP1=$(find /system -name DevicePerson*.apk)
DP2=$(find /system -name Matchmaker*.apk)
BDP="$DP1 $DP2"
elif [ -z  $(find /system -name DevicePerson*.apk) ]; then
DP=$(find /system -name Matchmaker*.apk)
else
DP=$(find /system -name DevicePerson*.apk)
fi
REMOVE="$DP"
fi

TUR=$(find /system -name Turbo*.apk)
REMOVE="$REMOVE $TUR"

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
sed -i -e "s/${str}/${add}/g" $file
}

keytest() {
  ui_print "- Vol Key Test"
  ui_print "    Press a Vol Key:"
  if (timeout 3 /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events); then
    return 0
  else
    ui_print "   Try again:"
    timeout 3 keycheck
    local SEL=$?
    [ $SEL -eq 143 ] && abort "   Vol key not detected!" || return 1
  fi
}

chooseport() {
  # Original idea by chainfire @xda-developers, improved on by ianmacd @xda-developers
  #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
  while true; do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events
    if (`cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
      break
    fi
  done
  if (`cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
    return 0
  else
    return 1
  fi
}

chooseportold() {
  # Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
  # Calling it first time detects previous input. Calling it second time will do what we want
  while true; do
    keycheck
    keycheck
    local SEL=$?
    if [ "$1" == "UP" ]; then
      UP=$SEL
      break
    elif [ "$1" == "DOWN" ]; then
      DOWN=$SEL
      break
    elif [ $SEL -eq $UP ]; then
      return 0
    elif [ $SEL -eq $DOWN ]; then
      return 1
    fi
  done
}

# Have user option to skip vol keys
OIFS=$IFS; IFS=\|; MID=false; NEW=false
case $(echo $(basename $ZIPFILE) | tr '[:upper:]' '[:lower:]') in
  *novk*) ui_print "- Skipping Vol Keys -";;
  *) if keytest; then
       VKSEL=chooseport
     else
       VKSEL=chooseportold
       ui_print "  ! Legacy device detected! Using old keycheck method"
       ui_print " "
       ui_print "- Vol Key Programming -"
       ui_print "  Press Vol Up Again:"
       $VKSEL "UP"
       ui_print "  Press Vol Down"
       $VKSEL "DOWN"
     fi;;
esac
IFS=$OIFS

DIALER=com.google.android.dialer
ui_print ""
print "- Installing Pixelify Module"
print "- Extracting Files...."
tar -xf $MODPATH/files/tur.tar.xz -C $MODPATH/system/product/priv-app
ui_print ""

DIALER_PREF=/data/data/com.google.android.dialer/shared_prefs/dialer_phenotype_flags.xml
print "- Installing Call Screening"
if [ -d /data/data/$DIALER ]; then
  ui_print ""
  print "- Google Dialer Already installed"
  print ""
  print " Call Screening other than US needs GoogleDialer version less 41"
  ui_print ""
  print "  Do you want to install GoogleDialer 40.0.275948326??"
  print "    Vol Up += Yes"
  print "    Vol Down += No"
  if $VKSEL; then
    if [ -d $app/$DIALER* ]; then
       pm uninstall $DIALER
    fi
    ui_print ""
    if [ -z $(grep "4674516" $DIALER_PREF) ]; then
    pm clear $DIALER
    fi
    print "- Installing GoogleDialer"
    ui_print ""
    tar -xf $MODPATH/files/gd.tar.xz -C $MODPATH/system/product/priv-app
    mv $MODPATH/system/product/priv-app/GoogleDialer $MODPATH/system/product/priv-app/Googledialer
    REMOVE="$REMOVE $DIALER1"
  else
    rm -rf $MODPATH/system/product/priv-app/Googledialer
    print ""
    print "- Enabling Call Screening"
    bool_patch atlas $DIALER_PREF
    bool_patch speak_easy $DIALER_PREF
    bool_patch speakeasy $DIALER_PREF
    bool_patch call_screen $DIALER_PREF
    bool_patch revelio $DIALER_PREF
    bool_patch record $DIALER_PREF
    bool_patch transcript $DIALER_PREF
  fi
else
  print "- Extracting GoogleDialer"
  tar -xf $MODPATH/files/gd.tar.xz -C $MODPATH/system/product/priv-app
  mv $MODPATH/system/product/priv-app/GoogleDialer $MODPATH/system/product/priv-app/Googledialer
  REMOVE="$REMOVE $DIALER1"
fi
ui_print "- Note -"
print "  Please Don't Update GoogleDialer (Other than US region),"
print "  It will remove Call Screening."
ui_print ""
print "  To get it back.."
print "  Just unistall update and reboot your phone !!"
ui_print "- Note End  -"
ui_print ""

GOOGLE_PREF=/data/data/com.google.android.googlequicksearchbox/shared_prefs/GEL.GSAPrefs.xml
if [ -d /data/data/com.google.android.googlequicksearchbox ]; then
print "  Google is installed."
print "  Do you want to installed Next generation assistant?"
print "  - and you need to select yes for spoof in below step."
print "   Vol Up += Yes"
print "   Vol Down += No"
ui_print ""
if $VKSEL; then
if [ -f /sdcard/Pixelify/backup/NgaResources.apk  ]; then
if $VKSEL; then
if [ ! $(cat /sdcard/Pixelify/version/nga.txt) -eq $NGAVERSION ]; then
ui_print ""
print "  (Interned Needed)"
print "  New version Detected."
print "  Do you Want to update or use Old Backup?"
print "  Version: $NGAVERSION"
print "  Size: $NGASIZE"
print "   Vol Up += Yes"
print "   Vol Down += No"
ui_print ""
if $VKSEL; then
rm -rf /sdcard/Pixelify/backup/NgaResources.apk
rm -rf /sdcard/Pixelify/version/nga.txt
mkdir $MODPATH/system/product/app/NgaResources
cd $MODPATH/system/product/app/NgaResources
curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/NgaResources.apk -O &> /proc/self/fd/$OUTFD
cd /
print "- Creating Backup"
print ""
cp -f $MODPATH/system/product/app/NgaResources/NgaResources.apk /sdcard/Pixelify/backup/NgaResources.apk
echo "$NGAVERSION" >> /sdcard/Pixelify/version/nga.txt
fi
fi
print "- Installing NgaResources from backups"
mkdir $MODPATH/system/product/app/NgaResources
cp -f /sdcard/Pixelify/backup/NgaResources.apk $MODPATH/system/product/app/NgaResources/NgaResources.apk
else
print "  (Interned Needed)"
print "  Do you want to install and Download NGA Resources"
print "  Size: $NGASIZE"
print "   Vol Up += Yes"
print "   Vol Down += No"
ui_print ""
if $VKSEL; then
print "  Downloading NGA Resources"
mkdir $MODPATH/system/product/app/NgaResources
cd $MODPATH/system/product/app/NgaResources
curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/NgaResources.apk -O &> /proc/self/fd/$OUTFD
cd /
ui_print ""
print "  Do you want to create backup of NGA Resources"
print "  so that you don't need redownload it everytime."
print "   Vol Up += Yes"
print "   Vol Down += No"
if $VKSEL; then
print "- Creating Backup"
mkdir /sdcard/Pixelify
mkdir /sdcard/Pixelify/backup
rm -rf /sdcard/Pixelify/backup/NgaResources.apk
cp -f $MODPATH/system/product/app/NgaResources/NgaResources.apk /sdcard/Pixelify/backup/NgaResources.apk
mkdir /sdcard/Pixelify/version
echo "$NGAVERSION" >> /sdcard/Pixelify/version/nga.txt
fi
fi
fi
ui_print ""
print "- NGA Resources installation complete"
print "- Patching Next Generation Assistant Files.."
name=$(grep current_account_name /data/data/com.android.vending/shared_prefs/account_shared_prefs.xml | cut -d">" -f2 | cut -d"<" -f1)
f1=$(grep 12490 $GOOGLE_PREF | cut -d'>' -f2 | cut -d'<' -f1)
f2=$(grep 12491 $GOOGLE_PREF | cut -d'>' -f2 | cut -d'<' -f1)
if [ ! -z $name ]; then
string_patch GSAPrefs.google_account $name $MODPATH/files/GEL.GSAPrefs.xml
fi
if [ ! -z $f1]; then
string_patch 12490 "$f1" $MODPATH/files/GEL.GSAPrefs.xml
fi
if [ ! -z $f2 ]; then
string_patch 12491 "$f2" $MODPATH/files/GEL.GSAPrefs.xml
fi
cp -f $MODPATH/files/GEL.GSAPrefs.xml $MODPATH/GEL.GSAPrefs.xml
chmod 0771 /data/data/com.google.android.googlequicksearchbox/shared_prefs
rm -rf $GOOGLE_PREF
rm -rf /data/data/com.google.android.googlequicksearchbox/cache/*

if [ -z $(find /system -name Velvet) ] && [ ! -f /data/adb/modules/Pixelify/system/product/priv-app/Velvet/Velvet.apk ]; then
print ""
print "- Google is not installed as a system app !!"
print "- Making Google as a system app"
REMOVE="$REMOVE $GOOGLE"
cp -r ~/$app/com.google.android.googlequicksearchbox*/. $MODPATH/system/product/priv-app/Velvet
mv $MODPATH/system/product/priv-app/Velvet/base.apk $MODPATH/system/product/priv-app/Velvet/Velvet.apk
rm -rf $MODPATH/system/product/priv-app/Velvet/oat
mv $MODPATH/files/privapp-permissions-com.google.android.googlequicksearchbox.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.googlequicksearchbox.xml
elif [ -f /data/adb/modules/Pixelify/system/product/priv-app/Velvet/Velvet.apk ]; then
print ""
print "- Google is not installed as a system app !!"
print "- Making Google as a system app"
REMOVE="$REMOVE $GOOGLE"
cp -r ~/$app/com.google.android.googlequicksearchbox*/. $MODPATH/system/product/priv-app/Velvet
mv $MODPATH/system/product/priv-app/Velvet/base.apk $MODPATH/system/product/priv-app/Velvet/Velvet.apk
rm -rf $MODPATH/system/product/priv-app/Velvet/oat
mv $MODPATH/files/privapp-permissions-com.google.android.googlequicksearchbox.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.googlequicksearchbox.xml
fi

else
sed -i -e "s/export GOOGLE/#export GOOGLE/g" $MODPATH/service.sh
sed -i -e "s/chmod 0551/#chmod 0551/g" $MODPATH/service.sh
sed -i -e "s/cp -Tf/#cp -Tf/g" $MODPATH/service.sh
fi
fi

if [ -f /sdcard/Pixelify/backup/pixel.tar.xz  ]; then
ui_print ""
print "  Do you want to install and Download Pixel LiveWallpapers?"
print "  (Backup detected, no internet needed)"
print "   Vol Up += Yes"
print "   Vol Down += No"
ui_print ""
if $VKSEL; then
if [ ! $(cat /sdcard/Pixelify/version/pixel.txt) -eq $LWVERSION ]; then
ui_print ""
print "  (Interned Needed)"
print "  New version Detected "
print "  Do you Want to update or use Old Backup?"
print "  Version: $LWVERSION"
print "  Size: $LWSIZE"
print "   Vol Up += Yes"
print "   Vol Down += No"
ui_print ""
if $VKSEL; then
rm -rf /sdcard/Pixelify/backup/pixel.tar.xz
rm -rf /sdcard/Pixelify/version/pixel.txt
cd $MODPATH/files
curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pixel.tar.xz -O &> /proc/self/fd/$OUTFD
cd /
print "- Creating Backup"
print ""
cp -f $MODPATH/files/pixel.tar.xz /sdcard/Pixelify/backup/pixel.tar.xz
echo "$LWVERSION" >> /sdcard/Pixelify/version/pixel.txt
fi
fi
print "- Installing Pixel LiveWallpapers"
tar -xf /sdcard/Pixelify/backup/pixel.tar.xz -C $MODPATH/system/product
wall=$(find /system -name WallpaperPickerGoogle*.apk)
REMOVE="$REMOVE $wall"
fi
else
ui_print ""
print "  Interned Needed for Step !!"
print "  Do you want to install and Download Pixel LiveWallpapers?"
print "  Size: $LWSIZE"
print "   Vol Up += Yes"
print "   Vol Down += No"
ui_print ""
if $VKSEL; then
print "- Downloading Pixel LiveWallpapers"
ui_print ""
cd $MODPATH/files
curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pixel.tar.xz -O &> /proc/self/fd/$OUTFD
cd /
print ""
print "- Installing Pixel LiveWallpapers"
tar -xf $MODPATH/files/pixel.tar.xz -C $MODPATH/system/product
wall=$(find /system -name WallpaperPickerGoogle*.apk)
REMOVE="$REMOVE $wall"
ui_print ""
print "  Do you want to create backup of Pixel LiveWallpapers?"
print "  so that you don't need redownload it everytime."
print "   Vol Up += Yes"
print "   Vol Down += No"
if $VKSEL; then
ui_print ""
print "- Creating Backup"
mkdir /sdcard/Pixelify
mkdir /sdcard/Pixelify/backup
rm -rf /sdcard/Pixelify/backup/pixel.tar.xz
cp -f $MODPATH/files/pixel.tar.xz /sdcard/Pixelify/backup/pixel.tar.xz
print ""
mkdir /sdcard/Pixelify/version
echo "$LWVERSION" >> /sdcard/Pixelify/version/pixel.txt
print " - Done"
fi
fi
fi

print ""
print "  Do you want to Spoof your device to Pixel 5 (redfin)?"
print "  Needed For Next Generation Assistant and many more features."
print "   Vol Up += Yes"
print "   Vol Down += No"
ui_print ""
if $VKSEL; then
cat $MODPATH/spoof.prop >> $MODPATH/system.prop
fi

print "  Do you want to install PixelBootanimation?"
print "   Vol Up += Yes"
print "   Vol Down += No"
if $VKSEL; then
if [ ! -f /system/bin/themed_bootanimation ]; then
rm -rf $MODPATH/system/product/media/bootanimation.zip
mv $MODPATH/system/product/media/bootanimation-dark.zip $MODPATH/system/product/media/bootanimation.zip
fi
else
rm -rf $MODPATH/system/product/media/boot*.zip
fi

FIT=/data/data/com.google.android.apps.fitness/shared_prefs/growthkit_phenotype_prefs.xml
if [ -f $FIT ]; then
print ""
print " Google Fit is installed."
print "- Enabling Heart rate Measurement "
print "- Enabling Respiratory rate."
bool_patch DeviceStateFeature $FIT
bool_patch TestingFeature $FIT
bool_patch Sync__sync_after_promo_shown $FIT
bool_patch Sync__use_experiment_flag_from_promo $FIT
bool_patch Promotions $FIT
fi


GBOARD=/data/data/com.google.android.inputmethod.latin/shared_prefs/flag_value.xml
if [ -f $GBOARD ]; then
ui_print ""
print " GBoard is installed."
print "- Enabling Redesigned Ui"
print "- Enabling Lens for Gboard"
print "- Enabling NGA Voice typing (If Nga is installed)"
bool_patch nga $GBOARD
bool_patch redesign $GBOARD
bool_patch lens $GBOARD
bool_patch generation $GBOARD
bool_patch multiword $GBOARD
bool_patch core_typing $GBOARD
fi

if [ $API -eq 30 ]; then
print ""
print "- Installing DevicePersonalisationService"
print "- Enabling Adaptive Sound & Live Captions ..."
tar -xf $MODPATH/files/dp.tar.xz -C $MODPATH/system/product/priv-app
mv $MODPATH/system/product/priv-app/DevicePersonalizationPrebuiltPixel2020 $MODPATH/system/product/priv-app/devicePersonalizationPrebuiltPixel2020
fi

REPLACE="$REMOVE"

chmod 0644 $MODPATH/system/product/overlay/*.apk
chmod 0644 $MODPATH/system/product/priv-app/*/*.apk
chmod 0644 $MODPATH/system/product/app/*/*.apk
chmod 0644 $MODPATH/system/product/etc/permissions/*.xml
chmod 0644 $MODPATH/system/vendor/etc/permissions/*.xml

#Clean Up
rm -rf $MODPATH/files
rm -rf $MODPATH/spoof.prop

ui_print ""
print "- Done"
ui_print ""
