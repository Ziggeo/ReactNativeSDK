package com.ziggeo.recorder;

import android.Manifest;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.karumi.dexter.Dexter;
import com.karumi.dexter.PermissionToken;
import com.karumi.dexter.listener.PermissionDeniedResponse;
import com.karumi.dexter.listener.PermissionGrantedResponse;
import com.karumi.dexter.listener.PermissionRequest;
import com.karumi.dexter.listener.single.PermissionListener;
import com.ziggeo.BaseModule;
import com.ziggeo.androidsdk.callbacks.IUploadingCallback;
import com.ziggeo.androidsdk.callbacks.RecorderCallback;
import com.ziggeo.androidsdk.callbacks.UploadingCallback;
import com.ziggeo.androidsdk.db.impl.room.models.RecordingInfo;
import com.ziggeo.androidsdk.log.ZLog;
import com.ziggeo.androidsdk.qr.QrScannerCallback;
import com.ziggeo.androidsdk.qr.QrScannerConfig;
import com.ziggeo.androidsdk.recorder.RecorderConfig;
import com.ziggeo.androidsdk.widgets.cameraview.CameraView;
import com.ziggeo.androidsdk.widgets.cameraview.Size;
import com.ziggeo.tasks.RecordVideoTask;
import com.ziggeo.tasks.Task;
import com.ziggeo.tasks.UploadFileTask;
import com.ziggeo.utils.ConversionUtil;
import com.ziggeo.utils.Events;
import com.ziggeo.utils.FileUtils;
import com.ziggeo.utils.Keys;
import com.ziggeo.utils.ThemeKeys;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Alex Bedulin on 6/25/2017.
 */
public class ZiggeoRecorderModule extends BaseModule {

    // constants for mapping native constants in JS
    private static final String REAR_CAMERA = "rearCamera";
    private static final String FRONT_CAMERA = "frontCamera";
    private static final String HIGH_QUALITY = "highQuality";
    private static final String MEDIUM_QUALITY = "mediumQuality";
    private static final String LOW_QUALITY = "lowQuality";

    private static final String ERR_UNKNOWN = "ERR_UNKNOWN";
    private static final String ERR_DURATION_EXCEEDED = "ERR_DURATION_EXCEEDED";
    private static final String ERR_FILE_DOES_NOT_EXIST = "ERR_FILE_DOES_NOT_EXIST";
    private static final String ERR_PERMISSION_DENIED = "ERR_PERMISSION_DENIED";

    private static final String ARG_DURATION = "max_duration";
    private static final String ARG_ENFORCE_DURATION = "enforce_duration";

    private int width;
    private int height;

    public ZiggeoRecorderModule(final ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @NonNull
    @Override
    public String getName() {
        return "ZiggeoRecorder";
    }

    @Override
    @ReactMethod
    public void setClientAuthToken(@NonNull String token) {
        super.setClientAuthToken(token);
    }

    @Override
    @ReactMethod
    public void setServerAuthToken(@NonNull String token) {
        super.setServerAuthToken(token);
    }

    @ReactMethod
    public void setAppToken(@NonNull String appToken) {
        ZLog.d("setAppToken:%s", appToken);
        ziggeo.setAppToken(appToken);
    }

    @ReactMethod
    public void setVideoWidth(int width) {
        this.width = width;
        if (width != 0 && height != 0) {
            ziggeo.getRecorderConfig().setResolution(new Size(width, height));
        } else {
            ziggeo.getRecorderConfig().setResolution(new Size(0, 0));
        }
    }

    @ReactMethod
    public void setVideoBitrate(int bitrate) {
        ziggeo.getRecorderConfig().setVideoBitrate(bitrate);
    }

    @ReactMethod
    public void setAudioSampleRate(int sampleRate) {
        ziggeo.getRecorderConfig().setAudioSampleRate(sampleRate);
    }

    @ReactMethod
    public void setAudioBitrate(int bitrate) {
        ziggeo.getRecorderConfig().setAudioBitrate(bitrate);
    }

    @ReactMethod
    public void setVideoHeight(int height) {
        this.height = height;
        if (width != 0 && height != 0) {
            ziggeo.getRecorderConfig().setResolution(new Size(width, height));
        } else {
            ziggeo.getRecorderConfig().setResolution(new Size(0, 0));
        }
    }

    @ReactMethod
    public void setLiveStreamingEnabled(boolean enabled) {
        ZLog.d("setLiveStreamingEnabled:%s", enabled);
        ziggeo.setRecorderConfig(new RecorderConfig.Builder(ziggeo.getRecorderConfig())
                .isLiveStreaming(enabled)
                .build());
    }

    @ReactMethod
    public void setAutostartRecordingAfter(int seconds) {
        ZLog.d("setAutostartRecordingAfter:%s", seconds);
        ziggeo.getRecorderConfig().setShouldAutoStartRecording(true);
        ziggeo.getRecorderConfig().setStartDelay(seconds);
    }

    @ReactMethod
    public void setStartDelay(int seconds) {
        ZLog.d("setStartDelay:%s", seconds);
        ziggeo.getRecorderConfig().setStartDelay(seconds);
    }

    @ReactMethod
    public void setExtraArgsForCreateVideo(ReadableMap readableMap) {
        ZLog.d("setExtraArgsForCreateVideo:%s", readableMap);
        this.setExtraArgsForRecorder(readableMap);
    }

    @ReactMethod
    public void setExtraArgsForRecorder(ReadableMap readableMap) {
        ZLog.d("setExtraArgsForRecorder:%s", readableMap);
        ziggeo.getRecorderConfig().setExtraArgs(ConversionUtil.toMap(readableMap));
    }

    @ReactMethod
    public void setCoverSelectorEnabled(boolean enabled) {
        ZLog.d("setCoverSelectorEnabled:%s", enabled);
        ziggeo.getRecorderConfig().setShouldEnableCoverShot(enabled);
    }

    @ReactMethod
    public void setMaxRecordingDuration(int maxDurationSeconds) {
        final long millis = maxDurationSeconds * 1000;
        ZLog.d("setMaxRecordingDuration:%s", millis);
        ziggeo.getRecorderConfig().setMaxDuration(millis);
    }

    @ReactMethod
    public void setCameraSwitchEnabled(boolean enabled) {
        ZLog.d("setCameraSwitchEnabled:%s", enabled);
        ziggeo.getRecorderConfig().setShouldDisableCameraSwitch(!enabled);
    }

    @ReactMethod
    public void setSendImmediately(boolean sendImmediately) {
        ZLog.d("setSendImmediately:%s", sendImmediately);
        ziggeo.getRecorderConfig().setShouldSendImmediately(sendImmediately);
    }

    @ReactMethod
    public void setCamera(@CameraView.Facing int facing) {
        ZLog.d("setCamera:%s", facing);
        ziggeo.getRecorderConfig().setFacing(facing);
    }

    @ReactMethod
    public void setQuality(@CameraView.Quality int quality) {
        ZLog.d("setQuality:%s", quality);
        ziggeo.getRecorderConfig().setVideoQuality(quality);
    }

    @ReactMethod
    public void setThemeArgsForRecorder(@Nullable ReadableMap data) {
        ZLog.d("setThemeArgsForRecorder");
        if (data != null) {
            ZLog.d(data.toString());
            if (data.hasKey(ThemeKeys.KEY_HIDE_RECORDER_CONTROLS)) {
                boolean hideControls = data.getBoolean(ThemeKeys.KEY_HIDE_RECORDER_CONTROLS);
                ziggeo.getRecorderConfig().getStyle().setHideControls(hideControls);
            }
        }
    }

    @ReactMethod
    public void record(final Promise promise) {
        RecordVideoTask task = new RecordVideoTask(promise);
        ziggeo.getRecorderConfig().setCallback(prepareRecorderCallback(task));
        ziggeo.getUploadingConfig().setCallback(prepareUploadingCallback(task));
        ziggeo.startCameraRecorder();
    }

    @ReactMethod
    public void startScreenRecorder(final Promise promise) {
        RecordVideoTask task = new RecordVideoTask(promise);
        ziggeo.getRecorderConfig().setCallback(prepareRecorderCallback(task));
        ziggeo.getUploadingConfig().setCallback(prepareUploadingCallback(task));
        ziggeo.startScreenRecorder(null);
    }

    @ReactMethod
    public void cancelRequest() {
        ZLog.d("cancelRequest");
    }

    @ReactMethod
    public void startQrScanner(@Nullable ReadableMap data) {
        ZLog.d("startQrScanner");
        final String keyClose = "closeAfterSuccessfulScan";
        HashMap<String, String> config = ConversionUtil.toMap(data);

        boolean close = true;
        if (config != null && config.containsKey(keyClose)) {
            close = Boolean.parseBoolean(config.get(keyClose));
        }
        ziggeo.setQrScannerConfig(new QrScannerConfig(close, new QrScannerCallback() {
            @Override
            public void onQrDecoded(@NonNull String value) {
                super.onQrDecoded(value);
                WritableMap params = Arguments.createMap();
                params.putString(Keys.QR, value);
                sendEvent(Events.EVENT_QR_DECODED, params);
            }
        }));

        ziggeo.startQrScanner();
    }

    @ReactMethod
    public void uploadFromPath(@NonNull final String path, @Nullable ReadableMap data, @NonNull final Promise promise) {
        UploadFileTask task = new UploadFileTask(promise);
        HashMap<String, String> args = ConversionUtil.toMap(data);
        if (args != null) {
            task.setExtraArgs(args);
        }
        Dexter.withActivity(getCurrentActivity())
                .withPermission(Manifest.permission.READ_EXTERNAL_STORAGE)
                .withListener(new PermissionListener() {
                    @Override
                    public void onPermissionGranted(PermissionGrantedResponse response) {
                        ZLog.d("onPermissionGranted");
                        boolean enforceDuration = false;
                        int maxDurationInSeconds = 0;
                        if (task.getExtraArgs() != null) {
                            String strDuration = task.getExtraArgs().get(ARG_DURATION);
                            if (strDuration != null && !strDuration.isEmpty()) {
                                maxDurationInSeconds = Integer.parseInt(strDuration);
                            }
                            String enforce = task.getExtraArgs().get(ARG_ENFORCE_DURATION);
                            if (enforce != null && !enforce.isEmpty()) {
                                enforceDuration = Boolean.parseBoolean(enforce);
                            }
                        }
                        final File videoFile = new File(path);
                        if (!videoFile.exists()) {
                            ZLog.e("File does not exist: %s", path);
                            reject(task, ERR_FILE_DOES_NOT_EXIST, path);
                        } else if (enforceDuration && maxDurationInSeconds > 0 &&
                                FileUtils.getVideoDurationInSeconds(path, getReactApplicationContext()) > maxDurationInSeconds) {
                            final String errorMsg = "Video duration is more than allowed.";
                            ZLog.e(errorMsg);
                            ZLog.e("Path: %s", path);
                            ZLog.e("Duration: %s", FileUtils.getVideoDurationInSeconds(path, getReactApplicationContext()));
                            ZLog.e("Max allowed duration: %s", maxDurationInSeconds);
                            reject(task, ERR_DURATION_EXCEEDED, errorMsg);
                        } else {
                            ziggeo.getUploadingConfig().setCallback(prepareUploadingCallback(task));
                            ziggeo.getUploadingHandler().uploadNow(new RecordingInfo(new File(path),
                                    null, task.getExtraArgs()));
                        }
                    }

                    @Override
                    public void onPermissionDenied(PermissionDeniedResponse response) {
                        ZLog.d("onPermissionDenied");
                        reject(task, ERR_PERMISSION_DENIED);
                    }

                    @Override
                    public void onPermissionRationaleShouldBeShown(PermissionRequest permission, PermissionToken token) {
                        ZLog.d("onPermissionRationaleShouldBeShown");
                    }
                }).check();
    }

    @ReactMethod
    public void uploadFromFileSelector(@Nullable ReadableMap data, @NonNull final Promise promise) {
        final UploadFileTask task = new UploadFileTask(promise);
        HashMap<String, String> args = ConversionUtil.toMap(data);
        if (args != null) {
            task.setExtraArgs(args);
        }
        int maxDurationInSeconds = 0;
        if (task.getExtraArgs() != null) {
            String strDuration = task.getExtraArgs().get(ARG_DURATION);
            if (strDuration != null && !strDuration.isEmpty()) {
                maxDurationInSeconds = Integer.parseInt(strDuration);
            }
        }
        ziggeo.getFileSelectorConfig().setMaxDuration(maxDurationInSeconds * 1000L);
        ziggeo.uploadFromFileSelector(task.getExtraArgs());
        ziggeo.getUploadingConfig().setCallback(prepareUploadingCallback(task));
    }

    @ReactMethod
    public void setRecorderCacheConfig(@Nullable ReadableMap data) {
        if (data != null) {
            ziggeo.getRecorderConfig().setCacheConfig(
                    ConversionUtil.dataToCacheConfig(data, getReactApplicationContext())
            );
        }
    }

    @ReactMethod
    public void setUploadingConfig(@Nullable ReadableMap data) {
        if (data != null) {
            ziggeo.setUploadingConfig(
                    ConversionUtil.dataToUploadingConfig(data, getReactApplicationContext())
            );
        }
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

    private IUploadingCallback prepareUploadingCallback(@NonNull Task task) {
        return new UploadingCallback() {
            @Override
            public void uploadProgress(@NonNull String videoToken, @NonNull String path, long uploaded, long total) {
                super.uploadProgress(videoToken, path, uploaded, total);
                ZLog.d("uploadProgress");
                WritableMap params = Arguments.createMap();
                params.putString(Keys.FILE_NAME, new File(path).getName());
                params.putString(Keys.BYTES_SENT, String.valueOf(uploaded));
                params.putString(Keys.BYTES_TOTAL, String.valueOf(total));
                sendEvent(Events.EVENT_PROGRESS, params);
            }

            @Override
            public void uploaded(@NonNull String path, @NonNull String token) {
                super.uploaded(path, token);
                ZLog.d("uploaded");
                resolve(task, token);
            }

            @Override
            public void uploadingStarted(@NonNull String path) {
                super.uploadingStarted(path);
                ZLog.d("uploadingStarted");
                if (task instanceof RecordVideoTask) {
                    ((RecordVideoTask) task).setUploadingStarted(true);
                }
            }

            @Override
            public void processing(@NonNull String token) {
                super.processing(token);
                ZLog.d("processing");
                WritableMap params = Arguments.createMap();
                params.putString(Keys.TOKEN, token);
                sendEvent(Events.EVENT_PROCESSING, params);
            }

            @Override
            public void processed(@NonNull String token) {
                super.processed(token);
                ZLog.d("processed");
                WritableMap params = Arguments.createMap();
                params.putString(Keys.TOKEN, token);
                sendEvent(Events.EVENT_PROCESSED, params);
            }

            @Override
            public void verified(@NonNull String token) {
                super.verified(token);
                ZLog.d("verified");
                WritableMap params = Arguments.createMap();
                params.putString(Keys.TOKEN, token);
                sendEvent(Events.EVENT_VERIFIED, params);
            }

            @Override
            public void error(@NonNull Throwable throwable) {
                super.error(throwable);
                ZLog.d("error:%s", throwable);
                reject(task, ERR_UNKNOWN, throwable.toString());
            }
        };
    }

    private RecorderCallback prepareRecorderCallback(@NonNull Task task) {
        return new RecorderCallback() {

            @Override
            public void accessForbidden(@NonNull List<String> permissions) {
                super.accessForbidden(permissions);
                ZLog.d("accessForbidden");
                reject(task, ERR_PERMISSION_DENIED);
            }

            @Override
            public void error(@NonNull Throwable throwable) {
                super.error(throwable);
                ZLog.d("error:%s", throwable);
                reject(task, ERR_UNKNOWN, throwable.toString());
            }

            @Override
            public void recordingStarted() {
                super.recordingStarted();
                ZLog.d("recordingStarted");
                sendEvent(Events.EVENT_RECORDING_STARTED, null);
            }

            @Override
            public void recordingStopped(@NonNull String path) {
                super.recordingStopped(path);
                ZLog.d("recordingStopped:%s", path);
                sendEvent(Events.EVENT_RECORDING_STOPPED, null);
            }

            @Override
            public void canceledByUser() {
                super.canceledByUser();
                ZLog.d("canceledByUser");
                cancel(task);
            }
        };
    }

}
