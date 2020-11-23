package com.ziggeo.cameraview

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.ziggeo.BaseModule

/**
 * Created by alex on 6/25/2017.
 */
class CameraModule(
        reactContext: ReactApplicationContext,
        private val rnCameraViewManager: RnCameraViewManager
) : BaseModule(reactContext) {

    override fun getName() = "Camera"

    @ReactMethod
    fun startRecording(path: String, maxDurationMillis: Int) {
        rnCameraViewManager.cameraView.startRecording(path, maxDurationMillis)
    }

    @ReactMethod
    fun stopRecording() {
        rnCameraViewManager.cameraView.stopRecording()
    }

    @ReactMethod
    fun startStreaming(appToken: String, videoToken: String, streamToken: String) {
        rnCameraViewManager.cameraView.startStream(appToken, videoToken, streamToken)
    }

    @ReactMethod
    fun stopStreaming() {
        rnCameraViewManager.cameraView.stopStream()
    }
}