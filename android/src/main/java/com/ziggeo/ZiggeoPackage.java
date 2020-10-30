package com.ziggeo;

import androidx.annotation.NonNull;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;
import com.ziggeo.api.VideosModule;
import com.ziggeo.cameraview.CameraModule;
import com.ziggeo.cameraview.RnCameraViewManager;
import com.ziggeo.contactus.ContactUs;
import com.ziggeo.player.ZiggeoPlayerModule;
import com.ziggeo.recorder.ZiggeoRecorderModule;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by alex on 6/25/2017.
 */

public class ZiggeoPackage implements ReactPackage {

    private RnCameraViewManager rnCameraViewManager;

    @Override
    public List<NativeModule> createNativeModules(@NonNull ReactApplicationContext reactContext) {
        initCameraManager(reactContext);
        List<NativeModule> modules = new ArrayList<>();
        modules.add(new ZiggeoRecorderModule(reactContext));
        modules.add(new ZiggeoPlayerModule(reactContext));
        modules.add(new VideosModule(reactContext));
        modules.add(new ContactUs(reactContext));
        modules.add(new CameraModule(reactContext, rnCameraViewManager));
        return modules;
    }

    @Override
    public List<ViewManager> createViewManagers(@NonNull ReactApplicationContext reactContext) {
        List<ViewManager> modules = new ArrayList<>();
        modules.add(rnCameraViewManager);
        return modules;
    }

    private void initCameraManager(@NonNull ReactApplicationContext context) {
        if (rnCameraViewManager == null) {
            rnCameraViewManager = new RnCameraViewManager(context);
        }
    }

}
