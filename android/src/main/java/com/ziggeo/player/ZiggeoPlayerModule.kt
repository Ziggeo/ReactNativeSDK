package com.ziggeo.player

import com.ziggeo.*
import android.net.Uri
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.Callback;
import com.ziggeo.BaseModule
import com.ziggeo.androidsdk.log.ZLog
import com.ziggeo.utils.ConversionUtil.dataFromPlayerStyle
import com.ziggeo.utils.ConversionUtil
import com.ziggeo.utils.ThemeKeys

import com.facebook.react.bridge.Promise
import com.ziggeo.tasks.SimpleTask
import com.ziggeo.tasks.Task

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
    fun playVideo(videoToken: String) {
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
            if (it.hasKey(ThemeKeys.KEY_PLAYER_CONTROLLER_STYLE)) {
                val controllerStyle = it.getInt(ThemeKeys.KEY_PLAYER_CONTROLLER_STYLE)
                ziggeo.playerConfig.style.controllerStyle = controllerStyle
            }
            if (it.hasKey(ThemeKeys.KEY_PLAYER_TEXT_COLOR)) {
                val textColor = it.getInt(ThemeKeys.KEY_PLAYER_TEXT_COLOR)
                ziggeo.playerConfig.style.textColor = textColor
            }
            if (it.hasKey(ThemeKeys.KEY_PLAYER_UNPLAYED_COLOR)) {
                val unplayedColor = it.getInt(ThemeKeys.KEY_PLAYER_UNPLAYED_COLOR)
                ziggeo.playerConfig.style.unplayedColor = unplayedColor
            }
            if (it.hasKey(ThemeKeys.KEY_PLAYER_PLAYED_COLOR)) {
                val playedColor = it.getInt(ThemeKeys.KEY_PLAYER_PLAYED_COLOR)
                ziggeo.playerConfig.style.playedColor = playedColor
            }
            if (it.hasKey(ThemeKeys.KEY_PLAYER_BUFFERED_COLOR)) {
                val bufferedColor = it.getInt(ThemeKeys.KEY_PLAYER_BUFFERED_COLOR)
                ziggeo.playerConfig.style.bufferedColor = bufferedColor
            }
            if (it.hasKey(ThemeKeys.KEY_PLAYER_TINT_COLOR)) {
                val tintColor = it.getInt(ThemeKeys.KEY_PLAYER_TINT_COLOR)
                ziggeo.playerConfig.style.tintColor = tintColor
            }
            if (it.hasKey(ThemeKeys.KEY_PLAYER_MUTE_OFF_DRAWABLE)) {
                val muteOffImageDrawable = it.getInt(ThemeKeys.KEY_PLAYER_MUTE_OFF_DRAWABLE)
                ziggeo.playerConfig.style.muteOffImageDrawable = muteOffImageDrawable
            }
            if (it.hasKey(ThemeKeys.KEY_PLAYER_MUTE_ON_DRAWABLE)) {
                val muteOnImageDrawable = it.getInt(ThemeKeys.KEY_PLAYER_MUTE_ON_DRAWABLE)
                ziggeo.playerConfig.style.muteOnImageDrawable = muteOnImageDrawable
            }
        }
    }

    @ReactMethod
    fun setAdsURL(url: String) {
        ZLog.d("setAdsURL:%s", url)
        ziggeo.playerConfig.adsUri = Uri.parse(url);
    }

    //getters
    @ReactMethod
    fun getAppToken(promise: Promise) {
        val task: Task = SimpleTask(promise)
        resolve(task, ziggeo.appToken)
    }

    @ReactMethod
    fun getClientAuthToken(promise: Promise) {
        val task: Task = SimpleTask(promise)
        resolve(task, ziggeo.getClientAuthToken());
    }

    @ReactMethod
    fun getServerAuthToken(promise: Promise) {
        val task: Task = SimpleTask(promise)
        resolve(task, ziggeo.getServerAuthToken());
    }

    @ReactMethod
    fun getThemeArgsForPlayer(promise: Promise){
        val task: Task = SimpleTask(promise)
        resolve(task, dataFromPlayerStyle(ziggeo.playerConfig.style));
    }

    @ReactMethod
    fun getAdsURL(promise: Promise){
        val task: Task = SimpleTask(promise)
        resolve(task, ziggeo.playerConfig.adsUri.toString());
    }
}
