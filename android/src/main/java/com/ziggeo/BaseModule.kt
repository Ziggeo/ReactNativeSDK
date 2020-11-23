package com.ziggeo

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter
import com.google.gson.Gson
import com.ziggeo.androidsdk.Ziggeo
import com.ziggeo.androidsdk.log.ZLog
import com.ziggeo.tasks.Task

abstract class BaseModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
    protected var ziggeo: Ziggeo = Ziggeo.getInstance(reactContext.applicationContext)
    protected var gson: Gson = Gson()

    @ReactMethod
    open fun setClientAuthToken(token: String) {
        ziggeo.clientAuthToken = token
    }

    @ReactMethod
    open fun setServerAuthToken(token: String) {
        ziggeo.serverAuthToken = token
    }

    fun sendEvent(eventName: String) {
        reactApplicationContext
                .getJSModule(RCTDeviceEventEmitter::class.java)
                .emit(eventName, null)
    }

    fun sendEvent(eventName: String, params: WritableMap?) {
        reactApplicationContext
                .getJSModule(RCTDeviceEventEmitter::class.java)
                .emit(eventName, params)
    }

    fun resolve(task: Task, obj: Any?) {
        task.resolve(obj)
    }

    fun reject(task: Task, err: String) {
        task.reject(err)
    }

    fun reject(task: Task, err: String, message: String?) {
        task.reject(err, message)
    }

    fun cancel(task: Task) {
        val message = "Cancelled by the user."
        ZLog.d(message)
        reject(task, ERR_CANCELLED, message)
    }

    companion object {
        private const val ERR_CANCELLED = "ERR_CANCELLED"
    }

}