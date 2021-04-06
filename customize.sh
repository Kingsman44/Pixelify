export KEYS=$MODPATH/keycheck
chmod +x $KEY

print() {
ui_print "$@"
sleep 0.3
}

print " Detected Arch: $ARCH"
print " Detected SDK : $API"
RAM=$( grep MemTotal /proc/meminfo | tr -dc '0-9')
print " Detected Ram: $RAM"
ui_print ""
if [ $RAM -le "6291456" ]; then
rm -rf $MODPATH/system/product/etc/sysconfig/GoogleCamera_6gb_or_more_ram.xml
fi

if [ $ARCH != "arm64" ]; then
 abort "Only support arm64 devices"
fi

DIALER1="
/system/priv-app/GoogleDialer
/system/app/Dialer
/system/product/app/Dialer
/system/product/priv-app/GoogleDialer
"

if [ $API -eq "30" ]; then
REMOVE="
/system/product/priv-app/DevicePersonalizationPrebuilt2
/system/product/priv-app/DevicePersonalizationPrebuilt3
/system/product/priv-app/DevicePersonalizationPrebuilt4
/system/product/priv-app/MatchmakerPrebuiltPixel2
/system/product/priv-app/MatchmakerPrebuiltPixel3
/system/product/priv-app/MatchmakerPrebuiltPixel4
/system/product/priv-app/MatchmakerPrebuiltPixel5
/system/priv-app/DevicePersonalizationPrebuilt2
/system/priv-app/DevicePersonalizationPrebuilt3
/system/priv-app/DevicePersonalizationPrebuilt4
/system/priv-app/MatchmakerPrebuiltPixel2
/system/priv-app/MatchmakerPrebuiltPixel3
/system/priv-app/MatchmakerPrebuiltPixel4
/system/priv-app/MatchmakerPrebuiltPixel5
"
fi

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
  print "- Vol Key Test"
  print "   Press a Vol Key:"
  if (timeout 3 /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events); then
    return 0
  else
    print "   Try again:"
    timeout 5 $KEYS
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
    $KEYS
    $KEYS
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
  *novk*) print "- Skipping Vol Keys -";;
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

print "- Installing Pixelify..."
ui_print ""

GPATCH=1
DIALER_PREF=/data/data/com.google.android.dialer/shared_prefs/dialer_phenotype_flags.xml
print " - Installing Call Screening -"
if [ -d /data/data/$DIALER ]; then
  ui_print "----"
  print "Google Dialer Already installed !!"
  print "Call Screening other than US needs GoogleDialer version less 41"
  ui_print ""
  print "Do you want to install GoogleDialer 40.0.275948326??"
  print "Vol Up = Yes, Vol Down = No"
  ui_print "----"
  ui_print ""
  if $VKSEL; then
    if [ -d /data/app/*/$DIALER* ] || [ -d /data/app/$DIALER* ]; then
      ui_print ""
      print "Unistalling GoogleDialer Update"
      rm -rf /data/app/*/$DIALER*
      rm -rf $DIALER_PREF
      cp -f $MODPATH/dialer_phenotype_flags.xml $DIALER_PREF
      chmod 0660 $DIALER_PREF
      rm -rf /data/app/$DIALER*
    fi
    ui_print ""
    print "Installing GoogleDialer"
    REMOVE="$REMOVE $DIALER1"
  else
    rm -rf $MODPATH/system/product/priv-app/GoogleDialer
    print "Enabling CallScreening features..."
    bool_patch atlas $DIALER_PREF
    bool_patch speak_easy $DIALER_PREF
    bool_patch speakeasy $DIALER_PREF
    bool_patch call_screen $DIALER_PREF
    bool_patch revelio $DIALER_PREF
    bool_patch record $DIALER_PREF
    bool_patch transcript $DIALER_PREF
  fi
else
  print "Google Dialer not installed."
  ui_print ""
  mkdir /data/data/$DIALER
  mkdir /data/data/$DIALER/shared_prefs
  chmod 0771 /data/data/$DIALER/shared_prefs
  cp -f $MODPATH/dialer_phenotype_flags.xml $DIALER_PREF
  chmod 0660 $DIALER_PREF
  print "Installing GoogleDialer"
  REMOVE="$REMOVE $DIALER1"
fi
ui_print ""
print "Please Don't Update GoogleDialer (Other than US region),"
print "It will remove Call Screening."
ui_print ""
print "To get it back.."
print "Just unistall update and reboot your phone !!"
ui_print ""

FIT=/data/data/com.google.android.apps.fitness/shared_prefs/growthkit_phenotype_prefs.xml
if [ -f $FIT ]; then
ui_print ""
print "Google Fit is installed."
print "- Enabling Heart rate Measurement "
print "- Enabling Respiratory rate."
ui_print ""
bool_patch DeviceStateFeature $FIT
bool_patch TestingFeature $FIT
bool_patch Sync__sync_after_promo_shown $FIT
bool_patch Sync__use_experiment_flag_from_promo $FIT
bool_patch Promotions $FIT
fi


GBOARD=/data/data/com.google.android.inputmethod.latin/shared_prefs/flag_value.xml
if [ -f $GBOARD ]; then
ui_print ""
print "GBoard is installed."
print "- Enabling Redesigned Ui"
print "- Enabling Smart Compose (Beta)"
print "- Enabling NGA Voice typing (If Nga is installed)"
ui_print ""
bool_patch nga $GBOARD
bool_patch redesign $GBOARD
bool_patch lens $GBOARD
bool_patch generation $GBOARD
bool_patch multiword $GBOARD
bool_patch core_typing $GBOARD
fi

if [ $API -eq 30 ]; then
print "Installing DevicePersonalisationService"
print "- Enabling Adaptive Sound & Live Captions ..."
if [ -d /data/app/*/com.google.android.as* ] || [ -d /data/app/com.google.android.as* ]; then
rm -rf /data/app/*/com.google.android.as*
rm -rf /data/app/com.google.android.as*
fi
fi

TURBO=/data/data/com.google.android.apps.turbo/shared_prefs/phenotypeFlags.xml
if [ -f $TURBO ]; then
bool_patch AdaptiveCharging__v1_enabled $TURBO
bool_patch AdaptiveBattery $TURBO
fi

REPLACE="$REMOVE"

print "- Done -"
