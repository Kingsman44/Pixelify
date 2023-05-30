#include <cstdlib>
#include <unistd.h>
#include <fcntl.h>
#include <string>
#include <vector>
#include <android/log.h>

#include "module.h"
#include "zygisk.hpp"

using zygisk::Api;
using zygisk::AppSpecializeArgs;
using zygisk::ServerSpecializeArgs;

// Spoofing apps
static std::vector<std::string> P1 = {"com.google.android.apps.photos", "com.google.ar.core", "com.google.vr.apps.ornament"};
static std::vector<std::string> P5 = {"com.google.android.tts", "com.google.android.apps.wearables.maestro.companion", "com.nothing.smartcenter","com.google.android.googlequicksearchbox:interactor"};
static std::vector<std::string> P6 = {"com.google"};
static std::vector<std::string> P7 = {"com.google.pixel.livewallpaper", "com.google.android.apps.subscriptions.red", "com.breel.wallpaper", "com.snapchat.android", "com.google.android.gms", "com.google.android.googlequicksearchbox","com.google.process.gapps","com.google.process.gservices"};
static std::vector<std::string> PFold = {"com.google.android.apps.subscriptions.red"};
static std::vector<std::string> keep = {"com.google.android.apps.recorder", "com.google.android.GoogleCamera", "com.google.android.apps.motionsense.bridge", "com.google.android.gms.chimera", "com.google.android.gms.update", "com.android.camera", "com.google.android.xx", "com.google.android.googlequicksearchbox:HotwordDetectionService","com.google.android.as:nonpersistent","com.google.android.apps.mesagging:rcs","com.google.android.googlequicksearchbox:assistant"};

// Fingerprint
const char P1_FP[256] = "google/marlin/marlin:10/QP1A.191005.007.A3/5972272:user/release-keys";
const char P5_FP[256] = "google/redfin/redfin:13/TQ2A.230305.008.C1/9619669:user/release-keys";
const char P6_FP[256] = "google/raven/raven:13/TQ1A.230105.002/9325679:user/release-keys";
const char P7_FP[256] = "google/cheetah/cheetah:13/TQ2A.230305.008.C1/9619669:user/release-keys";

bool DEBUG = true;
char package_name[256];
static int spoof_type;

// Changed by magisk module
const char INTERNAL_SPOOFING[256] = "INTERNAL_SPOOFING_NOT_SUPPORTED";

class pixelify : public zygisk::ModuleBase
{
public:
    void onLoad(Api *api, JNIEnv *env) override
    {
        this->api = api;
        this->env = env;
    }
    void preAppSpecialize(AppSpecializeArgs *args) override
    {
        // Use JNI to fetch our process name
        const char *process = env->GetStringUTFChars(args->nice_name, nullptr);
        spoof_type = getSpoof(process);
        strcpy(package_name, process);
        env->ReleaseStringUTFChars(args->nice_name, process);
    }
    void postAppSpecialize(const AppSpecializeArgs *) override
    {
        switch (spoof_type)
        {
        case 1:
            injectBuild("Pixel XL", "marlin", P1_FP);
            //Register_Has_system_feature();
            break;
        case 2:
            injectBuild("Pixel 5", "redfin", P5_FP);
            break;
        case 3:
            injectBuild("Pixel 6 Pro", "raven", P6_FP);
            break;
        case 4:
            injectBuild("Pixel 7 Pro", "cheetah", P7_FP);
            break;
        case 5:
            injectBuild("Pixel XL", "marlin", P1_FP);
            // N_MR1 (7.1.2) SDK Version is 25
            injectversion(25);
            break;
        case 6:
            injectBuild("Pixel Fold", "felix", P7_FP);
            break;
        case 7:
            if (strcmp(INTERNAL_SPOOFING, "INTERNAL_SPOOFING_SUPPORTED") == 0)
            {
                disablespoofinghack();
            }
            break;
        default:
            break;
        }
    }

private:
    Api *api;
    JNIEnv *env;

    void injectBuild(const char *model1, const char *product1, const char *finger1)
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
        env->DeleteLocalRef(finger);
    }
    void injectversion(const int inc_c)
    {
        if (env == nullptr)
        {
            LOGW("failed to inject android.os.Build for %s due to env is null", package_name);
            return;
        }

        jclass build_class = env->FindClass("android/os/Build$VERSION");
        if (build_class == nullptr)
        {
            LOGW("failed to inject android.os.Build.VERSION for %s due to build is null", package_name);
            return;
        }

        jint inc = (jint)inc_c;

        jfieldID inc_id = env->GetStaticFieldID(build_class, "DEVICE_INITIAL_SDK_INT", "I");
        if (inc_id != nullptr)
        {
            env->SetStaticIntField(build_class, inc_id, inc);
        }

        if (env->ExceptionCheck())
        {
            env->ExceptionClear();
        }
    }
    void disablespoofinghack()
    {
        if (env == nullptr)
        {
            LOGW("failed to inject android.os.Build for %s due to env is null", package_name);
            return;
        }
        jclass pixel_prop_class = env->FindClass("com/android/internal/util/custom/PixelPropsUtils");
        if (pixel_prop_class == nullptr)
        {
            LOGW("failed to inject PixelPropUtils for %s due to build is null", package_name);
            return;
        }
        jstring pixelify = env->NewStringUTF("ro.pixelify.device");
        jfieldID device_id = env->GetStaticFieldID(pixel_prop_class, "DEVICE", "Ljava/lang/String;");
        if (device_id != nullptr)
        {
            env->SetStaticObjectField(pixel_prop_class, device_id, pixelify);
        }
        env->DeleteLocalRef(pixelify);
    }
    int getSpoof(const char *process)
    {
        std::string package = process;
        if (strcmp(process, "com.google.android.gms.unstable") == 0)
            return 5;
        else if (strcmp(process, "system_server") == 0)
            return 7;

        for (auto &s : keep)
        {
            if (package.find(s) != std::string::npos)
                return 0;
        }
        for (auto &s : P1)
        {
            if (package.find(s) != std::string::npos)
                return 1;
        }
        for (auto &s : P5)
        {
            if (package.find(s) != std::string::npos)
                return 2;
        }
        for (auto &s : P7)
        {
            if (package.find(s) != std::string::npos)
                return 4;
        }
        for (auto &s : PFold)
        {
            if (package.find(s) != std::string::npos)
                return 6;
        }
        for (auto &s : P6)
        {
            if (package.find(s) != std::string::npos)
                return 3;
        }
        return 0;
    }
};

REGISTER_ZYGISK_MODULE(pixelify)