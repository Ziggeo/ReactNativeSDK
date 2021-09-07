package com.ziggeo.videorview

import android.content.Context
import com.facebook.react.bridge.LifecycleEventListener
import com.ziggeo.androidsdk.widgets.videoview.ZVideoView

/**
 * Created by Alexander Bedulin on 22-May-20.
 * Ziggeo, Inc.
 * alexb@ziggeo.com
 */
class RnVideoView(context: Context?) : ZVideoView(context), LifecycleEventListener {
    override fun onHostResume() {
        onResume()
    }

    override fun onHostPause() {
        onPause()
    }

    override fun onHostDestroy() {
        onPause()
    }
}