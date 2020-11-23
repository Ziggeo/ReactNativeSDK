package com.ziggeo

import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ViewManager
import com.ziggeo.api.VideosModule
import com.ziggeo.cameraview.CameraModule
import com.ziggeo.cameraview.RnCameraViewManager
import com.ziggeo.contactus.ContactUsModule
import com.ziggeo.player.ZiggeoPlayerModule
import com.ziggeo.recorder.ZiggeoRecorderModule
import java.util.*

/**
 * Created by alex on 6/25/2017.
 */
class ZiggeoPackage : ReactPackage {
    private var rnCameraViewManager: RnCameraViewManager? = null
    override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> {
        initCameraManager(reactContext)
        val modules: MutableList<NativeModule> = ArrayList()
        modules.add(ZiggeoRecorderModule(reactContext))
        modules.add(ZiggeoPlayerModule(reactContext))
        modules.add(VideosModule(reactContext))
        modules.add(ContactUsModule(reactContext))
        modules.add(CameraModule(reactContext, rnCameraViewManager!!))
        return modules
    }

    override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>?> {
        val modules: MutableList<ViewManager<*, *>?> = ArrayList()
        modules.add(rnCameraViewManager)
        return modules
    }

    private fun initCameraManager(context: ReactApplicationContext) {
        if (rnCameraViewManager == null) {
            rnCameraViewManager = RnCameraViewManager(context)
        }
    }
}