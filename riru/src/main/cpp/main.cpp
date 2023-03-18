#include <jni.h>
#include <sys/types.h>
#include <riru.h>
#include <malloc.h>
#include <cstdlib>
#include <unistd.h>
#include <string>
#include <vector>
#include <fcntl.h>
#include <stdio.h>

#include "logging.h"
#include "nativehelper/scoped_utf_chars.h"
#include "android_filesystem_config.h"

#include <sys/system_properties.h>

static std::vector<std::string> P6 = {"com.google", "com.android.vending"};
static std::vector<std::string> P5 = {"com.google.android.tts", "com.google.android.apps.wearables.maestro.companion", "com.google.android.gms", "com.nothing.smartcenter"};
static std::vector<std::string> P1 = {"com.google.android.apps.photos"};
static std::vector<std::string> PkgList = {"com.google.pixel.livewallpaper", "com.google.android.apps.subscriptions.red", "com.breel.wallpaper", "com.snapchat.android", "com.google.android.googlequicksearchbox"};
static std::vector<std::string> keep = {"com.google.android.apps.recorder", "com.google.android.GoogleCamera", "com.google.ar.core", "com.google.vr.apps.ornament", "com.google.android.apps.motionsense.bridge", "com.google.android.xx"};

bool DEBUG = false;
char* OFP = new char [1024];
char* OMODEL = new char [1024];
char* ODEVICE = new char [1024];
char* OMANU = new char [1024];
char* OBRAND = new char [1024];

void injectBuild(const char *package_name, const char *model1, const char *product1, const char *finger1, const char *brand1, const char *man1, JNIEnv *env)
{
    if (env == nullptr)
    {
        LOGW("failed to inject android.os.Build for %s due to env is null", package_name);
        return;
    }

    jclass build_class = env->FindClass("android/os/Build");
    if (build_class == nullptr)
    {
        LOGW("failed to inject android.os.Build for %s due to build is null", package_name);
        return;
    }
    else if (DEBUG)
    {
        LOGI("inject android.os.Build for %s with \nPRODUCT:%s \nMODEL:%s \nFINGERPRINT:%s", package_name, product1, model1, finger1);
    }

    jstring product = env->NewStringUTF(product1);
    jstring model = env->NewStringUTF(model1);
    jstring brand = env->NewStringUTF(brand1);
    jstring manufacturer = env->NewStringUTF(man1);
    jstring finger = env->NewStringUTF(finger1);

    if ((strcmp(model1, "") != 0) && (strcmp(model1, "") != 0))
    {
        jfieldID brand_id = env->GetStaticFieldID(build_class, "BRAND", "Ljava/lang/String;");
        if (brand_id != nullptr)
        {
            env->SetStaticObjectField(build_class, brand_id, brand);
        }

        jfieldID manufacturer_id = env->GetStaticFieldID(build_class, "MANUFACTURER", "Ljava/lang/String;");
        if (manufacturer_id != nullptr)
        {
            env->SetStaticObjectField(build_class, manufacturer_id, manufacturer);
        }

        jfieldID product_id = env->GetStaticFieldID(build_class, "PRODUCT", "Ljava/lang/String;");
        if (product_id != nullptr)
        {
            env->SetStaticObjectField(build_class, product_id, product);
        }

        jfieldID device_id = env->GetStaticFieldID(build_class, "DEVICE", "Ljava/lang/String;");
        if (device_id != nullptr)
        {
            env->SetStaticObjectField(build_class, device_id, product);
        }

        jfieldID model_id = env->GetStaticFieldID(build_class, "MODEL", "Ljava/lang/String;");
        if (model_id != nullptr)
        {
            env->SetStaticObjectField(build_class, model_id, model);
        }
    }
    if (strcmp(finger1, "") != 0)
    {
        jfieldID finger_id = env->GetStaticFieldID(build_class, "FINGERPRINT", "Ljava/lang/String;");
        if (finger_id != nullptr)
        {
            env->SetStaticObjectField(build_class, finger_id, finger);
        }
    }

    if (env->ExceptionCheck())
    {
        env->ExceptionClear();
    }
    if ((strcmp(model1, "") != 0) && (strcmp(model1, "") != 0))
    {
        env->DeleteLocalRef(brand);
        env->DeleteLocalRef(manufacturer);
        env->DeleteLocalRef(product);
        env->DeleteLocalRef(model);
    }
    if (strcmp(finger1, "") != 0)
    {
        env->DeleteLocalRef(finger);
    }
}

static void preSpecialize(const char *process, JNIEnv *env)
{
    std::string package_name = process;
    int type = 0;
    
    __system_property_get("ro.build.fingerprint", OFP);
    __system_property_get("ro.product.model", OMODEL);
    __system_property_get("ro.product.device", ODEVICE);
    __system_property_get("ro.product.manufacturer", OMANU);
    __system_property_get("ro.build.brand", OBRAND);
    
    for (auto &s : PkgList)
    {
        if (package_name.find(s) != std::string::npos)
        {
            type = 1;
            break;
        }
    }
    for (auto &s : P5)
    {
        if (package_name.find(s) != std::string::npos)
        {
            type = 2;
            break;
        }
    }
    for (auto &s : P1)
    {
        if (package_name.find(s) != std::string::npos)
        {
            type = 3;
            break;
        }
    }
    for (auto &s : P6)
    {
        if (package_name.find(s) != std::string::npos)
        {
            type = 3;
            break;
        }
    }
    for (auto &s : keep)
    {
        if (package_name.find(s) != std::string::npos)
        {
            type = 0;
            break;
        }
    }

    if (strcmp(process, "com.google.android.gms:unstable") == 0 || strcmp(process, "com.google.android.gms.unstable") == 0)
    {
        //injectBuild(process, "", "", "google/marlin/marlin:7.1.2/NJH47F/4146041:user/release-keys","","", env);
        type = 0;
    }

    if (strcmp(process, "com.google.android.apps.camera.services") == 0) {
        type = 1;
    }

    if (type == 1)
    {
        injectBuild(process, "Pixel 7 Pro", "cheetah", "google/cheetah/cheetah:13/TQ2A.230305.008.C1/9619669:user/release-keys","google","Google", env);
    }
    else if (type == 2)
    {
        injectBuild(process, "Pixel 5", "raven", "google/redfin/redfin:13/TQ2A.230305.008.C1/9619669:user/release-keys","google","Google", env);
    }
    else if (type == 4)
    {
        injectBuild(process, "Pixel 6 Pro", "raven", "google/cheetah/cheetah:13/TQ2A.230305.008.C1/9619669:user/release-keys","google","Google", env);
    }
    else if (type == 3)
    {
        injectBuild(process, "Pixel XL", "marlin", "google/marlin/marlin:10/QP1A.191005.007.A3/5972272:user/release-keys","google","Google", env);
    } 
    else
    {
        injectBuild(process, OMODEL, ODEVICE, OFP, OBRAND, OMANU, env); 
    }
}

static void forkAndSpecializePre(
    JNIEnv *env, jclass clazz, jint *uid, jint *gid, jintArray *gids, jint *runtimeFlags,
    jobjectArray *rlimits, jint *mountExternal, jstring *seInfo, jstring *niceName,
    jintArray *fdsToClose, jintArray *fdsToIgnore, jboolean *is_child_zygote,
    jstring *instructionSet, jstring *appDataDir, jboolean *isTopApp, jobjectArray *pkgDataInfoList,
    jobjectArray *whitelistedDataInfoList, jboolean *bindMountAppDataDirs, jboolean *bindMountAppStorageDirs)
{
    ScopedUtfChars process(env, *niceName);
    char processName[1024];
    sprintf(processName, "%s", process.c_str());
    preSpecialize(processName, env);
}

static void forkAndSpecializePost(JNIEnv *env, jclass clazz, jint res)
{
    if (res == 0)
    {
        riru_set_unload_allowed(true);
    }
}

static void specializeAppProcessPre(
    JNIEnv *env, jclass clazz, jint *uid, jint *gid, jintArray *gids, jint *runtimeFlags,
    jobjectArray *rlimits, jint *mountExternal, jstring *seInfo, jstring *niceName,
    jboolean *startChildZygote, jstring *instructionSet, jstring *appDataDir,
    jboolean *isTopApp, jobjectArray *pkgDataInfoList, jobjectArray *whitelistedDataInfoList,
    jboolean *bindMountAppDataDirs, jboolean *bindMountAppStorageDirs)
{
    ScopedUtfChars process(env, *niceName);
    char processName[1024];
    sprintf(processName, "%s", process.c_str());
    preSpecialize(processName, env);
}

static void specializeAppProcessPost(JNIEnv *env, jclass clazz)
{
    riru_set_unload_allowed(true);
}

extern "C"
{

    int riru_api_version;
    const char *riru_magisk_module_path = nullptr;
    int *riru_allow_unload = nullptr;

    static auto module = RiruVersionedModuleInfo{
        .moduleApiVersion = RIRU_MODULE_API_VERSION,
        .moduleInfo = RiruModuleInfo{
            .supportHide = true,
            .version = RIRU_MODULE_VERSION,
            .versionName = RIRU_MODULE_VERSION_NAME,
            .onModuleLoaded = nullptr,
            .forkAndSpecializePre = forkAndSpecializePre,
            .forkAndSpecializePost = forkAndSpecializePost,
            .forkSystemServerPre = nullptr,
            .forkSystemServerPost = nullptr,
            .specializeAppProcessPre = specializeAppProcessPre,
            .specializeAppProcessPost = specializeAppProcessPost}};

#ifndef RIRU_MODULE_LEGACY_INIT
    RiruVersionedModuleInfo *init(Riru *riru)
    {
        auto core_max_api_version = riru->riruApiVersion;
        riru_api_version = core_max_api_version <= RIRU_MODULE_API_VERSION ? core_max_api_version : RIRU_MODULE_API_VERSION;
        module.moduleApiVersion = riru_api_version;

        riru_magisk_module_path = strdup(riru->magiskModulePath);
        if (riru_api_version >= 25)
        {
            riru_allow_unload = riru->allowUnload;
        }
        return &module;
    }
#else
    RiruVersionedModuleInfo *init(Riru *riru)
    {
        static int step = 0;
        step += 1;

        switch (step)
        {
        case 1:
        {
            auto core_max_api_version = riru->riruApiVersion;
            riru_api_version = core_max_api_version <= RIRU_MODULE_API_VERSION ? core_max_api_version : RIRU_MODULE_API_VERSION;
            if (riru_api_version < 25)
            {
                module.moduleInfo.unused = (void *)shouldSkipUid;
            }
            else
            {
                riru_allow_unload = riru->allowUnload;
            }
            if (riru_api_version >= 24)
            {
                module.moduleApiVersion = riru_api_version;
                riru_magisk_module_path = strdup(riru->magiskModulePath);
                return &module;
            }
            else
            {
                return (RiruVersionedModuleInfo *)&riru_api_version;
            }
        }
        case 2:
        {
            return (RiruVersionedModuleInfo *)&module.moduleInfo;
        }
        case 3:
        default:
        {
            return nullptr;
        }
        }
    }
#endif
}
