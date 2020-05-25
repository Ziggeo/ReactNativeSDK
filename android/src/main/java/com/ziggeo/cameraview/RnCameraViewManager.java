package com.ziggeo.cameraview;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.ziggeo.androidsdk.widgets.cameraview.CameraView;

public class RnCameraViewManager extends SimpleViewManager<RnCameraView> {

    private ReactApplicationContext callerContext;

    @Override
    public String getName() {
        return "CameraView";
    }

    public RnCameraViewManager(ReactApplicationContext reactContext) {
        callerContext = reactContext;
    }

    @Override
    protected RnCameraView createViewInstance(ThemedReactContext reactContext) {
        RnCameraView cameraView = new RnCameraView(reactContext);
        callerContext.addLifecycleEventListener(cameraView);
        return cameraView;
    }
}
