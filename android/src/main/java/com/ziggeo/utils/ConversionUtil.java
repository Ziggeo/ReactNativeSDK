package com.ziggeo.utils;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableType;
import com.ziggeo.androidsdk.CacheConfig;
import com.ziggeo.androidsdk.net.uploading.UploadingConfig;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * Helper utilities to convert from react-native types to POJOs
 */
public final class ConversionUtil {
    /**
     * toObject extracts a value from a {@link ReadableMap} by its key,
     * and returns a POJO representing that object.
     *
     * @param readableMap The Map to containing the value to be converted
     * @param key         The key for the value to be converted
     * @return The converted POJO
     */
    public static String toObject(@Nullable ReadableMap readableMap, String key) {
        if (readableMap == null) {
            return null;
        }

        Object result;

        ReadableType readableType = readableMap.getType(key);
        switch (readableType) {
            case Null:
                result = null;
                break;
            case Boolean:
                result = readableMap.getBoolean(key);
                break;
            case Number:
                // Can be int or double.
                double tmp = readableMap.getDouble(key);
                if (tmp == (int) tmp) {
                    result = (int) tmp;
                } else {
                    result = tmp;
                }
                break;
            case String:
                result = readableMap.getString(key);
                break;
            default:
                throw new IllegalArgumentException("Could not convert object with key: " + key + ".");
        }

        return String.valueOf(result);
    }

    /**
     * toMap converts a {@link ReadableMap} into a HashMap.
     *
     * @param readableMap The ReadableMap to be conveted.
     * @return A HashMap containing the data that was in the ReadableMap.
     */
    @Nullable
    public static HashMap<String, String> toMap(@Nullable ReadableMap readableMap) {
        if (readableMap == null) {
            return null;
        }

        com.facebook.react.bridge.ReadableMapKeySetIterator iterator = readableMap.keySetIterator();
        if (!iterator.hasNextKey()) {
            return null;
        }

        HashMap<String, String> result = new HashMap<>();
        while (iterator.hasNextKey()) {
            String key = iterator.nextKey();
            result.put(key, toObject(readableMap, key));
        }

        return result;
    }

    /**
     * toList converts a {@link ReadableArray} into an ArrayList.
     *
     * @param readableArray The ReadableArray to be conveted.
     * @return An ArrayList containing the data that was in the ReadableArray.
     */
    public static List<Object> toList(@Nullable ReadableArray readableArray) {
        if (readableArray == null) {
            return null;
        }

        List<Object> result = new ArrayList<>(readableArray.size());
        for (int index = 0; index < readableArray.size(); index++) {
            ReadableType readableType = readableArray.getType(index);
            switch (readableType) {
                case Null:
                    result.add(String.valueOf(index));
                    break;
                case Boolean:
                    result.add(readableArray.getBoolean(index));
                    break;
                case Number:
                    // Can be int or double.
                    double tmp = readableArray.getDouble(index);
                    if (tmp == (int) tmp) {
                        result.add((int) tmp);
                    } else {
                        result.add(tmp);
                    }
                    break;
                case String:
                    result.add(readableArray.getString(index));
                    break;
                case Map:
                    result.add(toMap(readableArray.getMap(index)));
                    break;
                case Array:
                    result = toList(readableArray.getArray(index));
                    break;
                default:
                    throw new IllegalArgumentException("Could not convert object with index: " + index + ".");
            }
        }

        return result;
    }

    public static CacheConfig dataToCacheConfig(@NonNull ReadableMap data, @NonNull Context context) {
        final String cacheSize = "cache_size";
        final String cacheRoot = "cache_root";

        CacheConfig.Builder builder = new CacheConfig.Builder(context);
        if (data.hasKey(cacheRoot)) {
            builder.cacheDirectory(new File(data.getString(cacheRoot)));
        }
        if (data.hasKey(cacheSize)) {
            builder.maxCacheSize(data.getInt(cacheSize));
        }
        return builder.build();
    }

    public static UploadingConfig dataToUploadingConfig(@NonNull ReadableMap data, @NonNull Context context) {
        final String useWifiOnly = "use_wifi_only";
        final String syncInterval = "sync_interval";
        final String turnOffUploader = "turn_off_uploader";

        UploadingConfig.Builder builder = new UploadingConfig.Builder();
        if (data.hasKey(useWifiOnly)) {
            builder.useWifiOnly(data.getBoolean(useWifiOnly));
        }
        if (data.hasKey(syncInterval)) {
            builder.syncInterval(data.getInt(syncInterval));
        }
        if (data.hasKey(turnOffUploader)) {
            builder.turnOffUploader(data.getBoolean(turnOffUploader));
        }
        return builder.build();
    }
}