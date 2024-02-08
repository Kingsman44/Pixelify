# PIXELIFY MAGISK MODULE
A Magisk Module which enables Pixel UI and some exclusive features.<br>

<a href="https://www.pling.com/p/1794976"><img src="https://img.shields.io/badge/Download-v3.0-brown.svg" width="150"></a>
<a href="https://store.kde.org/p/1794976"><img src="https://img.shields.io/badge/Alternative-Link-brown.svg" width="150"></a>
<a href="https://www.pling.com/p/2004615/"><img src="https://img.shields.io/badge/Download-Submodules-brown.svg" width="200" height="30"></a>
<br><br>
<a href="https://forum.xda-developers.com/t/magisk-pixelify.4415387/"><img src="https://img.shields.io/badge/XDA_Thread-brown.svg"></a>
<a href="https://photos.app.goo.gl/jBPm3zTHHhc67Pdy7"><img src="https://img.shields.io/badge/Screenshots-red.svg"></a>
<a href="https://t.me/pixelifysupport"><img src="https://img.shields.io/badge/Telegram-Support_Group-blue.svg"></a>
<a href="https://paypal.me/shivan999?country.x=IN&locale.x=en_GB"><img src="https://img.shields.io/badge/PayPal-donation-blue.svg"></a>

## ⭐ Requirements
- **Supported Android Versions: Android 7.0 to Android 13**
- **ARM64 device**
- **Volume Keys (optional)**
- **Internet for downloading NGA Resources, Pixel Livewallpaper, Device Personalization Services & Pixel Launcher**
- **Magisk v24 or above from Pixelify v2+**
- **Zygisk or Riru (Recommended but not mandatory)**
- **NOTE: Flash the module zip file in the Magisk Manager app only; flashing the module in TWRP or any other recovery won't work.**

### Supported Roms
- OneUI
- AOSP Based Roms
- Pixel Stock
- Android One
- MIUI
- FunTouchOS
- OxygenOS
- ColorOS
- Windows Subsystem for Android

### Pixelify Sub Modules <br>
If the main Pixelify module is not functioning properly, or is too big for your phone, Pixelify module also provides some sub-modules for standalone features:
- Call Screening 
- Now Playing (Android System Intelligence required)
- Google Hotword
- Google Photos Unlimited Backup
- Google Bootanimation

### Installation instructions for v3
- Make Sure Play Store not installing when Pixelify is installing.
-  Magisk is Recommend
- If using KSU, install KSU zygisk module first
- Add Google Play Services and inside com.google.android.gms.unstable in DenyList.
- On installation, If see error when installing Google Photos, then uninstalling updates of google apps

### After Installations (For First Time Pixelify Installation):-
1) Playstore
- Clear Playstore data
- Open Playstore for 5-10 secs
- Force Stop Playstore
- Update Google App (For NGA & NGA Voice Typing)
- Untick Auto Updates for Google Photos, Android System Intelligence (Don't Update these app from playstore)

2)  Google Dialer
- Clear Data
- Open it for 5-10 secs
- Force Stop Google Dialer
- Open Google Dialer

3) Google App
- After Updating Google app from playstore
- Launch Google Assistant
- Let it Download and setup everything
- After setting up, automatically NGA Voice should work.

4) If NGA Voice typing not working then
- Set main Language of phone and Gboard to Supported NGA Languages
- Download 50xx Voice Pack in Google app
- Restart

5) Google Photos
- Clear Data
- Make sure connected to WiFi
- You may receive Updating Photos Editor, wait for it.
- Google Photos may download around 300-400mb only with WiFi

*Note:* Photos editor tool struck  Editing Tool will install soon 
- First Wait for sometimes and connect with WiFi
- Reboot
- if still not fixed (Reinstall Pixelify;- sometimes flags doesn't get patched due to gms performing action on database)

Working of Magic Editor, New Automatic Call Screening depends on Device, Kernel.

If Some features not working,
- Make Sure to Select YES for Disable Internal Spoofing
- Check file /sdcard/Pixelify/flaglog.txt
if you find Status: Error xxxxx on some flags, then you may need to reinstall pixelify.

### Installation without Volume Keys
- Use packages with Pixelify-${version}-no_VK.zip
- Place config.prop in your internal storage>Pixelify (/sdcard/Pixelify/config.prop)
- Edit the prop file according to what features you want
- (If you have any problem placing config.prop there then you also can extract and update config.prop inside the packages it automatically use it.) 

### Zygisk and Riru spoofing configuration
- Pixel 5:- Google TTS, Google Play services, Pixel Buds, Nothing Smart Center, Netflix
- Pixel XL:- Google Photos
- Pixel 8 Pro:- Google app, Google one, Breel Wallpaper, Snapchat, Adobe Light Room
- Pixel 6 Pro:- Rest Google apps except (all Google camera package)
<br><br>**Note** :- Zygisk spoofing can't override PixelProp Utils.

### Features of Pixelify module
- Initial Size of module is low
- Open Source
- Works with Riru as well as Zygisk
- Works with most of Android version (Nougat to 13)
- Uses Dynamic spoofing (Riru & Zygisk) for only Google apps to prevent crashes and other issues
- Provides most of the Pixel exclusive features
- Installation of features is optional
- Supports (720p,1080p,1440p) Google bootanimation
- Allows creation of backup of online Pixelify packages
- Also provides some unreleased Pixel Features
- Creates Google keyboard, Google app, Google Text to speech, Google Dialer as system app if not installed
- Dynamic Permission generation of apps installed by pixelify
- Config as well as Volume key installation
- Patches Flags to force enable pixel features
- Single zip works with Zygisk as well as Riru
- Works on almost all roms.

## ⭐ Pixel Features
### Pixel 7 & 8 Features Enables
-   Pixel 6 & Pixel 7 Live Wallpapers*
-   Magic Eraser
-   Magic Editor
-   Audio Eraser
-   ProofRead
-   Google Dialer Direct Call (12+)
-   New At a Glance feature (12+ & Dec+ Patch) 
-   Google Quick Phrase*
-   Google Next Generation Assistant Typing (Next Generation Assistant Required)*
-   Personalized Speech Recognition
-   Call Caption Typing (12+)
-   Live Captions different language

### Other Features
-   Adaptive Charging (Google SystemUI)
-   Adaptive Connectivity (11+)
-   Adaptive Sound (11+)*
-   Battery Widget (Working depends on rom)
-   Call Captions (11+)(Depends on Rom)
-   Enables Nexus, Pixel, and Android One app support
-   Extreme Battery Saver (11+) [ Settings > Battery > Battery Saver > Extreme Battery Saver -12 ]
-   Google Dialer Call Screening
-   Google Dialer Hold for me
-   Google Dialer Call Recording (Device depended for working)
-   Google Dialer Automatic Call Screening
-   Google Digital Wellbeing Heads up
-   Google Duo features
-   Google Fit Heart rate
-   Google Fit Respiratory rate
-   Live captions (10+)
-   Next Generation Assistant* (10+)(Optional)
-   Now Playing Export* (Works only on Pixel Phone)
-   Pixel Device spoofing (Optional)
-   Pixel Blue theme accent
-   Pixel bootanimation (Optional)
-   Pixel Launcher (10+)(Optional)
-   Pixel Live Wallpapers (Optional)
-   Pokemon SideKick Live Wallpaper (Optional-Included with LiveWallpapers)
-   Portrait Light (10+)
-   Screen Attention Service
-   Smart Compose
-   Unlimited Photos backup (Storage saver)
-   Unlimited Photos backup (original) (needs Zygisk or Riru)
<br>
* - Requires Spoofing to Pixel device

### Call Screening Supported languages other than English US <br>
- Italian (IT)
- Japanese (JP)
- Spain (ES)
- France (FR)
- Germany (DE)

## Contribute to project
- Reporting bugs with logs
- Feature Requests
- Supporting other persons on issues or telegram group
- Creating pull request to enable new feature or code improvements
- Donation

## Thanks to the following project contributors
- <a href="https://github.com/HiFiiDev">@HifiiDev, </a> <a href="https://github.com/theritikchoure">@theritikchoure,</a> <a href="https://github.com/ChrisvanChip">@ChrisvanChip</a> <a href="https://github.com/Anant-Strong">and @anant-strong</a>
 for Pull Requests that got merged 
- Johannes Drechsler, David Cash, Hendrik Roggenbuck, Ravijot Dhadial, Skyler Coles for Donation
- Pixelify Support Group Members for testing beta versions

### Donation
- **Paypal link** - [https://paypal.me/shivan999?country.x=IN&locale.x=en_GB](https://paypal.me/shivan999?country.x=IN&locale.x=en_GB)
- **UPI id (India only)** - shivan.0972@okicici

## ⭐ Credits
- Google for creating these awesome features
- [topjohnwu](https://github.com/topjohnwu) for Magisk
- [#TeamFiles](https://t.me/modulesrepo) for so many themed icons for Pixel Launcher android 12
- [Kdrag0n](https://github.com/kdrag0n) for SimpleDeviceConfig
- [Freak07](https://forum.xda-developers.com/m/freak07.3428502/) for Adaptive Sound
- [Pranav Pandey](https://forum.xda-developers.com/m/pranav-pandey.3962236/) for BreelWallpaper2020 Port
- [HuskyDG](https://github.com/HuskyDG) for intial Riru Port, Bootloop saver
- [Saitama](https://github.com/saitamasahil) Fixing Pixel Launcher crashes
- [Gapps Flag Leaks](https://t.me/GappsLeaks) AssembleDebug For some flags
- Pixelify Support Group Members for testing beta versions

## ⭐ ChangeLogs
### Version 3.0
- Added Proofread
- Added New automatic Call Screening (en-US)
- Added Audio Eraser
- Added Magic Editor
- Fixed Call Recording
- Added option for Auto switching Assistant typing
- Fixed Google dialer lag on some phones.
- Readded Google Fonts
- Removed Battery Health Services from Pixelify
- More Fixes for safety net
- Fixed For Zygisk detection for KSU
- Android 14 support
- Pixel Launcher crashes fixes for roms
- Enabled Loud sound alerts
- Enabled Ai Magic Wallpaper (Android 14)
- Fixed Permission Controller Crashing on some roms or device
- Updated Pixel Launcher, Styles and Wallpaper, Android System Intelligence
- Added option to backup styles and Wallpaper
- Added Option to install Pixel 8 Google Photos
- Added Flag logs of installation in /sdcard/Pixelify/flaglogs.txt
- Fixed Bug when not able to turn Google, Gboard as system app
- Fixes for Live Captions not downloading
- Fixed Google photos Unlimited Backup not working in AOSPA
- Fixed Ok Google
- Updated Spoofing
- Added Netflix in spoofing to enable HDR 
- Fixed Issue Automatic Battery Saver mode turning on and not turning off
- Fixes for RCS for some users
- Fixed Adaptive Sound not showing in Some roms
- Fixed Warning showing Empty XML in logs
- Some Background crashes fixes
- Fixes Web search not working in Pixel launcher search
- Battery Improvements
- Added Scan Text option in Gboard
- Removed Call Recording voice
- Added Call Recording Indicator
- Added Effects for Google Photos Video Editing
- Added 'Silence' Quick Phrase
- Minor Bug fixes & Improvements

### Version 2.2
- Added small Pixelify script to remove backup and disable pixel launcher without reinstalling
- Added support of NGA Resources in Android 13,12L,12,11
- Bootloop fixed on OxygenOS 13 & ColorOS 13
- Enabled Always On Display in settings
- Enabled Clip-Board-Overlay (A13)
- Enabled Live Bloom Wallpapers
- Enabled Pixel 3/4a Live Wallpapers
- Fixed Android System Intelligence crashes (A13)
- Fixed Google Recorder transcription for OEMS Roms
- Fixed Internal Spoof override for Evolution X A13
- Fixed Phones automatically reboot and Pixelify Disabled
- Fixed Pixel Launcher Crash on December Patches
- Fixed Pixel Launcher Crash on OxygenOS 12
- Fixed Riru Library for Pixel 6 models
- Fixed Uninstaller may taking cpu in background for some users
- Fixed crashes of styles and wallpapers on some ROMs (a13)
- Fixed incompatible version speech pack given by Google Offline Speech pack
- Fixed module disabled by default
- Fixed translation showing unknown languages
- Fixes for Assistant Voice Typing (NGA Tying)
- Fixes for Bootloop saver
- Fixes for Call Screening & Added More Call screening Languages
- Fixes for Call recording on google dialer
- Fixes for Google apps crashing on oppo color os, and Vivo phones (a13,a12)
- Fixes for Pixel launcher crash on OOS (12)
- Fixes for Pixel launcher recent crash on some customs roms(Thanks to @@saitama_96) a13
- Fully Fixed Precise location disable caused by GMS
- Google Hotword is removed for now
- Grammar checker fixed for Fr-Fr, Es-Es
- Internal Spoofing is now supported for more roms (13/12L)
- No volume key installation will be aborted if config is not placed /sdcard/Pixelify/config.prop
- Pixelify won't grant more permissions to Google play services
- Removed Installation of Offline Speech Pack from Pixelify
- Support for Pixel 7 Phones
- Updated Android System Intelligence to T19.pixel6 (13)
- Updated Live Wallpaper to v2.0 (Pokemon SideKick live wall exist too)
- More small fixes

### Version 2.1
- Support for OxygenOS & Color OS 12, 12L, 13.
- Support for Riru
- Added Bootloop saver inside Pixelify (only for Pixelify)
- Fixed Android 13 Styles and wallpaper showing 4 Colors instead of 16
- Fixed Call caption crashes in Android 13
- More Fixes for the safety net (CTS)
- Disabled Next Generation Assistant in ONEUi 4 or above due to boot loop
- Disabled Boot animation in OxygenOS 12, 12L, 13
- Updated Android System Intelligence (13) to T8.pixel6
- Updated Android System Intelligence (12) to S28.pixel6
- Fixed Google photos Unlimited backup becomes storage saver in some ROMs due to features conflict.
- Fixed Pixel Launcher not installing on some Lineage OS ROM due to an invalid security patch defined by rom
- Fixes for Precise location
- Created Pixelify Uninstaller to remove pixelify
- Enabled Universal Search in Android 13
- Enabled Unified Security & Privacy settings in Android 13
- Updated Pixel Live Wallpapers to v1.9
- Fixed Prebuilt Pixel Launcher disappeared while uninstalling Pixelify
- Added Script to generate Bootloop logs (beta) at /sdcard/Pixelify/boot_logs.txt
- Added OK Google Hotword (Android Pie to Android 13)
- Enabled Internal Spoofing for Elixir OS
- Fixed Recent Text selection in Pixel Launcher Recents
- The G logo in Gboard is made Optional
- Renamed no_vk.prop to config.prop
- Normal Pixelify.vXX.zip can now also config.prop
- Added Bootloop Saver for Pixelify
- Fixes for Grammar & Correction in Google Keyboard
- Fixes for Audio issues
- Enabled more options in At a Glance
- Improved Pixelify installation logs
- Added more Themed icons in Pixel Launcher from #TEAMFILES
- Added Styles and Wallpapers for Android 13
- Added Pixel Launcher for Android 13
- Fixes for some ROMs not showing pixel static wallpapers
- Fixed Bubble not showing in Google dialer
- Fixes for Google Text to speech
- Updated Pixel Launcher in Android 12
- Improved Battery backup from v2.02
- Added Support to disable internal spoofing of particular rom
- Many minor improvements & bug fixes

### Version 2.02
- Fixes for Quick phrase
- Option to disable internal spoofing for some rom ( might break ota | please read FAQ)
- Added optional fix for Gboard
- Fixed monet theming of notification of google dialer
- Support for monet bootanimation ( only supported rom only )
- Fixes for Pixel live wallpaper crashing
- made Google Settings service as an optional
- Fixed app search on pixel launcher
- Enabled Call caption typing
- Added option to force download online pack if internet is not detected
- Fixed Select in Pixel launcher recent on some roms
- Fixes for offline translation in Gboard
- Enabled Emoji Stickers and Emojify in Gboard
- Completely removed cts dependency on Pixelify module
- Enabled At a Store, and Doorbell extras in at a Glance.
- Improved Pixel Launcher search
- Updated Android system intelligence to pixel6.s18
- Enabled G logo in gboard
- added Google offline speech 5011 version (optional to install)
- Enabled Recents rounded corners
- more features enabled and bug fixes..

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
- Rename Device Personalization services to Android System Intelligence
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
- Enabled Google Quick Phrase
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
- Added Pixel Photos Unlimited storage backup
- Minor bug fixes 
- Extreme Battery Saver now optional.

### Version 1.5
- Fixed No Internet Connection problem on some roms.
- Fingerprint - August Security patch
- Fixes Camera Crash for some devices
- Device Personalisation is Optional
- Size of Module Reduce to 25Mb
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
- Add Next gen Assistant
- Fixed crash of GoogleDialer
- Removed Google Framework
- Added Option to backup NGA Resources
- Fixed CTS fail for some devices with Spoof 

### Beta 1.0
- Initial repo
