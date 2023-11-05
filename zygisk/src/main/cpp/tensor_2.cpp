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
static std::vector<std::string> P1 = {"com.google.android.apps.photos"};
static std::vector<std::string> P5 = {"com.google.android.gms"};
static std::vector<std::string> keep = {"com.google.android.gms.chimera", "com.google.android.gms.update","com.google.android.gms.unstable"};

// Fingerprint
const char P1_FP[256] = "google/marlin/marlin:10/QP1A.191005.007.A3/5972272:user/release-keys";
const char P5_FP[256] = "google/redfin/redfin:13/TQ2A.230305.008.C1/9619669:user/release-keys";

bool DEBUG = true;
char package_name[256];
static int spoof_type;

class pixelify_photos : public zygisk::ModuleBase
{
public:
    void onLoad(Api *api, JNIEnv *env) override
    {
        this->api = api;
        this->env = env;
    }
    void preAppSpecialize(AppSpecializeArgs *args) override
    {
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
            injectversion(34);
            break;
        case 2:
            injectBuild("Pixel 5", "redfin", P5_FP);
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
        jstring tag = env->NewStringUTF("release-keys");
        jstring type = env->NewStringUTF("user");

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
        jfieldID tag_id = env->GetStaticFieldID(build_class, "TAGS", "Ljava/lang/String;");
        if (tag_id != nullptr)
        {
            env->SetStaticObjectField(build_class, tag_id, tag);
        }
        jfieldID type_id = env->GetStaticFieldID(build_class, "TYPE", "Ljava/lang/String;");
        if (type_id != nullptr)
        {
            env->SetStaticObjectField(build_class, type_id, type);
        }
        jfieldID finger_id = env->GetStaticFieldID(build_class, "FINGERPRINT", "Ljava/lang/String;");
        if (finger_id != nullptr)
        {
            env->SetStaticObjectField(build_class, finger_id, finger);
        }

        if (env->ExceptionCheck())
        {
            env->ExceptionClear();
        }

        env->DeleteLocalRef(brand);
        env->DeleteLocalRef(manufacturer);
        env->DeleteLocalRef(product);
        env->DeleteLocalRef(model);
        env->DeleteLocalRef(type);
        env->DeleteLocalRef(tag);
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
    int getSpoof(const char *process)
    {
        std::string package = process;
        if (strcmp(process, "com.google.android.gms.unstable") == 0)
            return 0;

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
        return 0;
    }
};

REGISTER_ZYGISK_MODULE(pixelify_photos)