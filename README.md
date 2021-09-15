# PIXELIFY MAGISK MODULE
Enables Pixel Ui and Some Exclusive Features.<br>

### Please Read [this](https://github.com/Kingsman44/magisk_module_pixelify#-how-to-enable-features) before installing

## ⭐ Requirements
- **At least Nougat**
- **Arm64 device**
- **Volume Keys**
- **Internet for NGA Resources & Pixel Livewallpaper**

## ⭐ Features
-   Adaptive Charging (Google SystemUI)
-   Adaptive Connectivty (11+)
-   Adaptive Sound (11+)
-   Call Captions (11+)(Depends on Rom)
-   Enables Nexus, Pixel, and Android One app support
-   Extreme Battery Saver (11) [ Settings > Battery > Extreme Battery Saver ]
-   Google Dialer Call Screening Latest
-   Google Dialer Hold for me
-   Google Dialer Call Recording (Device depended for working)(Beta)
-   Google Digital Wellbeing Heads up
-   Google Duo features
-   Google Fit Heart rate (needed reboot if installed after module installtion)
-   Google Fit Respiratory rate (needed reboot if installed after module installtion)
-   Google GBoard New Design*
-   Google Gboard Assistant Mic* (If Preinstalled & NGA installed)
-   Google Gboard Lens support*
-   Google Gboard Smart Compose*
-   Google Photos Unlimited Storage
-   Google Sans Font
-   Live captions (10+)
-   Next Generation Assistant (10+)(Optional)
-   Now Playing Export (Works only on Pixel Phone)
-   Pixel Device spoof (Optional)
-   Pixel Blue theme accent
-   Pixel bootanimation (Optional)
-   Pixel Launcher (11)
-   Pixel Live Wallpapers (Optional)
-   Portrait Light (10+)
-   Screen Attention Service
-   Shareable Google Recorder 
<br>
* - There are two types of Gboard (com.android.inputmethod.latin and com.google.android.inputmethod.latin), These are only available for com.google.android.inputmethod.latin

## ⭐ How to Enable Features

### 1) Google Next Generation Assistant (Works without Spoof props for some people)
- **Installation**:- Install NGA RESOURCES in Installation.<br>
- **How to Enable**:- After installation reboot your phone, then while open assistant you will get prompt to download additional resources, download it and **reboot** your phone<br>
- **Note**:- Incase Assistant Ui is gone, just Reboot your Phone.<br>

## ⭐ Bugs and Fixes
- **Call Screening**: caller can't hear your voice.<br>
**Fix commit (Audio Hal v6):** https://github.com/PotterLab/arrow_device_motorola_potter/pull/1/commits/049dfa580bae0ed0dd47cf9c4acb2df410e119df
- **Call Screening**: can't able to download call screening files.<br>
**Fix:** Set WIFI to unmetered connection. <br>
- **Google**: Ok Google doesn't work without hotword with spoof to pixel.<br>
- **Google**: Next Generation Assistant Continued Conversation doesn't work without spoof to pixel<br>

## ⭐ Credits
- [topjohnwu](https://github.com/topjohnwu) for Magisk
- [Kdrag0n](https://github.com/kdrag0n) for SimpleDeviceConfig
- [Freak07](https://forum.xda-developers.com/m/freak07.3428502/) for Adaptive Sound
- [thehappydinoa](https://github.com/thehappydinoa) for Initial Call Screening
- [Pranav Pandey](https://forum.xda-developers.com/m/pranav-pandey.3962236/) for BreelWallpaper2020 Port

## ⭐ ChangeLogs
### Version 1.6
- Fixed Android S dimension problem and Accent colors problem
- Sept Sec Patch
- Fixed bootloop on some devices due to Extreme battery Saver
- Added Pixel Photos Unlimted storage backup
- Minor bug fixes 
- Extreme Battery Saver now optional.

### Version 1.5
- Fixed No Internet Connection problem on some roms.
- August Sec Patch
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
- July Sec Patch
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

