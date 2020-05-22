package com.ziggeo.ui;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.ziggeo.androidsdk.widgets.cameraview.CameraView;

public class CameraRnManager extends SimpleViewManager<RnCameraView> {

    public static final String NAME = CameraView.class.getSimpleName();
    private ReactApplicationContext callerContext;

    @Override
    public String getName() {
        return NAME;
    }

    public CameraRnManager(ReactApplicationContext reactContext) {
        callerContext = reactContext;
    }

    @Override
    protected RnCameraView createViewInstance(ThemedReactContext reactContext) {
        RnCameraView cameraView = new RnCameraView(reactContext);
        callerContext.addLifecycleEventListener(cameraView);
        return cameraView;
    }

}
