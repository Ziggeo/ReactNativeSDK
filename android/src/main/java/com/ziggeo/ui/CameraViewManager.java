package com.ziggeo.ui;

import androidx.annotation.NonNull;

import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.ziggeo.androidsdk.widgets.cameraview.CameraView;

public class CameraViewManager extends SimpleViewManager<CameraView> {

    private static final String TAG = CameraViewManager.class.getSimpleName();
    public static final String NAME = "camera_view";

    @Override
    public String getName() {
        return NAME;
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