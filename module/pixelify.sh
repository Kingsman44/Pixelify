#!/system/bin/sh
DIR=/data/adb/modules/Pixelify
option=$1
sel=$2
ac=0

case $option in
"--disable")
    if [ $sel == "pixellauncher" ] || [ $sel == "pl" ]; then
        rm -rf $DIR/system/**/priv-app/NexusLauncherRelease
        rm -rf $DIR/system/**/priv-app/*Launcher*
        rm -rf $DIR/system/**/priv-app/*Lawnchair*
        rm -rf $DIR/system/**/priv-app/*Trebuchet*
        rm -rf $DIR/system/**/priv-app/*QuickStep*
        rm -rf $DIR/system/**/priv-app/*MiuiHome*
        rm -rf $DIR/system/**/priv-app/*TouchWizHome*
        rm -rf $DIR/system/**/PixelLauncherOverlay.apk
    else
        echo "x Invalid choice"
        ac=1
    fi
    if [ $ac -eq 0 ]; then
        echo "- Success"
    fi
    ;;
"--remove-backup")
    if [ $sel == "pixellauncher" ] || [ $sel == "pl" ]; then
        rm -rf /sdcard/Pixelify/*/pl-*
    elif [ $sel == "asi" ] || [ $sel == "androidsystemintelligence" ]; then
        rm -rf /sdcard/Pixelify/*/asi-*
        rm -rf /sdcard/Pixelify/*/dp-*
    elif [ $sel == "nga" ]; then
        rm -rf /sdcard/Pixelify/*/nga*
        rm -rf /sdcard/Pixelify/*/NgaResources*
    elif [ $sel == "livewallapers" ] || [ $sel == "lw" ]; then
        rm -rf /sdcard/Pixelify/*/pixel*
    elif [ $sel == "osr" ]; then
        rm -rf /sdcard/Pixelify/*/osr*
    elif [ $sel == "callscreen" ] || [ $sel == "cs" ]; then
        rm -rf /sdcard/Pixelify/*/callscreen*
    elif [ $sel == "all" ]; then
        rm -rf /sdcard/Pixelify/backup /sdcard/Pixelify/version
    else
        echo "x Invalid choice"
        ac=1
    fi
    if [ $ac -eq 0 ]; then
        echo "- Done"
    fi
    ;;
"*")
    echo "x Invalid choice"
    ;;
esac
