# PIXELIFY MAGISK MODULE
Enables Pixel Ui and Some Exclusive Features.<br>

<a href="https://forum.xda-developers.com/t/magisk-pixelify.4415387/"><img src="https://img.shields.io/badge/XDA_Thread-brown.svg"></a>
<a href="https://photos.app.goo.gl/jBPm3zTHHhc67Pdy7"><img src="https://img.shields.io/badge/Screenshots-red.svg"></a>
<a href="https://t.me/pixelifysupport"><img src="https://img.shields.io/badge/Telegram-Support_Group-blue.svg"></a>

## ⭐ Requirements
- **Android Version: Android 7.0 to Android 13**
- **Arm64 device**
- **Volume Keys**
- **Internet for NGA Resources, Pixel Livewallpaper, Device Personalization Services & Pixel Launcher**
- **Zygisk (Recommended but not compulsary)**
- **Note: flash zip on magisk only not twrp**

### Supported Roms
- OneUi
- Custom Roms
- Pixel Stock
- Android One
- MiUI
- FunTouchOS
- Oxygen OS (Android 11 and below)
- Color Os (Android 11 and below)

### Unsupported Roms
- Oxygen os Android 12
- Color Os Android 12

### Installation
- Recommend to use magisk v24 or above from Pixelify v2
- If Volume keys are working then ignore no_vk files otherwise check Installation without Volume Keys
- Enable zygisk
- Flash Module
- Enjoy

### Installation without Volume Keys
- Use packages with Pixelify-${version}-no_VK.zip
- Place no-Vk.prop to internal storage>Pixelify (/sdcard/Pixelify/no-VK.prop)
- Edit prop according what you want to select
- (If you have any problem placing no-VK.prop there then you also can extract and update no-VK.prop inside the packages it automatcally use it.) 

### Zygisk spoofing configuration
- Pixel 5:- Google TTS, Google Recorder, Play services, Google app
- Pixel XL:- Google Photos
- Pixel 6 Pro:- Rest Google apps except (all Google camera package)
<br><br>**Note** :- Zygisk spoofing can't overide PixelProp Utils.

## ⭐ Features
### Pixel 6 Features Enables
-   Pixel 6 Live Wallpapers *
-   Magic Eraser (<a href="https://t.me/google_nws/864">USE THIS APK</a>)(7+)
-   Google Dialer Direct Call (12+)
-   Live Transcript (12+)
-   New At a Glance feature (12+ & Dec+ Patch) 
-   Google Quick Pharse *
-   Google Next Generation Assistant Typing (Next Generation Assistant Required)*
-   At a Glance Features. 

### Other Features
-   Adaptive Charging (Google SystemUI)
-   Adaptive Connectivty (11+)
-   Adaptive Sound (11+)*
-   Call Captions (11+)(Depends on Rom)
-   Enables Nexus, Pixel, and Android One app support
-   Extreme Battery Saver (11+) [ Settings > Battery > Extreme Battery Saver - 11 | Settings > Battery > Battery Saver > Extreme Battery Saver -12 ]
-   Google Dialer Call Screening
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
-   Unlimited Photos backup (Storage saver)
-   Unlimited Photos backup (original) (needs Zygisk magisk 24+)
<br>
* - Requires Spoofing to Pixel device

### Call Screening Supported languages other than English US <br>
**(Before you install the module, your country's language needs to be set as default system language and your SIM card needs to be from the same country.)**
<br> **Note: Automatic call screening aren't supported by these languages**
- Italian (IT)
- Japanese (JP)
- Spain (ES)
- France (FR)
- Germany (DE)

## ⭐ Guide to enable / Faqs / Troubleshooting
- [https://telegra.ph/Pixelify-Troubleshooting-guide-03-12](https://telegra.ph/Pixelify-Troubleshooting-guide-03-12)

## Contribute to project
- Reporting bugs with logs
- Feature Requests
- Supporting other persons on issues or telegram group
- Creating pull request to enable new feature or code improvements
- Donation

### Donation link
- **Paypal link** - [https://paypal.me/shivan999?country.x=IN&locale.x=en_GB](https://paypal.me/shivan999?country.x=IN&locale.x=en_GB)
- **UPI id (India only)** - shivan.0972@okhdfcbank

## ⭐ Credits
- [topjohnwu](https://github.com/topjohnwu) for Magisk
- #TeamFiles for many icons for Pixel Launcher android 12
- [Kdrag0n](https://github.com/kdrag0n) for SimpleDeviceConfig
- [Freak07](https://forum.xda-developers.com/m/freak07.3428502/) for Adaptive Sound
- [Pranav Pandey](https://forum.xda-developers.com/m/pranav-pandey.3962236/) for BreelWallpaper2020 Port

## ⭐ ChangeLogs

### Version 2.01
- Fixed Safety net issues
- Fixed blank call screen when Google Dialer not installed or not selected Google Dialer features for other Dialers
- Added support for German call screening lang support
- Spoofed Snapchat to pixel 6
- Enabled Battery Widget (March Security patch+)
- Fixed Precise Location
- Fixes for Play Store downloading
- Enable Wellbeing widget
- Fixed crashes of extreme saver mode on custom rom
- Call voice issue for some people had been fixed.
- Attempt to fix Pixel Launcher on stock roms like MiUi, OneUi....
- Updated Android System Intelligence to latest version
- Initial support for Android 12L and Android 13
- Fixed for battery drain issue
- Better support for tensor chip
- Pixel 6 user now will have option to choose magic eraser or unlimited storage
- Some minor improvements.

### Version 2.0
- Bug Fixes & lots of improvements
- Fixed Google Assistant bug
- Spoofing via Zygisk (Magisk v24 or v24+ is required)
- Call screening support for Italian (IT), Japanese (JP), Spain (ES), France (FR)
- Fixes for Android System Intelligence installation.
- Rename Device Personalisation services to Android System Intelligence
- Module will auto detect and install Bootanimation according your resolution.
<br>  Supported are:- 720p, 1080p, 1440p
<br>  Other resolution will use 1080p
- Fixed opposite installation via No volume key problem
- Enable All options in At a glance
- Forcely Enabled Android S notification style dialer notification for Android S
- Fixed Removal of some fonts on installing Pixelify module
- Added more fixes to enable Nga voice typing
- Fixed Pixel Launcher Crash due to missing PACKAGE_USAGE permission
- Added and optimise Nexus launcher 3rd party icons
- Updated Android System Intelligence (12) to S11
- Some more fixes for Call screening
- Fixed Wrong detection for using Nov patch or December Patch Pixel Launcher
- Fixed removal of system app on uninstalling Pixelify module
- Made dialer popup less annoyed (it will come if using pixel2021 version
- Removed option to spoof Pixel 3XL as Google removed Unlimited for Pixel 3 XL (You can still get Unlimited via Zygisk)
- Added missing NGA_BACKUP tag for No volume keys
- Fixes for Google recorder
- Fixed Search Bar background color in A12

### Version 1.9
- Fixed crash of Private compute app
- Added option for Google Unlimited storage backup
- Added Support without volume keys
- Fixes for call screening, call recording
- Fixed Pixel launcher crash
- Fixed Smart Compose
- Added more icons on Pixel Launcher A12
- Lots of bug fixes
- Removed intro voice for call recording for more devices

### Version 1.81
- Fixes for Downloading Live Caption on A12
- Update Device Personalisation Services (A12)
- Option to switch spoof to Pixel 6 Pro or Pixel 5
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
