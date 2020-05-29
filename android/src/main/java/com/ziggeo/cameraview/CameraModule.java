package com.ziggeo.cameraview;


import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.ziggeo.BaseModule;

/**
 * Created by alex on 6/25/2017.
 */

public class CameraModule extends BaseModule {

    private RnCameraViewManager rnCameraViewManager;

    public CameraModule(final ReactApplicationContext reactContext, RnCameraViewManager rnCameraViewManager) {
        super(reactContext);
        this.rnCameraViewManager = rnCameraViewManager;
    }

    @Override
    public String getName() {
        return "Camera";
    }

    @ReactMethod
    public void startRecording(@NonNull String path, int maxDurationMillis) {
        rnCameraViewManager.getCameraView().startRecording(path, maxDurationMillis);
    }

    @ReactMethod
    public void stopRecording() {
        rnCameraViewManager.getCameraView().stopRecording();
    }

    @ReactMethod
    public void startStreaming(@NonNull String appToken,
                               @NonNull String videoToken,
                               @NonNull String streamToken) {
        rnCameraViewManager.getCameraView().startStream(appToken, videoToken, streamToken);
    }

    @ReactMethod
    public void stopStreaming() {
        rnCameraViewManager.getCameraView().stopStream();
    }

}
