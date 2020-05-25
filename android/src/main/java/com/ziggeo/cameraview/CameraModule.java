package com.ziggeo.cameraview;


import com.facebook.react.bridge.ReactApplicationContext;
import com.ziggeo.BaseModule;

/**
 * Created by alex on 6/25/2017.
 */

public class CameraModule extends BaseModule {

    public CameraModule(final ReactApplicationContext reactContext, RnCameraViewManager rnCameraViewManager) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "Camera";
    }

}
