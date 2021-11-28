# PIXELIFY MAGISK MODULE
Enables Pixel Ui and Some Exclusive Features.<br>

<a href="https://photos.app.goo.gl/jBPm3zTHHhc67Pdy7"><img src="https://img.shields.io/badge/Screenshots-red.svg"></a>
<a href="https://t.me/pixelifysupport"><img src="https://img.shields.io/badge/Telegram-Support_Group-blue.svg"></a>

## ⭐ Requirements
- **Android Version: 7.0+**
- **Arm64 device**
- **Volume Keys**
- **Internet for NGA Resources, Pixel Livewallpaper, Device Personalization Services & Pixel Launcher**

## ⭐ Features
### Pixel 6 Features Enables
-   Pixel 6 Live Wallpapers *
-   Magic Earser (<a href="https://t.me/google_nws/864">USE THIS APK</a>)(7+)
-   Google Dialer Direct Call (<a href="https://www.apkmirror.com/apk/google-inc/google-phone/google-phone-72-0-407683083-publicbeta-pixel2021-release/">USE THIS APK</a>)(7+)
-   Live Transcript(12+)
-   Google Quick Pharse *
-   Google Next Generation Assistant Typing (Next Generation Assistant Required)*

### Other Features
-   Adaptive Charging (Google SystemUI)
-   Adaptive Connectivty (11+)
-   Adaptive Sound (11+)*
-   Call Captions (11+)(Depends on Rom)
-   Enables Nexus, Pixel, and Android One app support
-   Extreme Battery Saver (11+) [ Settings > Battery > Extreme Battery Saver - 11 | Settings > Battery > Battery Saver > Extreme Battery Saver -12 ]
-   Google Dialer Call Screening Latest
-   Google Dialer Hold for me
-   Google Dialer Call Recording (Device depended for working)
-   Google Digital Wellbeing Heads up
-   Google Duo features
-   Google Fit Heart rate (needed reboot if installed after module installtion)
-   Google Fit Respiratory rate (needed reboot if installed after module installtion)
-   Google Sans Font
-   Live captions (10+)
-   Next Generation Assistant* (10+)(Optional)
-   Now Playing Export* (Works only on Pixel Phone)
-   Pixel Device spoof (Optional)
-   Pixel Blue theme accent
-   Pixel bootanimation (Optional)
-   Pixel Launcher (10+)(Optional)
-   Pixel Live Wallpapers (Optional)
-   Pokemon SideKick Live Wallpaper (Optional-Included with LiveWallpapers)
-   Portrait Light (10+)
-   Screen Attention Service
-   Unlimited Photos backup (Storage Saver)
<br>
* - Requires Spoofing to Pixel device

## ⭐ How to Enable Features
### 1) Google Photos Unlimited Backup (storage saver)
- **Enable**:-  Clear Data Photos for first time installing Module<br>
- **Note**:-  It won't show you Unlimited Text, but your backup photos won't be counted on storage, you can check total after upload photos it won't change or will be back to same storage after 5-10 mins<br>

## ⭐ Bugs and Fixes
- **Call Screening**: caller can't hear your voice.<br>
**Fix commit:** https://github.com/Redmi-note-4x/android_hardware_qcom-caf_audio/commit/0074cac9a4b098f8c4c996a4ef7ca44d00b158d9,https://github.com/Redmi-note-4x/android_hardware_qcom-caf_audio/commit/de2146fdd88771182a677aa94ccb8237479d793d (According to your qcom board)
- **Call Screening**: can't able to download call screening files.<br>
**Fix:** Set WIFI to unmetered connection. <br>
- **Google**: Ok Google doesn't work without hotword with spoof to pixel.<br>
- **Google**: For Continued Conversation and fix At a Glance in Android 12 (<a href="https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/Velvet.zip">USE THIS APK</a>) (Use Sai Installer to install this splits apk)

## ⭐ Credits
- [topjohnwu](https://github.com/topjohnwu) for Magisk
- [Kdrag0n](https://github.com/kdrag0n) for SimpleDeviceConfig
- [Freak07](https://forum.xda-developers.com/m/freak07.3428502/) for Adaptive Sound
- [Pranav Pandey](https://forum.xda-developers.com/m/pranav-pandey.3962236/) for BreelWallpaper2020 Port

## ⭐ ChangeLogs
### Version 1.81
- Fixes for Downloading Live Caption on A12
- Fixed Text Selection in recents pixel Launcher on A12
- Update Device Personalisation Services (A12)
- Option to switch to Pixel 6 Pro or Pixel 5
- some fixes for download Live Translate
- Switched Online for Pixel Launcher
- Android 12 Pixel Launcher now supports 450 themed icons.
- Fixes for Nga Voice Typing & Bloom section in Pixel Live Wallpapers
- Fixes for Quick Phrase
- Reduced initial module size to 22 Mb

### Version 1.8
- Introduced Installation Logs (/sdcard/Pixelify/logs.txt) 
- New way for SimpleDeviceConfig
- introduced auto generate apps permissions
- Added Pokemon SideKick LiveWallpaper
- Small bugs fixes and Ui changes
- Updated Device Personalisation services (a12)
- Fixes on Unlimited Photos Backup
- Added more themed icon on Pixel Launcher (a12)

### Version 1.71
- Attempt to enable Direct my Call and Call Recording to all countries
- Dropped fingerprint spoof
- Dropped SimpleDeviceConfig
- Update Bootanim and media from pixel 6
- introduced auto generate apps permissions
- Fixed Magic earser
- Switched model Spoof to Pixel 5
- Added Unlimited Photos backup (Storage Saver)
- Enabled Direct Call in Google Dialer (<a href="https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/GoogleDialer.apk">USE THIS APK</a>)
- Enabled Live Transcript (Not working on my device)
- Enabled Google Quick Pharse
- Enabled Pixel 6 Live Wallpapers (Update APK from playstore)

### Version 1.7
- Fingerprint - October Security patch (A11)
- Fixed Photos Editor & not detecting pixel devices on spoof (Need Clear data)
- Added Small patch for call screening voice fix (may not work with all devices)
- Updated Live Wallpaper (all) and Device Personalisation (A11+A12) packages
- Added Pixel launcher for A12
- New Pixel 6 Design Google Assistant (NGA)
- Switched Model to Pixel 6
- Fixed crashing of Device Personalisation on Android 12
- Added Styles and Wallpaper & Extreme Battery Saver for Android 12
- fixed minor bugs

### Version 1.6
- Fixed Android S dimension problem and Accent colors problem
- Fingerprint - September Security patch
- Fixed bootloop on some devices due to Extreme battery Saver
- Added Pixel Photos Unlimted storage backup
- Minor bug fixes 
- Extreme Battery Saver now optional.

### Version 1.5
- Fixed No Internet Connection problem on some roms.
- Fingerprint - August Security patch
- Fixes Camera Crash for some deivces
- Device Personalisation is Optional
- Size of Module Reduze to 25Mb
- Android S Minimal Support
- Added Extreme Battery Saver (Android 11 Only | S will be supported on afterwards) [ On Settings > Battery ]
- Enabled Google Dialer Video Calling Preference, Bussiness Search, Android S Ui (For all Android Version), Prefix (May Not Work)

### Version 1.4
- Introduced auto set Fp according build id to fix cts
- Google Latest Call Screening for everyone
- Google Hold for Me
- Google Photos Locked Folder
- Google Assistant to Answer Call, Reject Call 
- Updated GEL.GSAPrefs.xml
- Introduced Logs, saved at Internal Storage > Pixelify > logs.txt (Beta)
- Forced Enable Caption Call (In Live Caption Settings)(Depends on ROM)
- Bug Fixes
- Support for Live Caption and Pixel Launcher for Android Q
- Fingerprint - July Security patch
- Fixed small Issues
- Added Google Call Recording (Beta)
- Fixed now playing for pixel devices

### Version 1.3
- Added Adaptive Connectivity
- Fixed small bug
- Signed all overlays with system signature
- Improved Gboard Smart Compose
- Improved gboard new design (Now more colors are available in Themes)
- Gboard will also converted into system-app if isn't
- Fixed Fingerprint for A10 to A8 devices. 
- Added SimpleDeviceConfig.apk
- Switch to Normal Pixel Launcher
- Fixed Uninstallation of other Launcher  
- Updated spoof props to june sec patch

### Version 1.2
- Updated Pixel Props to may
- Updated GEL.GSAPrefs.xml
- Fixed Pixel Launcher not installed
- Disabled Call screening if not selected

### Version 1.1
- Added NGA support without Pixel spoof
- Added Gboard Smart Compose
- Call Screening Optional

### Version 1.0
- Fixed Bootloops because of permissions
- Added Styles and Wallpapers for Pie and Ten

### Version Beta 1.5
- Improved backups support
- Fixed Google crashes
- Add Wellbeing headsup (beta only)

### Version Beta 1.4
- Added Pixel Live Wallpapers
- Sdk support unitl 26
- added Overlay support for sdk less than 30
- Updated DevicePersonalisationSevice
- updated Turbo
- Fixed compatibility for sdk 26-29

### Version Beta 1.3
- Fixed Installation stuck on NGA resources
- Some Minor Fixes
- Fixed velvet (if non system app) is gone after uninstall

### Version Beta 1.2
- Fixed NGA Mic
- Added Settings Overlay for Screen Attention and Adaptive Charging
- Update Permissions for Dialer and DevicePersonalisation
- Fixed NGA on Roms using PropUtils

### Version Beta 1.1
- Add Next gen Assitant
- Fixed crash of GoogleDialer
- Removed Google Framework
- Added Option to backup NGA Resources
- Fixed CTS fail for some devices with Spoof 

### Beta 1.0
- Initial repo

