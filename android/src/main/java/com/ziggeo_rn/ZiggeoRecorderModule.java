package com.ziggeo_rn;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.google.gson.Gson;
import com.ziggeo.androidsdk.IZiggeo;
import com.ziggeo.androidsdk.Ziggeo;
import com.ziggeo.androidsdk.net.rest.ProgressCallback;
import com.ziggeo.androidsdk.recording.VideoRecordingCallback;
import com.ziggeo.androidsdk.widgets.cameraview.CameraView;
import com.ziggeo_rn.models.ResponseModel;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CountDownLatch;

import okhttp3.Call;
import okhttp3.Response;

/**
 * Created by alex on 6/25/2017.
 */

public class ZiggeoRecorderModule extends ReactContextBaseJavaModule {

    private static final String TAG = ZiggeoRecorderModule.class.getSimpleName();

    public static final String REAR_CAMERA = "rearCamera";
    public static final String FRONT_CAMERA = "frontCamera";
    public static final String PROGRESS_VALUE = "progress";
    public static final String EVENT_PROGRESS = "UploadProgress";
    public static final String EVENT_RECORDING_STARTED = "RecordingStarted";
    public static final String EVENT_RECORDING_STOPPED = "RecordingStopped";

    public static final String ERROR_CODE_UNKNOWN = "-1";

    private IZiggeo ziggeo;
    private String recordedVideoToken;

    public ZiggeoRecorderModule(final ReactApplicationContext reactContext) {
        super(reactContext);
        ziggeo = new Ziggeo(reactContext.getApplicationContext());
        ziggeo.setSendImmediately(false);
    }

    @Override
    public String getName() {
        return "ZiggeoRecorder";
    }

    @ReactMethod
    public void setAppToken(@NonNull String appToken) {
        Log.d(TAG, "setAppToken:" + appToken);
        ziggeo.setAppToken(appToken);
        sendEvent(getReactApplicationContext(), "TestEvent", null);
    }

    @ReactMethod
    public void setAutostartRecordingAfter(int seconds) {
        final long millis = seconds * 1000;
        Log.d(TAG, "setAutostartRecordingAfter:" + millis);
        ziggeo.setAutostartRecordingAfter(millis);
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
    private void setCamera(int camera) {
        Log.d(TAG, "setCamera:" + camera);
        ziggeo.setPreferredCameraFacing(camera);
    }

    @ReactMethod
    public void record(final Promise promise) {
        final ReactContext context = getReactApplicationContext();
        final CountDownLatch latch = new CountDownLatch(1);
        recordedVideoToken = null;

        ziggeo.setNetworkRequestsCallback(new ProgressCallback() {
            @Override
            public void onProgressUpdate(int progress) {
                WritableMap params = Arguments.createMap();
                params.putInt(PROGRESS_VALUE, progress);
                sendEvent(context, EVENT_PROGRESS, params);
            }

            @Override
            public void onFailure(Call call, IOException e) {
                Log.e(TAG, "onFailure:" + e.toString());
                promise.reject(ERROR_CODE_UNKNOWN, e.toString());
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                final String responseString = response.body().string();
                response.body().close();
                Log.d(TAG, "onResponse:" + response.toString());
                Log.d(TAG, "onResponse: BodyString:" + responseString);
                if (!TextUtils.isEmpty(responseString)) {
                    Gson gson = new Gson();
                    ResponseModel model = gson.fromJson(responseString, ResponseModel.class);
                    recordedVideoToken = model.getVideo().getToken();
                    latch.countDown();
                } else {
                    promise.reject(String.valueOf(response.code()), response.message());
                }
            }
        });
        ziggeo.setVideoRecordingProcessCallback(new VideoRecordingCallback() {
            @Override
            public void onStarted() {
                Log.d(TAG, "onStarted");
                sendEvent(context, EVENT_RECORDING_STARTED, null);
            }

            @Override
            public void onStopped(@NonNull String s) {
                Log.d(TAG, "onStopped");
                sendEvent(context, EVENT_RECORDING_STOPPED, null);
            }

            @Override
            public void onError() {
                Log.e(TAG, "onError");
                promise.reject(ERROR_CODE_UNKNOWN, "");
            }
        });

        ziggeo.startRecorder();
        try {
            latch.await();
        } catch (InterruptedException e) {
            Log.e(TAG, e.toString());
        }
        promise.resolve(recordedVideoToken);
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
        constants.put(REAR_CAMERA, CameraView.FACING_BACK);
        constants.put(FRONT_CAMERA, CameraView.FACING_FRONT);
        return constants;
    }

    private void sendEvent(ReactContext reactContext, String eventName, @Nullable WritableMap params) {
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }
}