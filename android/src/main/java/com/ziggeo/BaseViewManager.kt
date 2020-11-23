package com.ziggeo

import android.view.View
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter
import com.facebook.react.uimanager.SimpleViewManager

/**
 * Created by Alexander Bedulin on 02-Jun-20.
 * Ziggeo, Inc.
 * alexb@ziggeo.com
 */
abstract class BaseViewManager<T : View?> : SimpleViewManager<T>() {
    protected lateinit var context: ReactApplicationContext
    fun sendEvent(eventName: String) {
        this.sendEvent(eventName, null)
    }

    fun sendEvent(eventName: String, params: WritableMap?) {
        context.getJSModule(RCTDeviceEventEmitter::class.java)
                .emit(eventName, params)
    }
}