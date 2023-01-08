#!/system/bin/sh
DIR=/data/adb/modules/Pixelify
option=$1
sel=$2
ac=0

. $DIR/vars.sh
. $DIR/utils.sh

case $option in
"disable")
    if [ $sel == "pixellauncher" ] || [ $sel == "pl" ]; then
        rm -rf $DIR/system/**/priv-app/NexusLauncherRelease
        rm -rf $DIR/system/**/priv-app/*Launcher*
        rm -rf $DIR/system/**/priv-app/*Lawnchair*
        rm -rf $DIR/system/**/priv-app/*Trebuchet*
        rm -rf $DIR/system/**/priv-app/*QuickStep*
        rm -rf $DIR/system/**/priv-app/*MiuiHome*
        rm -rf $DIR/system/**/priv-app/*TouchWizHome*
        rm -rf $DIR/system/**/PixelLauncherOverlay.apk
    elif [ $sel == "now-playing" ]; then
        rm -rf $DIR/system/etc/firmware
        rm -rf $DIR/system/product/overlay/PixeliflyNowPlaying.apk
    elif [ $sel == "hotword" ]; then
        rm -rf $DIR/system/**/*Hotword*
        rm -rf $DIR/system/**/*hotword*
    else
        echo "x Invalid choice"
        ac=1
    fi
    if [ $ac -eq 0 ]; then
        echo "- Success, Please Reboot to take effect !!"
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
"lockscreen_qr")
    if [ $sel == "1" ] || [ $sel == "true" ]; then
        settings put secure lock_screen_show_qr_code_scanner 1
        echo "- Success"
    elif [ $sel == "0" ] || [ $sel == "false" ]; then
        settings put secure lock_screen_show_qr_code_scanner 0
        echo "- Success"
    else
        echo "x Invalid choice"
        ac=1
    fi
    ;;
"enable")
    if [ $sel == "now-playing" ]; then
        if [ -d $DIR/extras/nplaying ]; then
            cp -r $DIR/extras/nplaying/. $DIR
            echo "- Success, Please Reboot to take effect !!"
        else
            echo "! File missing, cannot able to install now playing"
        fi
    elif [ $sel == "hotword" ]; then
        if [ $API -ge 30 ]; then
            cp -r  $DIR/extras/hotword/. $DIR
        else
            cp -r  $DIR/extras/hotword-9/. $DIR
        fi
        echo "- Success, Please Reboot to take effect !!"
    else
        echo "x Invalid choice"
        ac=1
    fi
    ;;
"*")
    echo "x Invalid choice"
    ;;
esac
