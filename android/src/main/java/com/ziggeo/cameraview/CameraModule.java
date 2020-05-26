package com.ziggeo.cameraview;


import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.ziggeo.BaseModule;
import com.ziggeo.androidsdk.log.ZLog;

/**
 * Created by alex on 6/25/2017.
 */

public class CameraModule extends BaseModule {

    private RnCameraView cameraView;

    public CameraModule(final ReactApplicationContext reactContext, RnCameraViewManager rnCameraViewManager) {
        super(reactContext);
        cameraView = rnCameraViewManager.getCameraView();
    }

    @Override
    public String getName() {
        return "Camera";
    }

    @ReactMethod
    public void startRecording(@NonNull String path, int maxDurationMillis) {
        cameraView.startRecording(path, maxDurationMillis);
    }

    @ReactMethod
    public void stopRecording() {
        cameraView.stopRecording();
    }

}
