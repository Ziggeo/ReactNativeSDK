package com.ziggeo;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.util.Log;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.google.gson.Gson;
import com.karumi.dexter.Dexter;
import com.karumi.dexter.PermissionToken;
import com.karumi.dexter.listener.PermissionDeniedResponse;
import com.karumi.dexter.listener.PermissionGrantedResponse;
import com.karumi.dexter.listener.PermissionRequest;
import com.karumi.dexter.listener.single.PermissionListener;
import com.ziggeo.androidsdk.IZiggeo;
import com.ziggeo.androidsdk.Ziggeo;
import com.ziggeo.androidsdk.net.rest.ProgressCallback;
import com.ziggeo.androidsdk.recording.VideoRecordingCallback;
import com.ziggeo.androidsdk.widgets.cameraview.CameraView;
import com.ziggeo.models.ResponseModel;
import com.ziggeo.utils.ConversionUtil;
import com.ziggeo.utils.FileUtils;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import okhttp3.Call;
import okhttp3.Response;

/**
 * Created by alex on 6/25/2017.
 */

public class ZiggeoRecorderModule extends ReactContextBaseJavaModule implements ActivityEventListener, LifecycleEventListener {
    private static final int REQUEST_TAKE_GALLERY_VIDEO = 1;

    private static final String TAG = ZiggeoRecorderModule.class.getSimpleName();

    public static final String REAR_CAMERA = "rearCamera";
    public static final String FRONT_CAMERA = "frontCamera";
    public static final String BYTES_SENT = "bytesSent";
    public static final String BYTES_TOTAL = "totalBytes";
    public static final String FILE_NAME = "fileName";
    public static final String EVENT_PROGRESS = "UploadProgress";
    public static final String EVENT_RECORDING_STARTED = "RecordingStarted";
    public static final String EVENT_RECORDING_STOPPED = "RecordingStopped";

    public static final String ERR_UNKNOWN = "ERR_UNKNOWN";
    public static final String ERR_DURATION_EXCEEDED = "ERR_DURATION_EXCEEDED";
    public static final String ERR_CANCELLED = "ERR_CANCELLED";

    private static final String ARG_DURATION = "max_duration";
    private static final String ARG_ENFORCE_DURATION = "enforce_duration";

    private IZiggeo ziggeo;
    private String recordedVideoToken;

    private ReactContext context;
    private Promise promise;
    private boolean rejectOnBack;
    private int maxAllowedDurationInSeconds;
    private boolean enforceDuration;

    public ZiggeoRecorderModule(final ReactApplicationContext reactContext) {
        super(reactContext);
        ziggeo = new Ziggeo(reactContext.getApplicationContext());
        ziggeo.setSendImmediately(false);
        context = reactContext;
        reactContext.addActivityEventListener(this);
        reactContext.addLifecycleEventListener(this);
    }

    @Override
    public String getName() {
        return "ZiggeoRecorder";
    }

    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        Log.d(TAG, "onActivityResult. resultCode:" + resultCode + " data:" + data);
        switch (requestCode) {
            case REQUEST_TAKE_GALLERY_VIDEO:
                if (resultCode == Activity.RESULT_OK) {
                    Uri uri = data.getData();
                    String path = null;

                    if (uri != null) {
                        path = uri.getPath();
                    }
                    if (path == null || !new File(path).exists()) {
                        path = FileUtils.getPath(context, uri);
                    }
                    if (path != null) {
                        uploadFromPath(path, promise);
                    } else {
                        reject(ERR_UNKNOWN, "");
                    }
                }
                break;
        }
    }

    @Override
    public void onNewIntent(Intent intent) {

    }

    @Override
    public void onHostResume() {
        if (rejectOnBack && promise != null) {
            reject(ERR_CANCELLED, "Cancelled by the user.");
        }
    }

    @Override
    public void onHostPause() {

    }

    @Override
    public void onHostDestroy() {

    }

    @ReactMethod
    public void setAppToken(@NonNull String appToken) {
        Log.d(TAG, "setAppToken:" + appToken);
        ziggeo.setAppToken(appToken);
        sendEvent(context, "TestEvent", null);
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
    public void setCamera(int camera) {
        Log.d(TAG, "setCamera:" + camera);
        ziggeo.setPreferredCameraFacing(camera);
    }

    @ReactMethod
    public void record(final Promise promise) {
        rejectOnBack = true;
        this.promise = promise;

        recordedVideoToken = null;

        ziggeo.setNetworkRequestsCallback(new ProgressCallback() {

            @Override
            public void onProgressUpdate(long sent, long total) {
                WritableMap params = Arguments.createMap();
                params.putString(BYTES_SENT, String.valueOf(sent));
                params.putString(BYTES_TOTAL, String.valueOf(total));
                sendEvent(context, EVENT_PROGRESS, params);
            }

            @Override
            public void onFailure(@NonNull Call call, @NonNull IOException e) {
                Log.e(TAG, "onFailure:" + e.toString());
                reject(ERR_UNKNOWN, e.toString());
            }

            @Override
            public void onResponse(@NonNull Call call, @NonNull Response response) throws IOException {
                final String responseString = response.body().string();
                response.close();
                Log.d(TAG, "onResponse:" + response.toString());
                Log.d(TAG, "onResponse: BodyString:" + responseString);
                if (response.isSuccessful() && !TextUtils.isEmpty(responseString)) {
                    Gson gson = new Gson();
                    ResponseModel model = gson.fromJson(responseString, ResponseModel.class);
                    recordedVideoToken = model.getVideo().getToken();
                    resolve(recordedVideoToken);
                } else {
                    reject(String.valueOf(response.code()), response.message());
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
                rejectOnBack = false;
                Log.d(TAG, "onStopped");
                sendEvent(context, EVENT_RECORDING_STOPPED, null);
            }

            @Override
            public void onError() {
                Log.e(TAG, "onError");
                reject(ERR_UNKNOWN, "");
            }
        });

        ziggeo.startRecorder();
    }

    @ReactMethod
    public void cancelRequest() {
        Log.d(TAG, "cancelRequest");
        ziggeo.cancelRequest();
    }

    @ReactMethod
    public void uploadFromFileSelectorWithDurationLimit(final int maxAllowedDurationInSeconds, boolean enforceDuration,
                                                        @NonNull final Promise promise) {
        this.maxAllowedDurationInSeconds = maxAllowedDurationInSeconds;
        this.enforceDuration = enforceDuration;
        uploadFromFileSelector(promise);
    }

    @ReactMethod
    public void uploadFromPath(@NonNull final String path, @NonNull final Promise promise) {
        rejectOnBack = false;
        Dexter.withActivity(getCurrentActivity())
                .withPermission(Manifest.permission.READ_EXTERNAL_STORAGE)
                .withListener(new PermissionListener() {
                    @Override
                    public void onPermissionGranted(PermissionGrantedResponse response) {
                        Log.d(TAG, "onPermissionGranted");
                        final File videoFile = new File(path);
                        if (!videoFile.exists()) {
                            Log.e(TAG, "File does not exist: " + path);
                        } else if (enforceDuration && maxAllowedDurationInSeconds > 0 && FileUtils.getVideoDuration(path, getReactApplicationContext()) > maxAllowedDurationInSeconds) {
                            final String errorMsg = "Video duration is more than allowed.";
                            Log.e(TAG, errorMsg);
                            Log.e(TAG, "Path: " + path);
                            Log.e(TAG, "Duration: " + FileUtils.getVideoDuration(path, getReactApplicationContext()));
                            Log.e(TAG, "Max allowed duration: " + maxAllowedDurationInSeconds);
                            reject(ERR_DURATION_EXCEEDED, errorMsg);
                        } else {
                            Map<String, String> args = new HashMap<>();
                            if (maxAllowedDurationInSeconds > 0) {
                                args.put(ARG_DURATION, String.valueOf(maxAllowedDurationInSeconds));
                                args.put(ARG_ENFORCE_DURATION, String.valueOf(enforceDuration));
                            }
                            ziggeo.videos().create(videoFile, args, new ProgressCallback() {
                                @Override
                                public void onProgressUpdate(long sent, long total) {
                                    WritableMap params = Arguments.createMap();
                                    params.putString(BYTES_SENT, String.valueOf(sent));
                                    params.putString(BYTES_TOTAL, String.valueOf(total));
                                    params.putString(FILE_NAME, path);
                                    sendEvent(context, EVENT_PROGRESS, params);
                                }

                                @Override
                                public void onFailure(@NonNull Call call, @NonNull IOException e) {
                                    Log.e(TAG, "onFailure:" + e.toString());
                                    reject(ERR_UNKNOWN, e.toString());
                                }

                                @Override
                                public void onResponse(@NonNull Call call, @NonNull Response response) throws IOException {
                                    final String responseString = response.body().string();
                                    response.close();
                                    Log.d(TAG, "onResponse:" + response.toString());
                                    Log.d(TAG, "onResponse: BodyString:" + responseString);
                                    if (response.isSuccessful() && !TextUtils.isEmpty(responseString)) {
                                        Gson gson = new Gson();
                                        ResponseModel model = gson.fromJson(responseString, ResponseModel.class);
                                        recordedVideoToken = model.getVideo().getToken();

                                        resolve(recordedVideoToken);
                                    } else {
                                        reject(String.valueOf(response.code()), response.message());
                                    }
                                }
                            });

                            maxAllowedDurationInSeconds = 0;
                            enforceDuration = false;
                        }
                    }

                    @Override
                    public void onPermissionDenied(PermissionDeniedResponse response) {
                        Log.d(TAG, "onPermissionDenied");
                    }

                    @Override
                    public void onPermissionRationaleShouldBeShown(PermissionRequest permission, PermissionToken token) {
                        Log.d(TAG, "onPermissionRationaleShouldBeShown");
                    }
                }).check();
    }

    @ReactMethod
    public void uploadFromFileSelector(Promise promise) {
        this.promise = promise;

        Intent intent = new Intent();
        intent.setType("video/*");
        intent.setAction(Intent.ACTION_GET_CONTENT);
        context.startActivityForResult(Intent.createChooser(intent, "Select Video"), REQUEST_TAKE_GALLERY_VIDEO, null);

        rejectOnBack = true;
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

    private void resolve(@NonNull String token) {
        if (promise != null) {
            try {
                promise.resolve(token);
            } finally {
                promise = null;
                rejectOnBack = false;
            }
        }
    }

    private void reject(@NonNull String err, @NonNull String message) {
        if (promise != null) {
            try {
                promise.reject(err, message);
            } finally {
                promise = null;
                rejectOnBack = false;
            }
        }
    }

}