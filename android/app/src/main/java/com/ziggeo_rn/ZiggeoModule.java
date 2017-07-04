package com.ziggeo_rn;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.ziggeo.androidsdk.IZiggeo;
import com.ziggeo.androidsdk.Ziggeo;
import com.ziggeo.androidsdk.recording.VideoRecordingCallback;
import com.ziggeo.androidsdk.widgets.cameraview.CameraView;

import java.util.HashMap;
import java.util.Map;

import okhttp3.Callback;

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
    public void setVideoRecordingProcessCallback(@Nullable VideoRecordingCallback videoRecordingCallback) {
        Log.d(TAG, "setVideoRecordingProcessCallback:" + videoRecordingCallback);
        //TODO replace with js related callback
    }

    @ReactMethod
    public void setNetworkRequestsCallback(@Nullable Callback callback) {
        Log.d(TAG, "setNetworkRequestsCallback:" + callback);
        //TODO replace with js related callback
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