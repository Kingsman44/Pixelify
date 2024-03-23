package org.pixelify.spoof;

import android.os.Build;
import android.util.Log;

import org.json.JSONObject;

import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Map;

public final class EntryPoint {
    public static void init(String BRAND, String MANUFACTURER, String PRODUCT, String DEVICE, String MODEL,
            String FINGERPRINT) {
        LOG("Called to spoof by pixelify zygisk " + DEVICE + " " + MODEL + " " + FINGERPRINT);
        setPropValue("MANUFACTURER", MANUFACTURER);
        setPropValue("BRAND", BRAND);
        setPropValue("DEVICE", DEVICE);
        setPropValue("PRODUCT", PRODUCT);
        setPropValue("MODEL", MODEL);
        setPropValue("FINGERPRINT", FINGERPRINT);
        setPropValue("TAGS", "release-keys");
        setPropValue("TYPE", "user");
    }
    static void setPropValue(String key, Object value) {
        try {
            Field field = Build.class.getDeclaredField(key);
            field.setAccessible(true);
            field.set(null, value);
            field.setAccessible(false);
            LOG("Defining prop " + key + " to " + value.toString());
        } catch (NoSuchFieldException | IllegalAccessException e) {
            LOG("Failed to set prop " + key);
        }
    }
    static void LOG(String msg) {
        Log.i("Pixelify", msg);
    }
}
