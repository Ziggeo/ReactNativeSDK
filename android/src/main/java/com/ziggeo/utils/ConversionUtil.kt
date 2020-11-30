package com.ziggeo.utils

import android.content.Context
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.ReadableType
import com.ziggeo.androidsdk.CacheConfig
import com.ziggeo.androidsdk.net.uploading.UploadingConfig
import java.io.File
import java.util.*

/**
 * Helper utilities to convert from react-native types to POJOs
 */
object ConversionUtil {
    /**
     * toObject extracts a value from a [ReadableMap] by its key,
     * and returns a POJO representing that object.
     *
     * @param readableMap The Map to containing the value to be converted
     * @param key         The key for the value to be converted
     * @return The converted POJO
     */
    private fun toObject(readableMap: ReadableMap?, key: String): String? {
        if (readableMap == null) {
            return null
        }
        var result: Any? = null
        when (readableMap.getType(key)) {
            ReadableType.Null -> result = null
            ReadableType.Boolean -> result = readableMap.getBoolean(key)
            ReadableType.Number -> readableMap.getDouble(key)
            ReadableType.String -> result = readableMap.getString(key)
            else -> throw IllegalArgumentException("Could not convert object with key: $key.")
        }
        return result?.toString()
    }

    /**
     * toMap converts a [ReadableMap] into a HashMap.
     *
     * @param readableMap The ReadableMap to be conveted.
     * @return A HashMap containing the data that was in the ReadableMap.
     */
    @JvmStatic
    fun toMap(readableMap: ReadableMap?): HashMap<String, String?>? {
        if (readableMap == null) {
            return null
        }
        val iterator = readableMap.keySetIterator()
        if (!iterator.hasNextKey()) {
            return null
        }
        val result = HashMap<String, String?>()
        while (iterator.hasNextKey()) {
            val key = iterator.nextKey()
            result[key] = toObject(readableMap, key)
        }
        return result
    }

    /**
     * toList converts a [ReadableArray] into an ArrayList.
     *
     * @param readableArray The ReadableArray to be conveted.
     * @return An ArrayList containing the data that was in the ReadableArray.
     */
    fun toList(readableArray: ReadableArray?): MutableList<Any?>? {
        if (readableArray == null) {
            return null
        }
        var result: MutableList<Any?>? = ArrayList(readableArray.size())
        for (index in 0 until readableArray.size()) {
            when (readableArray.getType(index)) {
                ReadableType.Null -> result!!.add(index.toString())
                ReadableType.Boolean -> result!!.add(readableArray.getBoolean(index))
                ReadableType.Number -> readableArray.getDouble(index)
                ReadableType.String -> result!!.add(readableArray.getString(index))
                ReadableType.Map -> result!!.add(toMap(readableArray.getMap(index)))
                ReadableType.Array -> result = toList(readableArray.getArray(index))
                else -> throw IllegalArgumentException("Could not convert object with index: $index.")
            }
        }
        return result
    }

    @JvmStatic
    fun dataToCacheConfig(data: ReadableMap, context: Context): CacheConfig {
        val cacheSize = "cache_size"
        val cacheRoot = "cache_root"
        val builder = CacheConfig.Builder(context)
        if (data.hasKey(cacheRoot)) {
            builder.cacheDirectory(File(data.getString(cacheRoot)))
        }
        if (data.hasKey(cacheSize)) {
            builder.maxCacheSize(data.getInt(cacheSize).toLong())
        }
        return builder.build()
    }

    @JvmStatic
    fun dataToUploadingConfig(data: ReadableMap, context: Context): UploadingConfig {
        val useWifiOnly = "use_wifi_only"
        val syncInterval = "sync_interval"
        val turnOffUploader = "turn_off_uploader"
        val shouldStartAsForeground = "start_as_foreground"
        val builder = UploadingConfig.Builder()
        if (data.hasKey(useWifiOnly)) {
            builder.useWifiOnly(data.getBoolean(useWifiOnly))
        }
        if (data.hasKey(syncInterval)) {
            builder.syncInterval(data.getInt(syncInterval).toLong())
        }
        if (data.hasKey(turnOffUploader)) {
            builder.turnOffUploader(data.getBoolean(turnOffUploader))
        }
        if (data.hasKey(shouldStartAsForeground)) {
            builder.startAsForeground(data.getBoolean(shouldStartAsForeground))
        }
        return builder.build()
    }
}