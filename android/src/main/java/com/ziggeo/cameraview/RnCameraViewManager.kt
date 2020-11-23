package com.ziggeo.cameraview

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp
import com.ziggeo.BaseViewManager
import com.ziggeo.androidsdk.callbacks.RecorderCallback
import com.ziggeo.androidsdk.log.ZLog
import com.ziggeo.androidsdk.widgets.cameraview.CameraView
import com.ziggeo.androidsdk.widgets.cameraview.CameraView.*
import com.ziggeo.androidsdk.widgets.cameraview.Size
import com.ziggeo.utils.Events
import com.ziggeo.utils.Keys

class RnCameraViewManager(reactContext: ReactApplicationContext) : BaseViewManager<RnCameraView>() {
    lateinit var cameraView: RnCameraView
        private set

    override fun getName() = "ZiggeoCameraView"

    init {
        context = reactContext
    }

    override fun createViewInstance(reactContext: ThemedReactContext): RnCameraView {
        cameraView = RnCameraView(reactContext)
        context.addLifecycleEventListener(cameraView)
        initCallbacks()
        return cameraView
    }


    @ReactProp(name = "facing")
    fun setFacing(cameraView: CameraView, @Facing facing: Int) {
        cameraView.facing = facing
    }

    @ReactProp(name = "quality")
    fun setQuality(cameraView: CameraView, @Quality quality: Int) {
        cameraView.quality = quality
    }

    @ReactProp(name = "autoFocus")
    fun setAutoFocus(cameraView: CameraView, autoFocus: Boolean) {
        cameraView.autoFocus = autoFocus
    }

    @ReactProp(name = "flash")
    fun setFlash(cameraView: CameraView, @Flash flash: Int) {
        cameraView.flash = flash
    }

    @ReactProp(name = "resolution")
    fun setResolution(cameraView: CameraView, array: ReadableArray) {
        cameraView.setResolution(Size(array.getInt(0), array.getInt(1)))
    }

    @ReactProp(name = "videoBitrate")
    fun setVideoBitrate(cameraView: CameraView, bitrate: Int) {
        cameraView.setVideoBitrate(bitrate)
    }

    @ReactProp(name = "audioBitrate")
    fun setAudioBitrate(cameraView: CameraView, bitrate: Int) {
        cameraView.setAudioBitrate(bitrate)
    }

    @ReactProp(name = "audioSampleRate")
    fun setAudioSampleRate(cameraView: CameraView, sampleRate: Int) {
        cameraView.setAudioSampleRate(sampleRate)
    }

    private fun initCallbacks() {
        cameraView.setCameraCallback(object : CameraCallback() {
            override fun cameraOpened() {
                super.cameraOpened()
                ZLog.d(Events.CAMERA_OPENED)
                sendEvent(Events.CAMERA_OPENED)
            }

            override fun cameraClosed() {
                super.cameraClosed()
                sendEvent(Events.CAMERA_CLOSED)
            }
        })
        cameraView.setRecorderCallback(object : RecorderCallback() {
            override fun error(throwable: Throwable) {
                super.error(throwable)
                val params = Arguments.createMap()
                params.putString(Events.ERROR, throwable.toString())
                sendEvent(Events.ERROR, params)
            }

            override fun recordingStarted() {
                super.recordingStarted()
                sendEvent(Events.RECORDING_STARTED)
            }

            override fun recordingStopped(path: String) {
                super.recordingStopped(path)
                val params = Arguments.createMap()
                params.putString(Keys.PATH, path)
                sendEvent(Events.RECORDING_STOPPED, params)
            }

            override fun streamingStarted() {
                super.streamingStarted()
                sendEvent(Events.STREAMING_STARTED)
            }

            override fun streamingStopped() {
                super.streamingStopped()
                sendEvent(Events.STREAMING_STOPPED)
            }
        })
    }
}