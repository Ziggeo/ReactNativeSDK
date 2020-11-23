package com.ziggeo.cameraview

import android.content.Context
import com.facebook.react.bridge.LifecycleEventListener
import com.ziggeo.androidsdk.widgets.cameraview.CameraView

/**
 * Created by Alexander Bedulin on 22-May-20.
 * Ziggeo, Inc.
 * alexb@ziggeo.com
 */
class RnCameraView(context: Context?) : CameraView(context), LifecycleEventListener {
    override fun onHostResume() {
        start()
    }

    override fun onHostPause() {
        stop()
    }

    override fun onHostDestroy() {
        stop()
    }
}