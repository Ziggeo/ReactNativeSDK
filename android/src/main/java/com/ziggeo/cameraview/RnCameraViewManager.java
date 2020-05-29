package com.ziggeo.cameraview;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.ziggeo.androidsdk.log.ZLog;
import com.ziggeo.androidsdk.widgets.cameraview.CameraView;
import com.ziggeo.androidsdk.widgets.cameraview.Size;

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

    @ReactProp(name = "autoFocus")
    public void setAutoFocus(@NonNull CameraView cameraView, boolean autoFocus) {
        cameraView.setAutoFocus(autoFocus);
    }

    @ReactProp(name = "flash")
    public void setFlash(@NonNull CameraView cameraView, @CameraView.Flash int flash) {
        cameraView.setFlash(flash);
    }

    @ReactProp(name = "resolution")
    public void setResolution(@NonNull CameraView cameraView, ReadableArray array) {
        cameraView.setResolution(new Size(array.getInt(0), array.getInt(1)));
    }

    @ReactProp(name = "videoBitrate")
    public void setVideoBitrate(@NonNull CameraView cameraView, int bitrate) {
        cameraView.setVideoBitrate(bitrate);
    }

    @ReactProp(name = "audioBitrate")
    public void setAudioBitrate(@NonNull CameraView cameraView, int bitrate) {
        cameraView.setAudioBitrate(bitrate);
    }

    @ReactProp(name = "audioSampleRate")
    public void setAudioSampleRate(@NonNull CameraView cameraView, int sampleRate) {
        cameraView.setAudioSampleRate(sampleRate);
    }
}
