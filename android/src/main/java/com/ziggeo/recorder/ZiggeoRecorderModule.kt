package com.ziggeo.recorder

import android.Manifest
import com.facebook.react.bridge.*
import com.karumi.dexter.Dexter
import com.karumi.dexter.PermissionToken
import com.karumi.dexter.listener.PermissionDeniedResponse
import com.karumi.dexter.listener.PermissionGrantedResponse
import com.karumi.dexter.listener.PermissionRequest
import com.karumi.dexter.listener.single.PermissionListener
import com.ziggeo.BaseModule
import com.ziggeo.androidsdk.callbacks.*
import com.ziggeo.androidsdk.db.impl.room.models.RecordingInfo
import com.ziggeo.androidsdk.log.ZLog
import com.ziggeo.androidsdk.qr.IQrScanner
import com.ziggeo.androidsdk.qr.QrScannerCallback
import com.ziggeo.androidsdk.qr.QrScannerConfig
import com.ziggeo.androidsdk.recorder.MicSoundLevel
import com.ziggeo.androidsdk.recorder.RecorderConfig
import com.ziggeo.androidsdk.widgets.cameraview.CameraView
import com.ziggeo.androidsdk.widgets.cameraview.CameraView.Facing
import com.ziggeo.androidsdk.widgets.cameraview.CameraView.Quality
import com.ziggeo.androidsdk.widgets.cameraview.Size
import com.ziggeo.tasks.RecordVideoTask
import com.ziggeo.tasks.Task
import com.ziggeo.tasks.UploadFileTask
import com.ziggeo.utils.ConversionUtil.dataToCacheConfig
import com.ziggeo.utils.ConversionUtil.dataToUploadingConfig
import com.ziggeo.utils.ConversionUtil.toMap
import com.ziggeo.utils.Events
import com.ziggeo.utils.FileUtils.getVideoDurationInSeconds
import com.ziggeo.utils.Keys
import com.ziggeo.utils.ThemeKeys
import java.io.File
import java.util.*

/**
 * Created by Alex Bedulin on 6/25/2017.
 */
class ZiggeoRecorderModule(reactContext: ReactApplicationContext) : BaseModule(reactContext) {
    private var width = 0
    private var height = 0
    override fun getName() = "ZiggeoRecorder"

    // we must override this method to make @ReactMethod annotation work
    @ReactMethod
    override fun setClientAuthToken(token: String) {
        super.setClientAuthToken(token)
    }

    // we must override this method to make @ReactMethod annotation work
    @ReactMethod
    override fun setServerAuthToken(token: String) {
        super.setServerAuthToken(token)
    }

    @ReactMethod
    fun setAppToken(appToken: String) {
        ZLog.d("setAppToken:%s", appToken)
        ziggeo.appToken = appToken
    }

    @ReactMethod
    fun setVideoWidth(w: Int) {
        this.width = w
        if (width != 0 && height != 0) {
            ziggeo.recorderConfig.resolution = Size(width, height)
        } else {
            ziggeo.recorderConfig.resolution = Size(0, 0)
        }
    }

    @ReactMethod
    fun setVideoBitrate(bitrate: Int) {
        ziggeo.recorderConfig.videoBitrate = bitrate
    }

    @ReactMethod
    fun setAudioSampleRate(sampleRate: Int) {
        ziggeo.recorderConfig.audioSampleRate = sampleRate
    }

    @ReactMethod
    fun setAudioBitrate(bitrate: Int) {
        ziggeo.recorderConfig.audioBitrate = bitrate
    }

    @ReactMethod
    fun setVideoHeight(h: Int) {
        this.height = h
        if (width != 0 && height != 0) {
            ziggeo.recorderConfig.resolution = Size(width, height)
        } else {
            ziggeo.recorderConfig.resolution = Size(0, 0)
        }
    }

    @ReactMethod
    fun setLiveStreamingEnabled(enabled: Boolean) {
        ZLog.d("setLiveStreamingEnabled:%s", enabled)
        ziggeo.recorderConfig = RecorderConfig.Builder(ziggeo.recorderConfig)
                .isLiveStreaming(enabled)
                .build()
    }

    @ReactMethod
    fun setAutostartRecordingAfter(seconds: Int) {
        ZLog.d("setAutostartRecordingAfter:%s", seconds)
        ziggeo.recorderConfig.shouldAutoStartRecording = true
        ziggeo.recorderConfig.startDelay = seconds
    }

    @ReactMethod
    fun setStartDelay(seconds: Int) {
        ZLog.d("setStartDelay:%s", seconds)
        ziggeo.recorderConfig.startDelay = seconds
    }

    @ReactMethod
    fun setExtraArgsForCreateVideo(readableMap: ReadableMap?) {
        ZLog.d("setExtraArgsForCreateVideo:%s", readableMap)
        setExtraArgsForRecorder(readableMap)
    }

    @ReactMethod
    fun setExtraArgsForRecorder(readableMap: ReadableMap?) {
        ZLog.d("setExtraArgsForRecorder:%s", readableMap)
        ziggeo.recorderConfig.extraArgs = toMap(readableMap)
    }

    @ReactMethod
    fun setCoverSelectorEnabled(enabled: Boolean) {
        ZLog.d("setCoverSelectorEnabled:%s", enabled)
        ziggeo.recorderConfig.shouldEnableCoverShot = enabled
    }

    @ReactMethod
    fun setMaxRecordingDuration(maxDurationSeconds: Int) {
        val millis = maxDurationSeconds * 1000.toLong()
        ZLog.d("setMaxRecordingDuration:%s", millis)
        ziggeo.recorderConfig.maxDuration = millis
    }

    @ReactMethod
    fun setCameraSwitchEnabled(enabled: Boolean) {
        ZLog.d("setCameraSwitchEnabled:%s", enabled)
        ziggeo.recorderConfig.shouldDisableCameraSwitch = !enabled
    }

    @ReactMethod
    fun setSendImmediately(sendImmediately: Boolean) {
        ZLog.d("setSendImmediately:%s", sendImmediately)
        ziggeo.recorderConfig.shouldSendImmediately = sendImmediately
    }

    @ReactMethod
    fun setCamera(@Facing facing: Int) {
        ZLog.d("setCamera:%s", facing)
        ziggeo.recorderConfig.facing = facing
    }

    @ReactMethod
    fun setQuality(@Quality quality: Int) {
        ZLog.d("setQuality:%s", quality)
        ziggeo.recorderConfig.videoQuality = quality
    }

    @ReactMethod
    fun setThemeArgsForRecorder(data: ReadableMap?) {
        ZLog.d("setThemeArgsForRecorder")
        data?.let {
            ZLog.d(it.toString())
            if (it.hasKey(ThemeKeys.KEY_HIDE_RECORDER_CONTROLS)) {
                val hideControls = it.getBoolean(ThemeKeys.KEY_HIDE_RECORDER_CONTROLS)
                ziggeo.recorderConfig.style.isHideControls = hideControls
            }
        }
    }

    @ReactMethod
    fun record(promise: Promise?) {
        val task = RecordVideoTask(promise!!)
        ziggeo.recorderConfig.callback = prepareRecorderCallback(task)
        ziggeo.uploadingConfig.callback = prepareUploadingCallback(task)
        ziggeo.startCameraRecorder()
    }

    @ReactMethod
    fun startScreenRecorder(promise: Promise?) {
        val task = RecordVideoTask(promise!!)
        ziggeo.recorderConfig.callback = prepareRecorderCallback(task)
        ziggeo.uploadingConfig.callback = prepareUploadingCallback(task)
        ziggeo.startScreenRecorder(null)
    }

    @ReactMethod
    fun cancelRequest() {
        ZLog.d("cancelRequest")
    }

    @ReactMethod
    fun startQrScanner(data: ReadableMap?) {
        ZLog.d("startQrScanner")
        val keyClose = "closeAfterSuccessfulScan"
        val config = toMap(data)
        var close = true
        if (config != null && config.containsKey(keyClose)) {
            close = java.lang.Boolean.parseBoolean(config[keyClose])
        }
        ziggeo.qrScannerConfig = QrScannerConfig(close, object : QrScannerCallback() {
            override fun onDecoded(value: String) {
                super.onDecoded(value)
                val params = Arguments.createMap()
                params.putString(Keys.QR, value)
                sendEvent(Events.QR_DECODED, params)
            }
        })
        ziggeo.startQrScanner()
    }

    @ReactMethod
    fun uploadFromPath(path: String, data: ReadableMap?, promise: Promise) {
        val task = UploadFileTask(promise)
        var args: HashMap<String, String?>? = toMap(data)
        if (args == null) {
            args = ziggeo.recorderConfig.extraArgs
        }
        if (args != null) {
            task.extraArgs = args
        }
        Dexter.withContext(currentActivity)
                .withPermission(Manifest.permission.READ_EXTERNAL_STORAGE)
                .withListener(object : PermissionListener {
                    override fun onPermissionGranted(response: PermissionGrantedResponse) {
                        ZLog.d("onPermissionGranted")
                        var enforceDuration = false
                        var maxDurationInSeconds = 0
                        task.extraArgs?.let {
                            val strDuration = it[ARG_DURATION]
                            if (strDuration?.isNotEmpty() == true) {
                                maxDurationInSeconds = strDuration.toInt()
                            }
                            val enforce = it[ARG_ENFORCE_DURATION]
                            if (enforce?.isNotEmpty() == true) {
                                enforceDuration = enforce.toBoolean()
                            }
                        }
                        val videoFile = File(path)
                        if (!videoFile.exists()) {
                            ZLog.e("File does not exist: %s", path)
                            reject(task, ERR_FILE_DOES_NOT_EXIST, path)
                        } else if (enforceDuration && maxDurationInSeconds > 0 && getVideoDurationInSeconds(path, reactApplicationContext) > maxDurationInSeconds) {
                            val errorMsg = "Video duration is more than allowed."
                            ZLog.e(errorMsg)
                            ZLog.e("Path: %s", path)
                            ZLog.e("Duration: %s", getVideoDurationInSeconds(path, reactApplicationContext))
                            ZLog.e("Max allowed duration: %s", maxDurationInSeconds)
                            reject(task, ERR_DURATION_EXCEEDED, errorMsg)
                        } else {
                            ziggeo.uploadingConfig.callback = prepareUploadingCallback(task)
                            ziggeo.uploadingHandler.uploadNow(RecordingInfo(File(path),
                                    null, task.extraArgs))
                        }
                    }

                    override fun onPermissionDenied(response: PermissionDeniedResponse) {
                        ZLog.d("onPermissionDenied")
                        reject(task, ERR_PERMISSION_DENIED)
                    }

                    override fun onPermissionRationaleShouldBeShown(permission: PermissionRequest, token: PermissionToken) {
                        ZLog.d("onPermissionRationaleShouldBeShown")
                    }
                }).check()
    }

    @ReactMethod
    fun uploadFromFileSelector(data: ReadableMap?, promise: Promise) {
        val task = UploadFileTask(promise)
        val args = toMap(data)
        if (args != null) {
            task.extraArgs = args
        }
        var maxDurationInSeconds = 0
        task.extraArgs?.let {
            val strDuration = it[ARG_DURATION]
            if (strDuration?.isNotEmpty() == true) {
                maxDurationInSeconds = strDuration.toInt()
            }
        }
        ziggeo.fileSelectorConfig.maxDuration = maxDurationInSeconds * 1000L
        ziggeo.fileSelectorConfig.extraArgs = task.extraArgs
        ziggeo.uploadingConfig.callback = prepareUploadingCallback(task)
        ziggeo.startFileSelector()
    }

    @ReactMethod
    fun setRecorderCacheConfig(data: ReadableMap?) {
        data?.let {
            ziggeo.recorderConfig.cacheConfig = dataToCacheConfig(it, reactApplicationContext)
        }
    }

    @ReactMethod
    fun setUploadingConfig(data: ReadableMap?) {
        data?.let {
            ziggeo.uploadingConfig = dataToUploadingConfig(it, reactApplicationContext)
        }
    }

    override fun getConstants(): Map<String, Any>? {
        val constants: MutableMap<String, Any> = HashMap()
        constants[REAR_CAMERA] = CameraView.FACING_BACK
        constants[FRONT_CAMERA] = CameraView.FACING_FRONT
        constants[HIGH_QUALITY] = CameraView.QUALITY_HIGH
        constants[MEDIUM_QUALITY] = CameraView.QUALITY_MEDIUM
        constants[LOW_QUALITY] = CameraView.QUALITY_LOW
        return constants
    }

    private fun prepareUploadingCallback(task: Task): IUploadingCallback {
        return object : UploadingCallback() {
            override fun uploadProgress(videoToken: String, path: String, uploaded: Long, total: Long) {
                super.uploadProgress(videoToken, path, uploaded, total)
                ZLog.d("uploadProgress")
                val params = Arguments.createMap()
                params.putString(Keys.TOKEN, videoToken)
                params.putString(Keys.FILE_NAME, File(path).name)
                params.putString(Keys.BYTES_SENT, uploaded.toString())
                params.putString(Keys.BYTES_TOTAL, total.toString())
                sendEvent(Events.UPLOAD_PROGRESS, params)
            }

            override fun uploaded(path: String, token: String) {
                super.uploaded(path, token)
                ZLog.d("uploaded")
                resolve(task, token)
                val map = Arguments.createMap()
                map.putString(Keys.PATH, path)
                map.putString(Keys.TOKEN, token)
                sendEvent(Events.UPLOADED, map)
            }

            override fun uploadingStarted(path: String) {
                super.uploadingStarted(path)
                ZLog.d("uploadingStarted")
                if (task is RecordVideoTask) {
                    task.isUploadingStarted = true
                }
                val map = Arguments.createMap()
                map.putString(Keys.PATH, path)
                sendEvent(Events.UPLOADING_STARTED, map)
            }

            override fun processing(token: String) {
                super.processing(token)
                ZLog.d("processing")
                val params = Arguments.createMap()
                params.putString(Keys.TOKEN, token)
                sendEvent(Events.PROCESSING, params)
            }

            override fun processed(token: String) {
                super.processed(token)
                ZLog.d("processed")
                val params = Arguments.createMap()
                params.putString(Keys.TOKEN, token)
                sendEvent(Events.PROCESSED, params)
            }

            override fun verified(token: String) {
                super.verified(token)
                ZLog.d("verified")
                val params = Arguments.createMap()
                params.putString(Keys.TOKEN, token)
                sendEvent(Events.VERIFIED, params)
            }

            override fun error(throwable: Throwable) {
                super.error(throwable)
                ZLog.d("error:%s", throwable)
                reject(task, ERR_UNKNOWN, throwable.toString())
                val map = Arguments.createMap()
                map.putString(Keys.ERROR, throwable.toString())
                sendEvent(Events.ERROR, map)
            }
        }
    }

    private fun prepareRecorderCallback(task: Task): IRecorderCallback {
        return object : RecorderCallback() {
            override fun loaded() {
                super.loaded()
                sendEvent(Events.LOADED)
            }

            override fun manuallySubmitted() {
                super.manuallySubmitted()
                sendEvent(Events.MANUALLY_SUBMITTED)
            }

            override fun countdown(secondsLeft: Int) {
                super.countdown(secondsLeft)
                val map = Arguments.createMap()
                map.putInt(Keys.SECONDS_LEFT, secondsLeft)
                sendEvent(Events.COUNTDOWN, map)
            }

            override fun recordingProgress(millisPassed: Long) {
                super.recordingProgress(millisPassed)
                val map = Arguments.createMap()
                map.putDouble(Keys.MILLIS_PASSED, millisPassed.toDouble())
                sendEvent(Events.COUNTDOWN, map)
            }

            override fun readyToRecord() {
                super.readyToRecord()
                sendEvent(Events.READY_TO_RECORD)
            }

            override fun accessGranted() {
                super.accessGranted()
                sendEvent(Events.ACCESS_GRANTED)
            }

            override fun noCamera() {
                super.noCamera()
                sendEvent(Events.NO_CAMERA)
            }

            override fun hasCamera() {
                super.hasCamera()
                sendEvent(Events.HAS_CAMERA)
            }

            override fun noMicrophone() {
                super.noMicrophone()
                sendEvent(Events.NO_MIC)
            }

            override fun hasMicrophone() {
                super.hasMicrophone()
                sendEvent(Events.HAS_MIC)
            }

            override fun microphoneHealth(micStatus: MicSoundLevel) {
                super.microphoneHealth(micStatus)
                val map = Arguments.createMap()
                map.putString(Keys.SOUND_LEVEL, micStatus.toString())
                sendEvent(Events.MIC_HEALTH, map)
            }

            override fun streamingStarted() {
                super.streamingStarted()
                sendEvent(Events.STREAMING_STARTED)
            }

            override fun streamingStopped() {
                super.streamingStopped()
                sendEvent(Events.STREAMING_STOPPED)
            }

            override fun rerecord() {
                super.rerecord()
                sendEvent(Events.RERECORD)
            }

            override fun accessForbidden(permissions: List<String>) {
                super.accessForbidden(permissions)
                ZLog.d("accessForbidden")
                reject(task, ERR_PERMISSION_DENIED)
                val map = Arguments.createMap()
                map.putArray(Keys.PERMISSIONS, Arguments.fromList(permissions))
                sendEvent(Events.ACCESS_FORBIDDEN, map)
            }

            override fun error(throwable: Throwable) {
                super.error(throwable)
                ZLog.d("error:%s", throwable)
                reject(task, ERR_UNKNOWN, throwable.toString())
                val map = Arguments.createMap()
                map.putString(Keys.ERROR, throwable.toString())
                sendEvent(Events.ERROR, map)
            }

            override fun recordingStarted() {
                super.recordingStarted()
                ZLog.d("recordingStarted")
                sendEvent(Events.RECORDING_STARTED)
            }

            override fun recordingStopped(path: String) {
                super.recordingStopped(path)
                ZLog.d("recordingStopped:%s", path)
                val map = Arguments.createMap()
                map.putString(Keys.PATH, path)
                sendEvent(Events.RECORDING_STOPPED, map)
            }

            override fun canceledByUser() {
                super.canceledByUser()
                ZLog.d("canceledByUser")
                sendEvent(Events.CANCELLED_BY_USER)
                cancel(task)
            }
        }
    }

    private fun prepareQrCallback(task: Task): IQrScanner.Callback {
        return object : QrScannerCallback() {
            override fun onDecoded(value: String) {
                super.onDecoded(value)
                val map = Arguments.createMap()
                map.putString(Keys.VALUE, value)
                sendEvent(Events.QR_DECODED, map)
            }

            override fun noMicrophone() {
                super.noMicrophone()
                sendEvent(Events.NO_MIC)
            }

            override fun hasMicrophone() {
                super.hasMicrophone()
                sendEvent(Events.HAS_MIC)
            }

            override fun canceledByUser() {
                super.canceledByUser()
                ZLog.d("canceledByUser")
                sendEvent(Events.CANCELLED_BY_USER)
                cancel(task)
            }

            override fun accessForbidden(permissions: List<String>) {
                super.accessForbidden(permissions)
                ZLog.d("accessForbidden")
                reject(task, ERR_PERMISSION_DENIED)
                val map = Arguments.createMap()
                map.putArray(Keys.PERMISSIONS, Arguments.fromList(permissions))
                sendEvent(Events.ACCESS_FORBIDDEN, map)
            }

            override fun error(throwable: Throwable) {
                super.error(throwable)
                ZLog.d("error:%s", throwable)
                reject(task, ERR_UNKNOWN, throwable.toString())
                val map = Arguments.createMap()
                map.putString(Keys.ERROR, throwable.toString())
                sendEvent(Events.ERROR, map)
            }

            override fun accessGranted() {
                super.accessGranted()
                sendEvent(Events.ACCESS_GRANTED)
            }

            override fun noCamera() {
                super.noCamera()
                sendEvent(Events.NO_CAMERA)
            }

            override fun hasCamera() {
                super.hasCamera()
                sendEvent(Events.HAS_CAMERA)
            }

            override fun loaded() {
                super.loaded()
                sendEvent(Events.LOADED)
            }
        }
    }

    private fun prepareFileSelectorCallback(task: Task): IFileSelectorCallback {
        return object : FileSelectorCallback() {
            override fun uploadSelected(paths: List<String>) {
                super.uploadSelected(paths)
                val map = Arguments.createMap()
                map.putArray(Keys.FILES, Arguments.fromList(paths))
                sendEvent(Events.ERROR, map)
            }

            override fun loaded() {
                super.loaded()
                sendEvent(Events.LOADED)
            }

            override fun canceledByUser() {
                super.canceledByUser()
                sendEvent(Events.CANCELLED_BY_USER)
                cancel(task)
            }

            override fun error(throwable: Throwable) {
                super.error(throwable)
                ZLog.d("error:%s", throwable)
                reject(task, ERR_UNKNOWN, throwable.toString())
                val map = Arguments.createMap()
                map.putString(Keys.ERROR, throwable.toString())
                sendEvent(Events.ERROR, map)
            }

            override fun accessForbidden(permissions: List<String>) {
                super.accessForbidden(permissions)
                ZLog.d("accessForbidden")
                reject(task, ERR_PERMISSION_DENIED)
                val map = Arguments.createMap()
                map.putArray(Keys.PERMISSIONS, Arguments.fromList(permissions))
                sendEvent(Events.ACCESS_FORBIDDEN, map)
            }

            override fun accessGranted() {
                super.accessGranted()
                sendEvent(Events.ACCESS_GRANTED)
            }
        }
    }

    private fun preparePlayerCallback(task: Task): IPlayerCallback {
        return object : PlayerCallback() {
            override fun loaded() {
                super.loaded()
                sendEvent(Events.LOADED)
            }

            override fun canceledByUser() {
                super.canceledByUser()
                sendEvent(Events.CANCELLED_BY_USER)
                cancel(task)
            }

            override fun error(throwable: Throwable) {
                super.error(throwable)
                ZLog.d("error:%s", throwable)
                reject(task, ERR_UNKNOWN, throwable.toString())
                val map = Arguments.createMap()
                map.putString(Keys.ERROR, throwable.toString())
                sendEvent(Events.ERROR, map)
            }

            override fun playing() {
                super.playing()
                sendEvent(Events.PLAYING)
            }

            override fun paused() {
                super.paused()
                sendEvent(Events.PAUSED)
            }

            override fun ended() {
                super.ended()
                sendEvent(Events.ENDED)
            }

            override fun seek(millis: Long) {
                super.seek(millis)
                val map = Arguments.createMap()
                map.putDouble(Keys.MILLIS, millis.toDouble())
                sendEvent(Events.SEEK, map)
            }

            override fun readyToPlay() {
                super.readyToPlay()
                sendEvent(Events.READY_TO_PLAY)
            }

            override fun accessForbidden(permissions: List<String>) {
                super.accessForbidden(permissions)
                ZLog.d("accessForbidden")
                reject(task, ERR_PERMISSION_DENIED)
                val map = Arguments.createMap()
                map.putArray(Keys.PERMISSIONS, Arguments.fromList(permissions))
                sendEvent(Events.ACCESS_FORBIDDEN, map)
            }

            override fun accessGranted() {
                super.accessGranted()
                sendEvent(Events.ACCESS_GRANTED)
            }
        }
    }

    companion object {
        // constants for mapping native constants in JS
        private const val REAR_CAMERA = "rearCamera"
        private const val FRONT_CAMERA = "frontCamera"
        private const val HIGH_QUALITY = "highQuality"
        private const val MEDIUM_QUALITY = "mediumQuality"
        private const val LOW_QUALITY = "lowQuality"
        private const val ERR_UNKNOWN = "ERR_UNKNOWN"
        private const val ERR_DURATION_EXCEEDED = "ERR_DURATION_EXCEEDED"
        private const val ERR_FILE_DOES_NOT_EXIST = "ERR_FILE_DOES_NOT_EXIST"
        private const val ERR_PERMISSION_DENIED = "ERR_PERMISSION_DENIED"
        private const val ARG_DURATION = "max_duration"
        private const val ARG_ENFORCE_DURATION = "enforce_duration"
    }
}