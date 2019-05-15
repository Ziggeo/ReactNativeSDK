package com.ziggeo.modules;

import android.Manifest;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
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
import com.ziggeo.androidsdk.widgets.cameraview.CameraView;
import com.ziggeo.tasks.RecordVideoTask;
import com.ziggeo.tasks.Task;
import com.ziggeo.tasks.UploadFileTask;
import com.ziggeo.ui.ThemeKeys;
import com.ziggeo.utils.ConversionUtil;
import com.ziggeo.utils.FileUtils;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import timber.log.Timber;

/**
 * Created by Alex Bedulin on 6/25/2017.
 */
public class ZiggeoRecorderModule extends BaseModule {

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

    public ZiggeoRecorderModule(final ReactApplicationContext reactContext) {
        super(reactContext);
        ziggeo = new Ziggeo(reactContext.getApplicationContext());
        ziggeo.setSendImmediately(false);
        context = reactContext;
    }

    @Override
    public String getName() {
        return "ZiggeoRecorder";
    }

    @ReactMethod
    public void setAppToken(@NonNull String appToken) {
        Timber.d("setAppToken:%s", appToken);
        ziggeo.setAppToken(appToken);
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
            if (data.hasKey(ThemeKeys.KEY_HIDE_RECORDER_CONTROLS)) {
                boolean hideControls = data.getBoolean(ThemeKeys.KEY_HIDE_RECORDER_CONTROLS);
                ziggeo.getRecorderConfig().getStyle().setHideControls(hideControls);
            }
        }
    }

    @ReactMethod
    public void record(final Promise promise) {
        RecordVideoTask task = new RecordVideoTask(promise);
        ziggeo.getRecorderConfig().setCallback(new RecorderCallback() {
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
                resolve(task, token);
            }

            @Override
            public void error(@NonNull Throwable throwable) {
                super.error(throwable);
                reject(task, ERR_UNKNOWN, throwable.toString());
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
                task.setUploadingStarted(true);
            }

            @Override
            public void canceledByUser() {
                super.canceledByUser();
                cancel(task);
            }
        });
        ziggeo.startCameraRecorder();
    }

    @ReactMethod
    public void cancelRequest() {
        Timber.d("cancelRequest");
        ziggeo.cancelRequest();
    }

    @ReactMethod
    public void uploadFromPath(@NonNull final String path, @Nullable ReadableMap data, @NonNull final Promise promise) {
        UploadFileTask task = new UploadFileTask(promise);
        if (data != null) {
            task.setExtraArgs(new HashMap<>(ConversionUtil.toMap(data)));
        }
        Dexter.withActivity(getCurrentActivity())
                .withPermission(Manifest.permission.READ_EXTERNAL_STORAGE)
                .withListener(new PermissionListener() {
                    @Override
                    public void onPermissionGranted(PermissionGrantedResponse response) {
                        Timber.d("onPermissionGranted");
                        boolean enforceDuration = false;
                        int maxDuration = 0;
                        if (task.getExtraArgs() != null) {
                            String strDuration = task.getExtraArgs().get(ARG_DURATION);
                            if (strDuration != null && !strDuration.isEmpty()) {
                                maxDuration = Integer.parseInt(strDuration);
                            }
                            String enforce = task.getExtraArgs().get(ARG_ENFORCE_DURATION);
                            if (enforce != null && !enforce.isEmpty()) {
                                enforceDuration = Boolean.parseBoolean(enforce);
                            }
                        }
                        final File videoFile = new File(path);
                        if (!videoFile.exists()) {
                            Timber.e("File does not exist: %s", path);
                            reject(task, ERR_FILE_DOES_NOT_EXIST, path);
                        } else if (enforceDuration && maxDuration > 0 &&
                                FileUtils.getVideoDuration(path, getReactApplicationContext()) > maxDuration) {
                            final String errorMsg = "Video duration is more than allowed.";
                            Timber.e(errorMsg);
                            Timber.e("Path: %s", path);
                            Timber.e("Duration: %s", FileUtils.getVideoDuration(path, getReactApplicationContext()));
                            Timber.e("Max allowed duration: %s", maxDuration);
                            reject(task, ERR_DURATION_EXCEEDED, errorMsg);
                        } else {
                            ziggeo.getRecorderConfig().setCallback(new RecorderCallback() {
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
                                    resolve(task, token);
                                }

                                @Override
                                public void error(@NonNull Throwable throwable) {
                                    super.error(throwable);
                                    reject(task, ERR_UNKNOWN, throwable.toString());
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
                                public void canceledByUser() {
                                    super.canceledByUser();
                                    cancel(task);
                                }
                            });
                            ziggeo.getUploadingHandler().uploadNow(new RecordingInfo(new File(path),
                                    null, task.getExtraArgs()));
                        }
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

    @ReactMethod
    public void uploadFromFileSelector(@Nullable ReadableMap data, @NonNull final Promise promise) {
        final UploadFileTask task = new UploadFileTask(promise);
        if (data != null) {
            task.setExtraArgs(new HashMap<>(ConversionUtil.toMap(data)));
        }
        ziggeo.getRecorderConfig().setCallback(new RecorderCallback() {
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
                resolve(task, token);
            }

            @Override
            public void error(@NonNull Throwable throwable) {
                super.error(throwable);
                reject(task, ERR_UNKNOWN, throwable.toString());
            }

            @Override
            public void accessForbidden(@NonNull List<String> permissions) {
                super.accessForbidden(permissions);
                reject(task, ERR_PERMISSION_DENIED);
            }

            @Override
            public void canceledByUser() {
                super.canceledByUser();
                cancel(task);
            }
        });
        ziggeo.uploadFromFileSelector(task.getExtraArgs());
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

    public void resolve(@NonNull Task task, @NonNull String token) {
        task.resolve(token);
    }

    public void reject(@NonNull Task task, @NonNull String err) {
        task.reject(err);
    }

    public void reject(@NonNull Task task, @NonNull String err, @Nullable String message) {
        task.reject(err, message);
    }

    public void cancel(@NonNull Task task) {
        reject(task, ERR_CANCELLED, "Cancelled by the user.");
    }

}