package com.ziggeo.videorview

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp
import com.ziggeo.BaseViewManager
import com.ziggeo.androidsdk.callbacks.PlayerCallback
import com.ziggeo.androidsdk.callbacks.RecorderCallback
import com.ziggeo.androidsdk.log.ZLog
import com.ziggeo.androidsdk.widgets.cameraview.CameraView
import com.ziggeo.androidsdk.widgets.videoview.ZVideoView
import com.ziggeo.utils.ConversionUtil
import com.ziggeo.utils.Events
import com.ziggeo.utils.Keys
import java.util.*

/**
 * Created by Alexander Bedulin on 22-May-20.
 * Ziggeo, Inc.
 * alexb@ziggeo.com
 */
class RnVideoViewManager(reactContext: ReactApplicationContext) : BaseViewManager<RnVideoView>() {
    lateinit var videoView: RnVideoView
        private set

    override fun getName() = "ZVideoViewManager"

    init {
        context = reactContext
    }

    override fun createViewInstance(reactContext: ThemedReactContext): RnVideoView {
        videoView = RnVideoView(reactContext)
        context.addLifecycleEventListener(videoView)
        videoView.loadConfigs()
        videoView.initViews()
        initCallbacks()
        return videoView
    }

    @ReactProp(name = "uris")
    fun setUris(cameraView: RnVideoView, uris: ReadableArray?) {
        uris?.let {
            videoView.videoTokens = ConversionUtil.toList(it).filterIsInstance<String>()
        }
    }

    @ReactProp(name = "tokens")
    fun setTokens(cameraView: RnVideoView, tokens: ReadableArray?) {
        tokens?.let {
            videoView.videoTokens = ConversionUtil.toList(it).filterIsInstance<String>()
        }
    }

    private fun initCallbacks() {
        videoView.playerConfig.callback = object : PlayerCallback() {
            override fun error(throwable: Throwable) {
                super.error(throwable)
                val params = Arguments.createMap()
                params.putString(Keys.ERROR, throwable.toString())
                sendEvent(Events.ERROR, params)
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
                val params = Arguments.createMap()
                params.putDouble(Keys.MILLIS, millis.toDouble())
                sendEvent(Events.SEEK, params)
            }

            override fun readyToPlay() {
                super.readyToPlay()
                sendEvent(Events.READY_TO_PLAY)
            }
        }
    }
}