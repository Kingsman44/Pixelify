# PIXELIFY MAGISK MODULE
Enables Pixel Ui and Some Exclusive Features.<br>

### Please Read [this](https://github.com/Kingsman44/magisk_module_pixelify#-how-to-enable-features) before installing

## ⭐ Requirements
- **Arm64 device**
- **Volume Keys**

## ⭐ Features
-   Adaptive Charging (Google SystemUI)
-   Adaptive Sound (11+)
-   Enables Google Dialer install via Playstore
-   Enables Google Dialer's Call Screening (9+)
-   Enables Nexus, Pixel, and Android One app support
-   Google Duo features
-   Google Fit Heart rate (needed reboot if installed after module installtion)
-   Google Fit Respiratory rate (needed reboot if installed after module installtion)
-   Google GBoard New Design
-   Google Gboard Assistant Mic (If Preinstalled & NGA installed)
-   Google Gboard Lens support
-   Google Sans Font
-   Live captions (11+)
-   Next Generation Assistant (10+)(Optional)
-   Now Playing Export (Works only on Pixel Phone)
-   Pixel 5 spoof (Optional)
-   Pixel Blue theme accent
-   Pixel bootanimation (Optional)
-   Portrait Light (10+)
-   Screen Attention Service
-   Shareable Google Recorder

## ⭐ How to Enable Features

### 1) Google Next Generation Assistant
- **Installation**:- Needed to select 'YES' to pixel Spoof , Install NGA RESOURCES in Installation.<br>
- **How to Enable**:- After installation reboot your phone, then while open assistant you will get prompt to download additional resources, download it and **reboot** your phone<br>
- **Note**:- Incase Assistant Ui is gone, just Reboot your Phone.<br>

### 2.1) Call Screening Latest with all Features [ US only ] [ Beta ]
- **Installation**:- Needed to select 'YES' to pixel Spoof, If Dialer Preinstalled (As SystemApp) No need to Install Dialer from module <br>
- **Note**:- Incase Call Screening is gone, just Reboot your Phone.<br> 

### 2.2) Call Screening V1 [ Available to all regions ]
- **Installation**:- Needed to Install Dialer from module <br>
- **How to Enable**:- After installation reboot your phone, , Open Dialer wait 4-5 Min, Then reboot your Phone<br>
- **Note**:- 1) Do not Update Dialer
<br>2) Incase Call Screening is gone, just Reboot your Phone.<br>

### 3) Portrait Light
- **Note**:- You might Get directly, if didn't then clear data, open photos and wait for some time.<br>

## ⭐ Bugs and Fixes
- **Call Screening**: caller can't hear your voice.<br>
**Fix commit (Audio Hal v6):** https://github.com/PotterLab/arrow_device_motorola_potter/pull/1/commits/049dfa580bae0ed0dd47cf9c4acb2df410e119df
- **Call Screening**: can't able to download call screening files.<br>
**Fix:** Set WIFI to unmetered connection. <br>
- **Google**: Ok Google doesn't work without hotword.<br>

## ⭐ Credits
- [Kdrag0n](https://github.com/kdrag0n) for SimpleDeviceConfig
- [Freak07](https://forum.xda-developers.com/m/freak07.3428502/) for Adaptive Sound
- [thehappydinoa](https://github.com/thehappydinoa) for Initial Call Screening

## ⭐ ChangeLogs
### Beta 1.0
- Initial repo

### Version Beta 1.1
- Add Next gen Assitant
- Fixed crash of GoogleDialer
- Removed Google Framework
- Added Option to backup NGA Resources
- Fixed CTS fail for some devices with Spoof 

### Version Beta 1.2
- Fixed NGA Mic
- Added Settings Overlay for Screen Attention and Adaptive Charging
- Update Permissions for Dialer and DevicePersonalisation
- Fixed NGA on Roms using PropUtils

### Version Beta 1.3
- Fixed Installation stuck on NGA resources
- Some Minor Fixes
- Fixed velvet (if non system app) is gone after unistall

