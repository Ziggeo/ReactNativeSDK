package com.ziggeo.cameraview;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.ziggeo.BaseViewManager;
import com.ziggeo.androidsdk.callbacks.RecorderCallback;
import com.ziggeo.androidsdk.log.ZLog;
import com.ziggeo.androidsdk.widgets.cameraview.CameraView;
import com.ziggeo.androidsdk.widgets.cameraview.Size;
import com.ziggeo.utils.Events;
import com.ziggeo.utils.Keys;

import static com.ziggeo.utils.Events.ERROR;

public class RnCameraViewManager extends BaseViewManager<RnCameraView> {

    private RnCameraView cameraView;

    @Override
    public String getName() {
        return "ZiggeoCameraView";
    }

    public RnCameraViewManager(ReactApplicationContext reactContext) {
        context = reactContext;
    }

    public RnCameraView getCameraView() {
        return cameraView;
    }

    @Override
    protected RnCameraView createViewInstance(ThemedReactContext reactContext) {
        cameraView = new RnCameraView(reactContext);
        context.addLifecycleEventListener(cameraView);
        initCallbacks();
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

    private void initCallbacks() {
        cameraView.setCameraCallback(new CameraView.CameraCallback() {
            @Override
            public void cameraOpened() {
                super.cameraOpened();
                ZLog.d(Events.EVENT_CAMERA_OPENED);

                sendEvent(Events.EVENT_CAMERA_OPENED, null);
            }

            @Override
            public void cameraClosed() {
                super.cameraClosed();
                sendEvent(Events.EVENT_CAMERA_CLOSED, null);
            }
        });

        cameraView.setRecorderCallback(new RecorderCallback() {
            @Override
            public void error(@NonNull Throwable throwable) {
                super.error(throwable);
                WritableMap params = Arguments.createMap();
                params.putString(ERROR, throwable.toString());
                sendEvent(ERROR, params);
            }

            @Override
            public void recordingStarted() {
                super.recordingStarted();
                sendEvent(Events.EVENT_RECORDING_STARTED, null);
            }

            @Override
            public void recordingStopped(@NonNull String path) {
                super.recordingStopped(path);
                WritableMap params = Arguments.createMap();
                params.putString(Keys.PATH, path);
                sendEvent(Events.EVENT_RECORDING_STOPPED, params);
            }

            @Override
            public void streamingStarted() {
                super.streamingStarted();
                sendEvent(Events.EVENT_STREAMING_STARTED, null);
            }

            @Override
            public void streamingStopped() {
                super.streamingStopped();
                sendEvent(Events.EVENT_STREAMING_STOPPED, null);
            }
        });
    }

}
