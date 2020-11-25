package com.ziggeo.utils

import android.content.Context
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.ReadableType
import com.ziggeo.androidsdk.CacheConfig
import com.ziggeo.androidsdk.fileselector.FileSelectorConfig
import com.ziggeo.androidsdk.net.uploading.UploadingConfig
import com.ziggeo.androidsdk.qr.QrScannerConfig
import com.ziggeo.androidsdk.recorder.RecorderConfig
import com.ziggeo.androidsdk.widgets.cameraview.AspectRatio
import com.ziggeo.androidsdk.widgets.cameraview.Size
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
    @JvmStatic
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
        return builder.build()
    }

    @JvmStatic
    fun dataQrScannerConfig(data: ReadableMap): QrScannerConfig {
        val shouldCloseAfterSuccessfulScan = "close_after_successful_scan"
        val builder = QrScannerConfig.Builder()
        if (data.hasKey(shouldCloseAfterSuccessfulScan)) {
            builder.shouldCloseAfterSuccessfulScan(data.getBoolean(shouldCloseAfterSuccessfulScan))
        }
        return builder.build()
    }

    @JvmStatic
    fun dataToFileSelectorConfig(data: ReadableMap, context: Context): FileSelectorConfig {
        val maxDuration = "max_duration"
        val allowMultipleSelection = "allow_multiple_selection"
        val builder = FileSelectorConfig.Builder(context)
        if (data.hasKey(maxDuration)) {
            builder.maxDuration(data.getDouble(maxDuration).toLong())
        }
        if (data.hasKey(allowMultipleSelection)) {
            builder.shouldAllowMultipleSelection(data.getBoolean(allowMultipleSelection))
        }
        return builder.build()
    }

    @JvmStatic
    fun dataToRecorderConfig(data: ReadableMap, context: Context): RecorderConfig {
        val shouldShowFaceOutline = "show_face_outline"
        val isLiveStreaming = "is_live_streaming"
        val shouldAutoStartRecording = "auto_start_recording"
        val startDelay = "start_delay"
        val shouldSendImmediately = "send_immediately"
        val shouldDisableCameraSwitch = "disable_camera_switch"
        val quality = "quality"
        val facing = "facing"
        val maxDuration = "max_duration"
        val shouldEnableCoverShot = "enable_cover_shot"
        val shouldConfirmStopRecording = "confirm_stop_recording"
        val videoBitrate = "video_bitrate"
        val audioBitrate = "audio_bitrate"
        val audioSampleRate = "audio_sample_rate"

        val builder = RecorderConfig.Builder(context)
        if (data.hasKey(shouldShowFaceOutline)) {
            builder.shouldShowFaceOutline(data.getBoolean(shouldShowFaceOutline))
        }
        if (data.hasKey(isLiveStreaming)) {
            builder.isLiveStreaming(data.getBoolean(isLiveStreaming))
        }
        if (data.hasKey(shouldAutoStartRecording)) {
            builder.shouldAutoStartRecording(data.getBoolean(shouldAutoStartRecording))
        }
        if (data.hasKey(startDelay)) {
            builder.startDelay(data.getInt(startDelay))
        }
        if (data.hasKey(shouldSendImmediately)) {
            builder.shouldSendImmediately(data.getBoolean(shouldSendImmediately))
        }
        if (data.hasKey(shouldDisableCameraSwitch)) {
            builder.shouldDisableCameraSwitch(data.getBoolean(shouldDisableCameraSwitch))
        }
        if (data.hasKey(quality)) {
            builder.quality(data.getInt(quality))
        }
        if (data.hasKey(facing)) {
            builder.facing(data.getInt(facing))
        }
        if (data.hasKey(maxDuration)) {
            builder.maxDuration(data.getDouble(maxDuration).toLong())
        }
        if (data.hasKey(shouldEnableCoverShot)) {
            builder.shouldEnableCoverShot(data.getBoolean(shouldEnableCoverShot))
        }
        if (data.hasKey(shouldConfirmStopRecording)) {
            builder.shouldConfirmStopRecording(data.getBoolean(shouldConfirmStopRecording))
        }
        if (data.hasKey(videoBitrate)) {
            builder.videoBitrate(data.getInt(videoBitrate))
        }
        if (data.hasKey(audioBitrate)) {
            builder.audioBitrate(data.getInt(audioBitrate))
        }
        if (data.hasKey(audioSampleRate)) {
            builder.audioSampleRate(data.getInt(audioSampleRate))
        }
        return builder.build()
    }
}