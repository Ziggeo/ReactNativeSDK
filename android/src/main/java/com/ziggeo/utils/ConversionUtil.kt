package com.ziggeo.utils

import android.content.Context
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.ReadableType
import com.facebook.react.bridge.WritableNativeMap
import com.facebook.react.bridge.Arguments
import com.ziggeo.androidsdk.CacheConfig
import com.ziggeo.androidsdk.StopRecordingConfirmationDialogConfig
import com.ziggeo.androidsdk.net.uploading.UploadingConfig
import com.ziggeo.androidsdk.ui.theming.PlayerStyle;
import java.io.File
import com.ziggeo.utils.ThemeKeys
import com.ziggeo.utils.RecorderKeys
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
        result = when (readableMap.getType(key)) {
            ReadableType.Null -> null
            ReadableType.Boolean -> readableMap.getBoolean(key)
            ReadableType.Number -> readableMap.getDouble(key)
            ReadableType.String -> readableMap.getString(key)
            ReadableType.Array -> toList(readableMap.getArray(key)!!)
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
    fun toList(readableArray: ReadableArray): MutableList<Any?> {
        var result: MutableList<Any?> = ArrayList(readableArray.size())
        for (index in 0 until readableArray.size()) {
            when (readableArray.getType(index)) {
                ReadableType.Null -> result.add(index.toString())
                ReadableType.Boolean -> result.add(readableArray.getBoolean(index))
                ReadableType.Number -> readableArray.getDouble(index)
                ReadableType.String -> result.add(readableArray.getString(index))
                ReadableType.Map -> result.add(toMap(readableArray.getMap(index)))
                ReadableType.Array -> result = toList(readableArray.getArray(index)!!)
                else -> throw IllegalArgumentException("Could not convert object with index: $index.")
            }
        }
        return result
    }

    @JvmStatic
    fun dataToCacheConfig(data: ReadableMap, context: Context): CacheConfig {
        val builder = CacheConfig.Builder(context)
        if (data.hasKey(RecorderKeys.KEY_CACHE_ROOT)) {
            builder.cacheDirectory(File(data.getString(RecorderKeys.KEY_CACHE_ROOT)))
        }
        if (data.hasKey(RecorderKeys.KEY_CACHE_SIZE)) {
            builder.maxCacheSize(data.getInt(RecorderKeys.KEY_CACHE_SIZE).toLong())
        }
        return builder.build()
    }

    @JvmStatic
    fun dataFromCacheConfig(data: CacheConfig): WritableMap {
        val map: WritableMap = Arguments.createMap()
        map.putInt(RecorderKeys.KEY_CACHE_SIZE, data.maxCacheSize.toInt())
        map.putString(RecorderKeys.KEY_CACHE_ROOT, data.cacheRoot.toString())
        return map;
    }

    @JvmStatic
    fun dataToUploadingConfig(data: ReadableMap, context: Context): UploadingConfig {
        val builder = UploadingConfig.Builder()
        if (data.hasKey(RecorderKeys.KEY_USE_WIFI_ONLY)) {
            builder.useWifiOnly(data.getBoolean(RecorderKeys.KEY_USE_WIFI_ONLY))
        }
        if (data.hasKey(RecorderKeys.KEY_SYNC_INTERVAL)) {
            builder.syncInterval(data.getInt(RecorderKeys.KEY_SYNC_INTERVAL).toLong())
        }
        if (data.hasKey(RecorderKeys.KEY_TURN_OFF_UPLOADER)) {
            builder.turnOffUploader(data.getBoolean(RecorderKeys.KEY_TURN_OFF_UPLOADER))
        }
        if (data.hasKey(RecorderKeys.KEY_START_AS_FOREGROUND)) {
            builder.startAsForeground(data.getBoolean(RecorderKeys.KEY_START_AS_FOREGROUND))
        }
        return builder.build()
    }

    @JvmStatic
    fun dataFromUploadingConfig(data: UploadingConfig): ReadableMap {
        val map: WritableMap = Arguments.createMap()
        map.putBoolean(RecorderKeys.KEY_USE_WIFI_ONLY, data.shouldUseWifiOnly)
        map.putInt(RecorderKeys.KEY_SYNC_INTERVAL, data.syncInterval.toInt())
        map.putBoolean(RecorderKeys.KEY_TURN_OFF_UPLOADER, data.shouldTurnOffUploader)
        return map;
    }

    @JvmStatic
    fun dataToConfirmationDialogConfig(data: ReadableMap, context: Context):
            StopRecordingConfirmationDialogConfig {
        val builder = StopRecordingConfirmationDialogConfig.Builder()
        if (data.hasKey(RecorderKeys.KEY_TITLE_RES_ID)) {
            builder.titleResId(data.getInt(RecorderKeys.KEY_TITLE_RES_ID))
        }
        if (data.hasKey(RecorderKeys.KEY_TITLE_TEXT)) {
            builder.titleText(data.getString(RecorderKeys.KEY_TITLE_TEXT) as CharSequence)
        }
        if (data.hasKey(RecorderKeys.KEY_MESSAGE_RES_ID)) {
            builder.mesResId(data.getInt(RecorderKeys.KEY_MESSAGE_RES_ID))
        }
        if (data.hasKey(RecorderKeys.KEY_MESSAGE_TEXT)) {
            builder.mesText(data.getString(RecorderKeys.KEY_MESSAGE_TEXT) as CharSequence)
        }
        if (data.hasKey(RecorderKeys.KEY_POSITIVE_BUTTON_RES_ID)) {
            builder.posBtnResId(data.getInt(RecorderKeys.KEY_POSITIVE_BUTTON_RES_ID))
        }
        if (data.hasKey(RecorderKeys.KEY_POSITIVE_BUTTON_TEXT)) {
            builder.posBtnText(data.getString(RecorderKeys.KEY_POSITIVE_BUTTON_TEXT) as CharSequence)
        }
        if (data.hasKey(RecorderKeys.KEY_NEGATIVE_BUTTON_RES_ID)) {
            builder.negBtnResId(data.getInt(RecorderKeys.KEY_NEGATIVE_BUTTON_RES_ID))
        }
        if (data.hasKey(RecorderKeys.KEY_NEGATIVE_BUTTON_TEXT)) {
            builder.negBtnText(data.getString(RecorderKeys.KEY_NEGATIVE_BUTTON_TEXT) as CharSequence)
        }
        return builder.build()
    }

    @JvmStatic
    fun dataFromConfirmationDialogConfig(data: StopRecordingConfirmationDialogConfig): ReadableMap {
        val map: WritableMap = Arguments.createMap()
        map.putInt(RecorderKeys.KEY_TITLE_RES_ID, data.titleResId)
        if (data.titleText != null) {
            map.putString(RecorderKeys.KEY_TITLE_TEXT, data.titleText.toString())
        }
        map.putInt(RecorderKeys.KEY_MESSAGE_RES_ID, data.mesResId)
        if (data.mesText != null) {
            map.putString(RecorderKeys.KEY_MESSAGE_TEXT, data.mesText.toString())
        }
        map.putInt(RecorderKeys.KEY_POSITIVE_BUTTON_RES_ID, data.posBtnResId)
        if (data.posBtnText != null) {
            map.putString(RecorderKeys.KEY_POSITIVE_BUTTON_TEXT, data.posBtnText.toString())
        }
        map.putInt(RecorderKeys.KEY_NEGATIVE_BUTTON_RES_ID, data.negBtnResId)
        if (data.negBtnText != null) {
            map.putString(RecorderKeys.KEY_NEGATIVE_BUTTON_TEXT, data.negBtnText.toString())
        }
        return map;
    }

    @JvmStatic
    fun dataFromPlayerStyle(data: PlayerStyle): ReadableMap {
        val map: WritableMap = Arguments.createMap()
        map.putBoolean(ThemeKeys.KEY_HIDE_PLAYER_CONTROLS, data.isHideControls)
        map.putInt(ThemeKeys.KEY_PLAYER_CONTROLLER_STYLE, data.controllerStyle)
        map.putInt(ThemeKeys.KEY_PLAYER_TEXT_COLOR, data.textColor)
        map.putInt(ThemeKeys.KEY_PLAYER_UNPLAYED_COLOR, data.unplayedColor)
        map.putInt(ThemeKeys.KEY_PLAYER_PLAYED_COLOR, data.playedColor)
        map.putInt(ThemeKeys.KEY_PLAYER_BUFFERED_COLOR, data.bufferedColor)
        map.putInt(ThemeKeys.KEY_PLAYER_TINT_COLOR, data.tintColor)
        map.putInt(ThemeKeys.KEY_PLAYER_MUTE_OFF_DRAWABLE, data.muteOffImageDrawable)
        map.putInt(ThemeKeys.KEY_PLAYER_MUTE_ON_DRAWABLE, data.muteOnImageDrawable)
        return map;
    }
}
