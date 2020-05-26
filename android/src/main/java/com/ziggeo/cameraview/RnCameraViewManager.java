package com.ziggeo.cameraview;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.ziggeo.androidsdk.widgets.cameraview.CameraView;

public class RnCameraViewManager extends SimpleViewManager<RnCameraView> {

    private ReactApplicationContext callerContext;
    private RnCameraView cameraView;
    @Override
    public String getName() {
        return "ZiggeoCameraView";
    }

    public RnCameraViewManager(ReactApplicationContext reactContext) {
        callerContext = reactContext;
    }

    public RnCameraView getCameraView() {
        return cameraView;
    }

    @Override
    protected RnCameraView createViewInstance(ThemedReactContext reactContext) {
        cameraView = new RnCameraView(reactContext);
        callerContext.addLifecycleEventListener(cameraView);
        return cameraView;
    }

    @ReactProp(name = "facing")
    public void setFacing(@NonNull CameraView cameraView, @CameraView.Facing int facing) {
        cameraView.setFacing(facing);
    }

    @ReactProp(name = "quality")
    public void setQuality(@NonNull CameraView cameraView, @CameraView.Quality int quality) {
        cameraView.setQuality(quality);
    }
}
