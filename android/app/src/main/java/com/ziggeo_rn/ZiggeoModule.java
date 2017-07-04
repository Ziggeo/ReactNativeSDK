package com.ziggeo_rn;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.Log;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.ziggeo.androidsdk.IZiggeo;
import com.ziggeo.androidsdk.Ziggeo;
import com.ziggeo.androidsdk.net.rest.ProgressCallback;
import com.ziggeo.androidsdk.recording.VideoRecordingCallback;
import com.ziggeo.androidsdk.widgets.cameraview.CameraView;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import okhttp3.Call;
import okhttp3.Response;

/**
 * Created by alex on 6/25/2017.
 */

public class ZiggeoModule extends ReactContextBaseJavaModule {

    private static final String TAG = ZiggeoModule.class.getSimpleName();

    public static final String FACING_BACK = "BACK";
    public static final String FACING_FRONT = "FRONT";

    private IZiggeo ziggeo;

    public ZiggeoModule(final ReactApplicationContext reactContext) {
        super(reactContext);
        ziggeo = new Ziggeo(reactContext.getApplicationContext());
        ziggeo.setSendImmediately(false);
    }

    @Override
    public String getName() {
        return "ZiggeoAndroid";
    }

    @ReactMethod
    public void setAppToken(@NonNull String appToken) {
        Log.d(TAG, "setAppToken:" + appToken);
        ziggeo.setAppToken(appToken);
    }

    @ReactMethod
    public void setAutostartRecordingAfter(int seconds) {
        final long millis = seconds * 1000;
        Log.d(TAG, "setAutostartRecordingAfter:" + millis);
        ziggeo.setAutostartRecordingAfter(millis);
    }

    @ReactMethod
    public void setVideoRecordingProcessCallback(@Nullable final Callback startCallback,
                                                 @Nullable final Callback stopCallback,
                                                 @Nullable final Callback errorCallback) {
        Log.d(TAG, "setVideoRecordingProcessCallback:" + startCallback + ":" + stopCallback + ":" + errorCallback);
        ziggeo.setVideoRecordingProcessCallback(new VideoRecordingCallback() {
            @Override
            public void onStarted() {
                if (startCallback != null) {
                    startCallback.invoke();
                }
            }

            @Override
            public void onStopped(@NonNull String path) {
                if (stopCallback != null) {
                    stopCallback.invoke(path);
                }
            }

            @Override
            public void onError() {
                if (errorCallback != null) {
                    errorCallback.invoke();
                }
            }
        });
    }

    @ReactMethod
    public void setNetworkRequestsCallback(@Nullable final Callback progressCallback,
                                           @Nullable final Callback successCallback,
                                           @Nullable final Callback errorCallback) {
        Log.d(TAG, "setNetworkRequestsCallback:" + progressCallback + ":" + successCallback + ":" + errorCallback);
        ziggeo.setNetworkRequestsCallback(new ProgressCallback() {
            @Override
            public void onProgressUpdate(int i) {
                if (progressCallback != null) {
                    progressCallback.invoke(i);
                }
            }

            @Override
            public void onFailure(Call call, IOException e) {
                if (errorCallback != null) {
                    errorCallback.invoke(call.request().url(), e.toString());
                }
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                if (successCallback != null) {
                    successCallback.invoke(response.body().string());
                }
            }
        });
    }

    @ReactMethod
    public void setExtraArgsForCreateVideo(ReadableMap readableMap) {
        Log.d(TAG, "setExtraArgsForCreateVideo:" + readableMap);
        ziggeo.setExtraArgsForCreateVideo(ConversionUtil.toMap(readableMap));
    }

    @ReactMethod
    public void setCoverSelectorEnabled(boolean enabled) {
        Log.d(TAG, "setCoverSelectorEnabled:" + enabled);
        ziggeo.setCoverSelectorEnabled(enabled);
    }

    @ReactMethod
    public void setMaxRecordingDuration(int maxDurationSeconds) {
        final long millis = maxDurationSeconds * 1000;
        Log.d(TAG, "setMaxRecordingDuration:" + millis);
        ziggeo.setMaxRecordingDuration(millis);
    }

    @ReactMethod
    public void setPreferredCameraFacing(int facing) {
        Log.d(TAG, "setPreferredCameraFacing:" + facing);
        ziggeo.setPreferredCameraFacing(facing);
    }

    @ReactMethod
    public void setCameraSwitchEnabled(boolean enabled) {
        Log.d(TAG, "setCameraSwitchEnabled:" + enabled);
        ziggeo.setCameraSwitchDisabled(!enabled);
    }

    @ReactMethod
    public void setSendImmediately(boolean sendImmediately) {
        Log.d(TAG, "setSendImmediately:" + sendImmediately);
        ziggeo.setSendImmediately(sendImmediately);
    }

    @ReactMethod
    public void startRecorder() {
        Log.d(TAG, "startRecorder");
        ziggeo.startRecorder();
    }

    @ReactMethod
    public void cancelRequest() {
        Log.d(TAG, "cancelRequest");
        ziggeo.cancelRequest();
    }

    @Nullable
    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put(FACING_BACK, CameraView.FACING_BACK);
        constants.put(FACING_FRONT, CameraView.FACING_FRONT);
        return constants;
    }

}