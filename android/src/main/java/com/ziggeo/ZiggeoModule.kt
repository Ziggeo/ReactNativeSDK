package com.ziggeo

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.ziggeo.utils.ConversionUtil

class ZiggeoModule(reactContext: ReactApplicationContext) : BaseModule(reactContext) {
    override fun getName() = "Ziggeo"

    //TODO remove those methods from base module
    @ReactMethod
    override fun setClientAuthToken(token: String) {
        super.setClientAuthToken(token)
    }

    @ReactMethod
    fun getClientAuthToken(): String? {
        return ziggeo.clientAuthToken
    }

    @ReactMethod
    override fun setServerAuthToken(token: String) {
        super.setServerAuthToken(token)
    }

    @ReactMethod
    fun getServerAuthToken(): String? {
        return ziggeo.serverAuthToken
    }

    @ReactMethod
    fun setQrScannerConfig(data: ReadableMap?) {
        data?.let {
            ziggeo.qrScannerConfig = ConversionUtil.dataQrScannerConfig(it)
        }
    }

    @ReactMethod
    fun startQrScanner() {
        ziggeo.startQrScanner()
    }

    @ReactMethod
    fun setFileSelectorConfig(data: ReadableMap?) {
        data?.let {
            ziggeo.fileSelectorConfig = ConversionUtil.dataToFileSelectorConfig(it, reactApplicationContext)
        }
    }

    @ReactMethod
    fun startFileSelector() {
        ziggeo.startFileSelector()
    }

    @ReactMethod
    fun setRecorderConfig(data: ReadableMap?) {
        data?.let {
            ziggeo.recorderConfig = ConversionUtil.dataToRecorderConfig(it, reactApplicationContext)
        }
    }

    @ReactMethod
    fun startCameraRecorder() {
        ziggeo.startCameraRecorder()
    }

    @ReactMethod
    fun startScreenRecorder() {
        ziggeo.startScreenRecorder(null)
    }

}