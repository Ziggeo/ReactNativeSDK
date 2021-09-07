package com.ziggeo.videorview

import android.content.Context
import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.ziggeo.BaseModule
import com.ziggeo.androidsdk.widgets.cameraview.CameraView
import com.ziggeo.androidsdk.widgets.videoview.ZVideoView
import com.ziggeo.cameraview.RnCameraViewManager

/**
 * Created by Alexander Bedulin on 22-May-20.
 * Ziggeo, Inc.
 * alexb@ziggeo.com
 */
class VideoViewModule(reactContext: ReactApplicationContext,
                      private val rnCameraViewManager: RnVideoViewManager
) : BaseModule(reactContext) {

    override fun getName() = "ZVideoViewModule"

    @ReactMethod
    fun startPlaying() {
        rnCameraViewManager.videoView.prepareQueueAndStartPlaying()
    }

}