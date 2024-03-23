#include <cstdlib>
#include <unistd.h>
#include <fcntl.h>
#include <string>
#include <vector>
#include <android/log.h>
// #include <chrono>
#include "module.h"
#include "zygisk.hpp"

using zygisk::Api;
using zygisk::AppSpecializeArgs;
using zygisk::ServerSpecializeArgs;

#define CLASSES_DEX "/data/adb/modules/Pixelify/classes.dex"

// Spoofing apps
static std::vector<std::string> P1 = {"com.google.android.apps.photos"};
static std::vector<std::string> P5 = {"com.google", "com.google.android.dialer", "com.google.android.tts", "com.google.android.apps.wearables.maestro.companion", "com.nothing.smartcenter", "com.netflix.mediaclient", "com.google.process.gapps", "com.google.process.gservices"};
static std::vector<std::string> P6 = {};
static std::vector<std::string> P7 = {};
static std::vector<std::string> P8 = {"com.google.android.gms","com.android.vending", "com.google.android.aicore", "com.google.pixel.livewallpaper", "com.google.android.apps.subscriptions.red", "com.snapchat.android", "com.google.android.googlequicksearchbox", "com.adobe.lrmobile", "com.google.android.apps.recorder", "com.google.android.wallpaper.effects", "com.google.android.apps.customization.pixel"};
static std::vector<std::string> PFold = {"com.google.android.apps.subscriptions.red"};
static std::vector<std::string> S23U = {"com.samsung."};
static std::vector<std::string> keep = {"com.google.vr.apps.ornament", "com.google.android.apps.nexuslauncher", "com.google.android.apps.pixelmigrate", "com.google.android.apps.restore", "com.google.android.apps.tachyon", "com.google.android.apps.tycho", "com.google.android.euicc", "com.google.oslo", "com.google.ar.core", "com.google.android.apps.recorder", "com.google.android.GoogleCamera", "com.google.android.apps.motionsense.bridge", "com.google.android.gms.chimera", "com.google.android.gms.update", "com.android.camera", "com.google.android.xx", "com.google.android.googlequicksearchbox:HotwordDetectionService", "com.google.android.apps.mesagging:rcs", "com.google.android.googlequicksearchbox:trusted:com.google.android.apps.gsa.hotword.hotworddetectionservice.GsaHotwordDetectionService", "com.google.android.gms.unstable"};

// Fingerprint
const char P1_FP[256] = "google/marlin/marlin:10/QP1A.191005.007.A3/5972272:user/release-keys";
const char P5_FP[256] = "google/redfin/redfin:13/TQ2A.230305.008.C1/9619669:user/release-keys";
const char P6_FP[256] = "google/raven/raven:13/TQ1A.230105.002/9325679:user/release-keys";
const char P7_FP[256] = "google/husky/husky:14/UD1A.230803.022.A3/10714844:user/release-keys";
const char P2_FP[256] = "google/walleye/walleye:8.1.0/OPM1.171019.011/4448085:user/release-keys";
const char PF_FP[256] = "google/felix/felix:13/TD3A.230203.070.A1/10075871:user/release-keys";
const char P8_FP[256] = "google/husky/husky:14/AP1A.240305.019.A1/11445699:user/release-keys";
const char S23U_FP[256] = "samsung/dm3qxxx/qssi:14/UP1A.231005.007/S918BXXS3BXBD:user/release-keys";

// Classes.dex Inject packages
static std::vector<std::string> InjectPackages = {"com.google.android.gms", "com.google.android.apps.photos", "com.google.android.googlequicksearchbox", "com.android.vending"};

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
        const char *process = env->GetStringUTFChars(args->nice_name, nullptr);
        spoof_type = getSpoof(process);
        package_name = process;
        shouldinjectdex = false;
        if (RequiresInject(package_name))
        {
            long dexSize = 0;
            int fd = api->connectCompanion();
            read(fd, &dexSize, sizeof(long));
            LOGI("Dex file size: %ld", dexSize);
            if (dexSize > 0)
            {
                dexVector.resize(dexSize);
                read(fd, dexVector.data(), dexSize);
                shouldinjectdex = true;
            }
        }
    }
    void postAppSpecialize(const AppSpecializeArgs *) override
    {
        jclass build_class = env->FindClass("android/os/Build");
        if (!spoof_type)
        {
            api->setOption(zygisk::DLCLOSE_MODULE_LIBRARY);
            return;
        }
        std::string BRAND = "";
        std::string MANUFACTURER = "";
        std::string PRODUCT = "";
        std::string DEVICE = "";
        std::string MODEL = "";
        std::string TAGS = "";
        std::string TYPE = "";
        std::string FINGERPRINT = "";
        switch (spoof_type)
        {
        case 1:
            BRAND = "google";
            MANUFACTURER = "Google";
            PRODUCT = "marlin";
            DEVICE = "marlin";
            MODEL = "Pixel XL";
            FINGERPRINT = P1_FP;
            break;
        case 2:
            BRAND = "google";
            MANUFACTURER = "Google";
            PRODUCT = "walleye";
            DEVICE = "walleye";
            MODEL = "Pixel 2";
            FINGERPRINT = P2_FP;
            break;
        case 3:
            BRAND = "google";
            MANUFACTURER = "Google";
            PRODUCT = "redfin";
            DEVICE = "redfin";
            MODEL = "Pixel 5";
            FINGERPRINT = P5_FP;
            break;
        case 4:
            BRAND = "google";
            MANUFACTURER = "Google";
            PRODUCT = "raven";
            DEVICE = "raven";
            MODEL = "Pixel 6 Pro";
            FINGERPRINT = P6_FP;
            break;
        case 5:
            BRAND = "google";
            MANUFACTURER = "Google";
            PRODUCT = "cheetah";
            DEVICE = "cheetah";
            MODEL = "Pixel 7 Pro";
            FINGERPRINT = P7_FP;
            break;
        case 6:
            BRAND = "google";
            MANUFACTURER = "Google";
            PRODUCT = "felix";
            DEVICE = "felix";
            MODEL = "Pixel Fold";
            FINGERPRINT = PF_FP;
            break;
        case 7:
            BRAND = "google";
            MANUFACTURER = "Google";
            PRODUCT = "husky";
            DEVICE = "husky";
            MODEL = "Pixel 8 Pro";
            FINGERPRINT = P8_FP;
            break;
        case 8:
            BRAND = "samsung";
            MANUFACTURER = "samsung";
            PRODUCT = "dm3qxxx";
            DEVICE = "qssi";
            MODEL = "SM-S918B";
            FINGERPRINT = S23U_FP;
            break;
        default:
            api->setOption(zygisk::DLCLOSE_MODULE_LIBRARY);
            return;
            break;
        }
        injectValue(build_class, "BRAND", BRAND);
        injectValue(build_class, "MANUFACTURER", MANUFACTURER);
        injectValue(build_class, "PRODUCT", PRODUCT);
        injectValue(build_class, "DEVICE", DEVICE);
        injectValue(build_class, "MODEL", MODEL);
        injectValue(build_class, "TAGS", "release-keys");
        injectValue(build_class, "TYPE", "user");
        injectValue(build_class, "FINGERPRINT", FINGERPRINT);
        if (shouldinjectdex)
        {
            // From PlayIntregrity fix
            LOGI("Injecting Dex in package %s",package_name.c_str());
            if(dexVector.empty()) {
                LOGE("Couldn't load Dex file to inject spoof");
            }
            LOGI("get system classloader for package %s",package_name.c_str());
            auto clClass = env->FindClass("java/lang/ClassLoader");
            auto getSystemClassLoader = env->GetStaticMethodID(clClass, "getSystemClassLoader",
                                                               "()Ljava/lang/ClassLoader;");
            auto systemClassLoader = env->CallStaticObjectMethod(clClass, getSystemClassLoader);

            LOGI("create class loader");
            auto dexClClass = env->FindClass("dalvik/system/InMemoryDexClassLoader");
            auto dexClInit = env->GetMethodID(dexClClass, "<init>",
                                              "(Ljava/nio/ByteBuffer;Ljava/lang/ClassLoader;)V");
            auto buffer = env->NewDirectByteBuffer(dexVector.data(), dexVector.size());
            auto dexCl = env->NewObject(dexClClass, dexClInit, buffer, systemClassLoader);

            LOGI("load class");
            auto loadClass = env->GetMethodID(clClass, "loadClass",
                                              "(Ljava/lang/String;)Ljava/lang/Class;");
            auto entryClassName = env->NewStringUTF("org.pixelify.spoof.EntryPoint");
            auto entryClassObj = env->CallObjectMethod(dexCl, loadClass, entryClassName);

            auto entryPointClass = (jclass)entryClassObj;

            LOGI("call init");
            auto entryInit = env->GetStaticMethodID(entryPointClass, "init", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
            auto str1 = env->NewStringUTF(BRAND.c_str());
            auto str2 = env->NewStringUTF(MANUFACTURER.c_str());
            auto str3 = env->NewStringUTF(PRODUCT.c_str());
            auto str4 = env->NewStringUTF(DEVICE.c_str());
            auto str5 = env->NewStringUTF(MODEL.c_str());
            auto str6 = env->NewStringUTF(FINGERPRINT.c_str());
            env->CallStaticVoidMethod(entryPointClass, entryInit, str1, str2, str3, str4, str5, str6);
            return;
        }
        api->setOption(zygisk::DLCLOSE_MODULE_LIBRARY);
    }
    void preServerSpecialize(zygisk::ServerSpecializeArgs *args) override
    {
        api->setOption(zygisk::DLCLOSE_MODULE_LIBRARY);
    }

private:
    Api *api;
    JNIEnv *env;
    std::vector<uint8_t> dexVector;
    bool shouldinjectdex = false;
    std::string package_name;
    int spoof_type;

    void injectValue(jclass build_class, const char *field, std::string value)
    {
        if (env == nullptr)
        {
            LOGW("failed to inject %s for %s due to env is null", field, package_name.c_str());
            return;
        }

        if (build_class == nullptr)
        {
            LOGW("failed to inject %s for %s due to build is null", field, package_name.c_str());
            return;
        }
        LOGI("process=%s %s -> %s", package_name.c_str(), field, value.c_str());

        jstring inc = env->NewStringUTF(value.c_str());

        jfieldID inc_id = env->GetStaticFieldID(build_class, field, "Ljava/lang/String;");
        if (inc_id != nullptr)
        {
            env->SetStaticObjectField(build_class, inc_id, inc);
        }

        if (env->ExceptionCheck())
        {
            env->ExceptionClear();
        }
        env->DeleteLocalRef(inc);
    }
    void injectValue(jclass build_class, const char *field, const int value)
    {
        if (env == nullptr)
        {
            LOGW("failed to inject %s for %s due to env is null", field, package_name.c_str());
            return;
        }
        if (build_class == nullptr)
        {
            LOGW("failed to inject %s for %s due to build is null", field, package_name.c_str());
            return;
        }
        LOGI("process=%s %s -> %d", package_name.c_str(), field, value);
        jint inc = (jint)value;

        jfieldID inc_id = env->GetStaticFieldID(build_class, field, "I");
        if (inc_id != nullptr)
        {
            env->SetStaticIntField(build_class, inc_id, inc);
        }

        if (env->ExceptionCheck())
        {
            env->ExceptionClear();
        }
    }
    void injectValue(jclass build_class, const char *field, const long value)
    {
        if (env == nullptr)
        {
            LOGW("failed to inject android.os.Build for %s due to env is null", package_name.c_str());
            return;
        }
        if (build_class == nullptr)
        {
            LOGW("failed to inject %s for %s due to build is null", field, package_name.c_str());
            return;
        }
        LOGI("process=%s %s -> %ld", package_name.c_str(), field, value);
        jlong inc = (jlong)value;

        jfieldID inc_id = env->GetStaticFieldID(build_class, field, "J");
        if (inc_id != nullptr)
        {
            env->SetStaticIntField(build_class, inc_id, inc);
        }

        if (env->ExceptionCheck())
        {
            env->ExceptionClear();
        }
    }
    int getSpoof(std::string package)
    {
        if (package == "com.google.android.gms.unstable")
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
        for (auto &s : P8)
        {
            if (package.find(s) != std::string::npos)
                return 7;
        }
        for (auto &s : P7)
        {
            if (package.find(s) != std::string::npos)
                return 5;
        }
        for (auto &s : PFold)
        {
            if (package.find(s) != std::string::npos)
                return 6;
        }
        for (auto &s : P6)
        {
            if (package.find(s) != std::string::npos)
                return 4;
        }
        for (auto &s : S23U)
        {
            if (package.find(s) != std::string::npos)
                return 8;
        }
        for (auto &s : P5)
        {
            if (package.find(s) != std::string::npos)
                return 3;
        }
        return 0;
    }
    bool RequiresInject(std::string package)
    {
        for (auto &s : InjectPackages)
        {
            if (package.find(s) != std::string::npos)
                return true;
        }
        return false;
    }
};

// Taken from PlayIntregrity Fix
static std::vector<uint8_t> readFile(const char *path)
{

    std::vector<uint8_t> vector;

    FILE *file = fopen(path, "rb");

    if (file)
    {
        fseek(file, 0, SEEK_END);
        long size = ftell(file);
        fseek(file, 0, SEEK_SET);

        vector.resize(size);
        fread(vector.data(), 1, size, file);
        fclose(file);
    }
    else
    {
        LOGI("Couldn't read %s file!", path);
    }

    return vector;
}

static void companion(int fd)
{
    std::vector<uint8_t> dexVector;
    dexVector = readFile(CLASSES_DEX);
    long dexSize = dexVector.size();
    write(fd, &dexSize, sizeof(long));
    write(fd, dexVector.data(), dexSize);
}

REGISTER_ZYGISK_MODULE(pixelify)
REGISTER_ZYGISK_COMPANION(companion)