#include <cstdlib>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <string>
#include <vector>
#include <android/log.h>

#include "module.h"
#include "zygisk.hpp"

using zygisk::Api;
using zygisk::AppSpecializeArgs;
using zygisk::ServerSpecializeArgs;

static std::vector<std::string> P6 = {"com.google", "com.android.vending"};
static std::vector<std::string> P5 = {"com.google.android.tts", "com.google.android.apps.wearables.maestro.companion", "com.google.android.gms", "com.nothing.smartcenter"};
static std::vector<std::string> P1 = {"com.google.android.apps.photos"};
static std::vector<std::string> PkgList = {"com.google.pixel.livewallpaper", "com.google.android.apps.subscriptions.red", "com.breel.wallpaper", "com.snapchat.android", "com.google.android.googlequicksearchbox"};
static std::vector<std::string> keep = {"com.google.android.apps.recorder", "com.google.android.GoogleCamera", "com.google.ar.core", "com.google.vr.apps.ornament", "com.google.android.apps.motionsense.bridge", "com.google.android.xx"};

bool DEBUG = true;
const char P7_FP[256] = "google/cheetah/cheetah:13/TQ2A.230305.008.C1/9619669:user/release-keys";
const char P7_BID[256] = "TQ2A.230305.008.C1";
const char P6_FP[256] = "google/raven/raven:13/TQ1A.230105.002/9325679:user/release-keys";
const char P6_BID[256] = "TQ1A.230105.002";
const char P5_FP[256] = "google/redfin/redfin:13/TQ2A.230305.008.C1/9619669:user/release-keys";
const char P5_BID[256] = "TQ2A.230305.008.C1";

jboolean (*orig_hasSystemFeature)(JNIEnv *, jobject, jstring, jint);
jboolean (*orig_hasSystemFeature_1)(JNIEnv *, jobject, jstring);

static jboolean my_has_system_feature(JNIEnv *env, jobject thiz, jstring name, jint version)
{
    if (strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2022_EXPERIENCE") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2022_MIDYEAR_EXPERIENCE") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2021_EXPERIENCE") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2021_MIDYEAR_EXPERIENCE") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2020_EXPERIENCE") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2020_MIDYEAR_EXPERIENCE") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2019_EXPERIENCE") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2019_PRELOAD") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2019_MIDYEAR_EXPERIENCE") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2018_EXPERIENCE") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2018_PRELOAD") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2017_EXPERIENCE") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2017_PRELOAD") != nullptr)
    {
        // Release the string resources
        env->ReleaseStringUTFChars(name, env->GetStringUTFChars(name, nullptr));
        // Return false if the package name and feature name match
        return JNI_FALSE;
    }
    // Release the string resources
    env->ReleaseStringUTFChars(name, env->GetStringUTFChars(name, nullptr));
    return orig_hasSystemFeature(env, thiz, name, version);
}

static jboolean my_has_system_feature_1(JNIEnv *env, jobject thiz, jstring name)
{
    if (strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2022_EXPERIENCE") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2022_MIDYEAR_EXPERIENCE") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2021_EXPERIENCE") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2021_MIDYEAR_EXPERIENCE") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2020_EXPERIENCE") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2020_MIDYEAR_EXPERIENCE") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2019_EXPERIENCE") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2019_PRELOAD") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2019_MIDYEAR_EXPERIENCE") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2018_EXPERIENCE") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2018_PRELOAD") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2017_EXPERIENCE") != nullptr ||
        strstr(env->GetStringUTFChars(name, nullptr), "PIXEL_2017_PRELOAD") != nullptr)
    {
        // Release the string resources
        env->ReleaseStringUTFChars(name, env->GetStringUTFChars(name, nullptr));
        // Return false if the package name and feature name match
        return JNI_FALSE;
    }
    // Release the string resources
    env->ReleaseStringUTFChars(name, env->GetStringUTFChars(name, nullptr));
    return orig_hasSystemFeature_1(env, thiz, name);
}

class pixelify : public zygisk::ModuleBase
{
public:
    void onLoad(Api *api, JNIEnv *env) override
    {
        this->api = api;
        this->env = env;
    }

    void patch_sys()
    {
        JNINativeMethod methods[] = {
            {"hasSystemFeature", "(Ljava/lang/String;I)Z", (void *)my_has_system_feature},
            {"hasSystemFeature", "(Ljava/lang/String;I)", (void *)my_has_system_feature_1}};
        api->hookJniNativeMethods(env, "android/app/ApplicationPackageManager", methods, 2);
        *(void **)&orig_hasSystemFeature = methods[0].fnPtr;
        *(void **)&orig_hasSystemFeature_1 = methods[1].fnPtr;
    }

    void preAppSpecialize(AppSpecializeArgs *args) override
    {
        // Use JNI to fetch our process name
        const char *process = env->GetStringUTFChars(args->nice_name, nullptr);
        preSpecialize(process);
        env->ReleaseStringUTFChars(args->nice_name, process);
    }

    void preServerSpecialize(ServerSpecializeArgs *args) override
    {
        preSpecialize("system_server");
    }

    void injectBuild(const char *package_name, const char *model1, const char *product1, const char *finger1, const char *id1)
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
        jstring brand = env->NewStringUTF("google");
        jstring manufacturer = env->NewStringUTF("Google");
        jstring finger = env->NewStringUTF(finger1);
        jstring id = env->NewStringUTF(id1);

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
        jfieldID build_id = env->GetStaticFieldID(build_class, "ID", "Ljava/lang/String;");
        if (build_id != nullptr)
        {
            env->SetStaticObjectField(build_class, build_id, id);
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

        env->DeleteLocalRef(brand);
        env->DeleteLocalRef(manufacturer);
        env->DeleteLocalRef(product);
        env->DeleteLocalRef(model);
        env->DeleteLocalRef(id);
        if (strcmp(finger1, "") != 0)
        {
            env->DeleteLocalRef(finger);
        }
    }

private:
    Api *api;
    JNIEnv *env;

    void preSpecialize(const char *process)
    {
        unsigned r = 0;
        int fd = api->connectCompanion();
        read(fd, &r, sizeof(r));
        close(fd);

        std::string package_name = process;
        int type = 0;
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
        for (auto &s : P6)
        {
            if (package_name.find(s) != std::string::npos)
            {
                type = 4;
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
        for (auto &s : keep)
        {
            if (package_name.find(s) != std::string::npos)
            {
                type = 0;
                break;
            }
        }
        // if (package_name.find("com.google.android.apps.photos") != std::string::npos)
        // {
        //     patch_sys();
        // }
        if (strcmp(process, "com.google.android.gms:unstable") == 0 || strcmp(process, "com.google.android.gms.unstable") == 0)
        {
            // injectBuild(process, "Pixel 6 Pro", "raven", "", "");
            type = 0;
        }

        if (strcmp(process, "com.google.android.apps.camera.services") == 0)
            type = 4;

        if (type == 1)
        {
            injectBuild(process, "Pixel 7 Pro", "cheetah", P7_FP, P7_BID);
        }
        else if (type == 2)
        {
            injectBuild(process, "Pixel 5", "redfin", P5_FP, P5_BID);
        }
        else if (type == 3)
        {
            injectBuild(process, "Pixel XL", "marlin", "google/marlin/marlin:10/QP1A.191005.007.A3/5972272:user/release-keys", "QP1A.191005.007");
        }
        else if (type == 4)
        {
            injectBuild(process, "Pixel 6 Pro", "raven", P6_FP, P6_BID);
        }

        api->setOption(zygisk::Option::DLCLOSE_MODULE_LIBRARY);
    }
};

static int urandom = -1;

static void companion_handler(int i)
{
    if (urandom < 0)
    {
        urandom = open("/dev/urandom", O_RDONLY);
    }
    unsigned r;
    read(urandom, &r, sizeof(r));
    LOGD("example: companion r=[%u]\n", r);
    write(i, &r, sizeof(r));
}

REGISTER_ZYGISK_MODULE(pixelify)
REGISTER_ZYGISK_COMPANION(companion_handler)