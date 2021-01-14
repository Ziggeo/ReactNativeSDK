package com.ziggeo.player

import android.net.Uri
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.ziggeo.BaseModule
import com.ziggeo.androidsdk.log.ZLog
import com.ziggeo.utils.ConversionUtil
import com.ziggeo.utils.ThemeKeys

/**
 * Created by alex on 6/25/2017.
 */
class ZiggeoPlayerModule(reactContext: ReactApplicationContext) : BaseModule(reactContext) {
    override fun getName() = "ZiggeoPlayer"

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
    fun play(videoToken: String) {
        ziggeo.startPlayer(videoToken)
    }

    @ReactMethod
    fun playFromUri(path_or_uri: String) {
        ziggeo.startPlayer(Uri.parse(path_or_uri))
    }

    @ReactMethod
    fun setExtraArgsForPlayer(readableMap: ReadableMap?) {
        ZLog.d("setExtraArgsForPlayer:%s", readableMap)
        ziggeo.playerConfig.extraArgs = ConversionUtil.toMap(readableMap)
    }

    @ReactMethod
    fun setThemeArgsForPlayer(data: ReadableMap?) {
        data?.let {
            if (it.hasKey(ThemeKeys.KEY_HIDE_PLAYER_CONTROLS)) {
                val hideControls = it.getBoolean(ThemeKeys.KEY_HIDE_PLAYER_CONTROLS)
                ziggeo.playerConfig.style.isHideControls = hideControls
            }
        }
    }

    @ReactMethod
    fun setAdsURL(url: String) {
        ZLog.d("setAdsURL:%s", url)
        ziggeo.playerConfig.adsUri = Uri.parse(url);
    }
}