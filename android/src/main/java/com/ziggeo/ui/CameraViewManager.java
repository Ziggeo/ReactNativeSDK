package com.ziggeo.ui;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.ziggeo.androidsdk.widgets.cameraview.CameraView;

public class CameraViewManager extends SimpleViewManager<CameraView> {

    public static final String NAME = CameraView.class.getSimpleName();
    ReactApplicationContext callerContext;

    @Override
    public String getName() {
        return NAME;
    }

    public CameraViewManager(ReactApplicationContext reactContext) {
        callerContext = reactContext;
    }

    @Override
    protected CameraView createViewInstance(ThemedReactContext reactContext) {
        CameraView cameraView = new CameraView(reactContext);
        cameraView.start();
        return cameraView;
    }

    @Override
    public void onDropViewInstance(@NonNull CameraView view) {
        view.stop();
        super.onDropViewInstance(view);
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
