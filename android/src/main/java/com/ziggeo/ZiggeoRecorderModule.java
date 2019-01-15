package com.ziggeo;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.SparseArray;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.karumi.dexter.Dexter;
import com.karumi.dexter.PermissionToken;
import com.karumi.dexter.listener.PermissionDeniedResponse;
import com.karumi.dexter.listener.PermissionGrantedResponse;
import com.karumi.dexter.listener.PermissionRequest;
import com.karumi.dexter.listener.single.PermissionListener;
import com.ziggeo.androidsdk.Ziggeo;
import com.ziggeo.androidsdk.callbacks.RecorderCallback;
import com.ziggeo.androidsdk.db.impl.room.models.RecordingInfo;
import com.ziggeo.androidsdk.ui.theming.RecorderStyle;
import com.ziggeo.androidsdk.ui.theming.ZiggeoTheme;
import com.ziggeo.androidsdk.widgets.cameraview.CameraView;
import com.ziggeo.tasks.RecordVideoTask;
import com.ziggeo.tasks.Task;
import com.ziggeo.tasks.UploadFileTask;
import com.ziggeo.ui.ThemeKeys;
import com.ziggeo.utils.ConversionUtil;
import com.ziggeo.utils.FileUtils;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import timber.log.Timber;

/**
 * Created by Alex Bedulin on 6/25/2017.
 */
public class ZiggeoRecorderModule extends BaseModule implements ActivityEventListener, LifecycleEventListener {

    private static final String TAG = ZiggeoRecorderModule.class.getSimpleName();

    // constants for mapping native constants in JS
    private static final String REAR_CAMERA = "rearCamera";
    private static final String FRONT_CAMERA = "frontCamera";
    private static final String HIGH_QUALITY = "highQuality";
    private static final String MEDIUM_QUALITY = "mediumQuality";
    private static final String LOW_QUALITY = "lowQuality";

    private static final String BYTES_SENT = "bytesSent";
    private static final String BYTES_TOTAL = "totalBytes";
    private static final String FILE_NAME = "fileName";
    private static final String EVENT_PROGRESS = "UploadProgress";
    private static final String EVENT_RECORDING_STARTED = "RecordingStarted";
    private static final String EVENT_RECORDING_STOPPED = "RecordingStopped";

    private static final String ERR_UNKNOWN = "ERR_UNKNOWN";
    private static final String ERR_DURATION_EXCEEDED = "ERR_DURATION_EXCEEDED";
    private static final String ERR_CANCELLED = "ERR_CANCELLED";
    private static final String ERR_FILE_DOES_NOT_EXIST = "ERR_FILE_DOES_NOT_EXIST";
    private static final String ERR_PERMISSION_DENIED = "ERR_PERMISSION_DENIED";

    private static final String ARG_DURATION = "max_duration";
    private static final String ARG_ENFORCE_DURATION = "enforce_duration";

    private String recordedVideoToken;

    private RecordVideoTask recordVideoTask;
    //TODO remove it when file selector will be remade
    private SparseArray<UploadFileTask> tasks;

    public ZiggeoRecorderModule(final ReactApplicationContext reactContext) {
        super(reactContext);
        ziggeo = new Ziggeo(reactContext.getApplicationContext());
        ziggeo.setSendImmediately(false);
        context = reactContext;
        reactContext.addActivityEventListener(this);
        reactContext.addLifecycleEventListener(this);
        tasks = new SparseArray<>();
    }

    @Override
    public String getName() {
        return "ZiggeoRecorder";
    }

    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        Timber.d("onActivityResult. resultCode:%s data:%s", resultCode, data);
        UploadFileTask task = tasks.get(requestCode);
        if (task != null) {
            switch (resultCode) {
                case Activity.RESULT_OK:
                    Uri uri = data.getData();
                    String path = null;

                    if (uri != null) {
                        path = uri.getPath();
                    }
                    if (path == null || !new File(path).exists()) {
                        path = FileUtils.getPath(context, uri);
                    }
                    if (path != null) {
                        uploadFromPath(path, null, task, null);
                    } else {
                        reject(task, ERR_UNKNOWN);
                    }
                    break;
                case Activity.RESULT_CANCELED:
                    reject(task, ERR_CANCELLED, "Cancelled by the user.");
                    break;
            }
        }
    }

    @Override
    public void onNewIntent(Intent intent) {

    }

    @Override
    public void onHostResume() {
        if (recordVideoTask != null && !recordVideoTask.isUploadingStarted()) {
            reject(recordVideoTask, ERR_CANCELLED, "Cancelled by the user.");
            recordVideoTask = null;
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
        Timber.d("setAppToken:%s", appToken);
        ziggeo.setAppToken(appToken);
        sendEvent(context, "TestEvent", null);
    }

    @ReactMethod
    public void setAutostartRecordingAfter(int seconds) {
        final long millis = seconds * 1000;
        Timber.d("setAutostartRecordingAfter:%s", millis);
        ziggeo.setAutostartRecordingAfter(millis);
    }

    @ReactMethod
    public void setExtraArgsForCreateVideo(ReadableMap readableMap) {
        Timber.d("setExtraArgsForCreateVideo:%s", readableMap);
        this.setExtraArgsForRecorder(readableMap);
    }

    @ReactMethod
    public void setExtraArgsForRecorder(ReadableMap readableMap) {
        Timber.d("setExtraArgsForRecorder:%s", readableMap);
        ziggeo.setExtraArgsForRecorder(ConversionUtil.toMap(readableMap));
    }

    @ReactMethod
    public void setCoverSelectorEnabled(boolean enabled) {
        Timber.d("setCoverSelectorEnabled:%s", enabled);
        ziggeo.setCoverSelectorEnabled(enabled);
    }

    @ReactMethod
    public void setMaxRecordingDuration(int maxDurationSeconds) {
        final long millis = maxDurationSeconds * 1000;
        Timber.d("setMaxRecordingDuration:%s", millis);
        ziggeo.setMaxRecordingDuration(millis);
    }

    @ReactMethod
    public void setCameraSwitchEnabled(boolean enabled) {
        Timber.d("setCameraSwitchEnabled:%s", enabled);
        ziggeo.setCameraSwitchDisabled(!enabled);
    }

    @ReactMethod
    public void setSendImmediately(boolean sendImmediately) {
        Timber.d("setSendImmediately:%s", sendImmediately);
        ziggeo.setSendImmediately(sendImmediately);
    }

    @ReactMethod
    public void setCamera(@CameraView.Facing int facing) {
        Timber.d("setCamera:%s", facing);
        ziggeo.setPreferredCameraFacing(facing);
    }

    @ReactMethod
    public void setQuality(@CameraView.Quality int quality) {
        Timber.d("setQuality:%s", quality);
        ziggeo.setPreferredQuality(quality);
    }

    @ReactMethod
    public void setThemeArgsForRecorder(@Nullable ReadableMap data) {
        if (data != null) {
            RecorderStyle recorderStyle = new RecorderStyle.Builder()
                    .hideControls(data.getBoolean(ThemeKeys.KEY_HIDE_RECORDER_CONTROLS))
                    .build();

            if (ziggeo.getTheme() == null) {
                ziggeo.setTheme(new ZiggeoTheme());
            }
            ziggeo.getTheme().setRecorderStyle(recorderStyle);
        }
    }

    @ReactMethod
    public void record(final Promise promise) {
        recordVideoTask = new RecordVideoTask(promise);
        recordedVideoToken = null;
        ziggeo.setRecorderCallback(new RecorderCallback() {
            @Override
            public void uploadProgress(@NonNull String videoToken, @NonNull File file, long uploaded, long total) {
                super.uploadProgress(videoToken, file, uploaded, total);
                WritableMap params = Arguments.createMap();
                params.putString(BYTES_SENT, String.valueOf(uploaded));
                params.putString(BYTES_TOTAL, String.valueOf(total));
                sendEvent(context, EVENT_PROGRESS, params);
            }

            @Override
            public void uploaded(@NonNull String path, @NonNull String token) {
                super.uploaded(path, token);
                resolve(recordVideoTask, token);
            }

            @Override
            public void error(@NonNull Throwable throwable) {
                super.error(throwable);
                reject(recordVideoTask, ERR_UNKNOWN, throwable.toString());
            }

            @Override
            public void recordingStarted() {
                super.recordingStarted();
                sendEvent(context, EVENT_RECORDING_STARTED, null);
            }

            @Override
            public void recordingStopped(@NonNull String path) {
                super.recordingStopped(path);
                sendEvent(context, EVENT_RECORDING_STOPPED, null);
            }

            @Override
            public void uploadingStarted(@NonNull String path) {
                super.uploadingStarted(path);
                recordVideoTask.setUploadingStarted(true);
            }
        });
        ziggeo.startRecorder();
    }

    @ReactMethod
    public void cancelRequest() {
        Timber.d("cancelRequest");
        ziggeo.cancelRequest();
    }

    @ReactMethod
    public void uploadFromPath(@NonNull final String path, @Nullable ReadableMap data, @Nullable final Promise promise) {
        uploadFromPath(path, data, null, promise);
    }

    public void uploadFromPath(@NonNull final String path, @Nullable ReadableMap data, @Nullable UploadFileTask task,
                               @Nullable final Promise promise) {
        if (task == null && promise != null) {
            task = new UploadFileTask(promise);
        }
        final UploadFileTask finalTask = task;
        if (data != null) {
            finalTask.setExtraArgs(new HashMap<>(ConversionUtil.toMap(data)));
        }
        Dexter.withActivity(getCurrentActivity())
                .withPermission(Manifest.permission.READ_EXTERNAL_STORAGE)
                .withListener(new PermissionListener() {
                    @Override
                    public void onPermissionGranted(PermissionGrantedResponse response) {
                        Timber.d("onPermissionGranted");
                        boolean enforceDuration = false;
                        int maxDuration = 0;
                        if (finalTask.getExtraArgs() != null) {
                            String strDuration = finalTask.getExtraArgs().get(ARG_DURATION);
                            if (strDuration != null && !strDuration.isEmpty()) {
                                maxDuration = Integer.parseInt(strDuration);
                            }
                            String enforce = finalTask.getExtraArgs().get(ARG_ENFORCE_DURATION);
                            if (enforce != null && !enforce.isEmpty()) {
                                enforceDuration = Boolean.parseBoolean(enforce);
                            }
                        }
                        final File videoFile = new File(path);
                        if (!videoFile.exists()) {
                            Timber.e("File does not exist: %s", path);
                            reject(finalTask, ERR_FILE_DOES_NOT_EXIST, path);
                        } else if (enforceDuration && maxDuration > 0 &&
                                FileUtils.getVideoDuration(path, getReactApplicationContext()) > maxDuration) {
                            final String errorMsg = "Video duration is more than allowed.";
                            Timber.e(errorMsg);
                            Timber.e("Path: %s", path);
                            Timber.e("Duration: %s", FileUtils.getVideoDuration(path, getReactApplicationContext()));
                            Timber.e("Max allowed duration: %s", maxDuration);
                            reject(finalTask, ERR_DURATION_EXCEEDED, errorMsg);
                        } else {
                            ziggeo.setRecorderCallback(new RecorderCallback() {
                                @Override
                                public void uploadProgress(@NonNull String videoToken, @NonNull File file, long uploaded, long total) {
                                    super.uploadProgress(videoToken, file, uploaded, total);
                                    WritableMap params = Arguments.createMap();
                                    params.putString(BYTES_SENT, String.valueOf(uploaded));
                                    params.putString(BYTES_TOTAL, String.valueOf(total));
                                    sendEvent(context, EVENT_PROGRESS, params);
                                }

                                @Override
                                public void uploaded(@NonNull String path, @NonNull String token) {
                                    super.uploaded(path, token);
                                    resolve(finalTask, token);
                                }

                                @Override
                                public void error(@NonNull Throwable throwable) {
                                    super.error(throwable);
                                    reject(finalTask, ERR_UNKNOWN, throwable.toString());
                                }

                                @Override
                                public void recordingStarted() {
                                    super.recordingStarted();
                                    sendEvent(context, EVENT_RECORDING_STARTED, null);
                                }

                                @Override
                                public void recordingStopped(@NonNull String path) {
                                    super.recordingStopped(path);
                                    sendEvent(context, EVENT_RECORDING_STOPPED, null);
                                }
                            });
                            ziggeo.getUploadingHandler().uploadNow(new RecordingInfo(new File(path),
                                    null, finalTask.getExtraArgs()));
                            executeTask(finalTask);
                        }
                    }

                    @Override
                    public void onPermissionDenied(PermissionDeniedResponse response) {
                        Timber.d("onPermissionDenied");
                        reject(finalTask, ERR_PERMISSION_DENIED);
                    }

                    @Override
                    public void onPermissionRationaleShouldBeShown(PermissionRequest permission, PermissionToken token) {
                        Timber.d("onPermissionRationaleShouldBeShown");
                    }
                }).check();
    }

    @ReactMethod
    public void uploadFromFileSelector(@Nullable ReadableMap data, @NonNull final Promise promise) {
        final UploadFileTask task = new UploadFileTask(promise);
        if (data != null) {
            task.setExtraArgs(new HashMap<>(ConversionUtil.toMap(data)));
        }
        tasks.append(task.getId(), task);

        Dexter.withActivity(getCurrentActivity())
                .withPermission(Manifest.permission.READ_EXTERNAL_STORAGE)
                .withListener(new PermissionListener() {
                    @Override
                    public void onPermissionGranted(PermissionGrantedResponse response) {
                        Intent intent = new Intent();
                        intent.setType("video/*");
                        intent.setAction(Intent.ACTION_GET_CONTENT);
                        context.startActivityForResult(
                                Intent.createChooser(intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION), "Select Video"),
                                task.getId(), null);
                    }

                    @Override
                    public void onPermissionDenied(PermissionDeniedResponse response) {
                        Timber.d("onPermissionDenied");
                        reject(task, ERR_PERMISSION_DENIED);
                    }

                    @Override
                    public void onPermissionRationaleShouldBeShown(PermissionRequest permission, PermissionToken token) {
                        Timber.d("onPermissionRationaleShouldBeShown");
                    }
                }).check();
    }

    @Nullable
    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put(REAR_CAMERA, CameraView.FACING_BACK);
        constants.put(FRONT_CAMERA, CameraView.FACING_FRONT);
        constants.put(HIGH_QUALITY, CameraView.QUALITY_HIGH);
        constants.put(MEDIUM_QUALITY, CameraView.QUALITY_MEDIUM);
        constants.put(LOW_QUALITY, CameraView.QUALITY_LOW);
        return constants;
    }

    private void sendEvent(ReactContext reactContext, String eventName, @Nullable WritableMap params) {
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }

    private void executeTask(@NonNull UploadFileTask task) {
        tasks.delete(task.getId());
    }

    public void resolve(@NonNull Task task, @NonNull String token) {
        task.resolve(token);
        tasks.delete(task.getId());
    }

    public void reject(@NonNull Task task, @NonNull String err) {
        task.reject(err);
        tasks.delete(task.getId());
    }

    public void reject(@NonNull Task task, @NonNull String err, @Nullable String message) {
        task.reject(err, message);
        tasks.delete(task.getId());
    }

}