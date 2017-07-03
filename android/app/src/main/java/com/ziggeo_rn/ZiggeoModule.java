package com.ziggeo_rn;

import android.app.Activity;
import android.content.Context;
import android.net.Uri;
import android.support.annotation.ColorInt;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.annotation.StringRes;
import android.support.v4.app.FragmentManager;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.ziggeo.androidsdk.IZiggeo;
import com.ziggeo.androidsdk.Ziggeo;
import com.ziggeo.androidsdk.recording.CameraHelper;
import com.ziggeo.androidsdk.recording.VideoRecordingCallback;
import com.ziggeo.androidsdk.widgets.cameraview.CameraView;

import java.util.HashMap;
import java.util.Map;

import okhttp3.Callback;

/**
 * Created by alex on 6/25/2017.
 */

public class ZiggeoModule extends ReactContextBaseJavaModule implements IZiggeo {

    private static final String FACING_BACK = "BACK";
    private static final String FACING_FRONT = "FRONT";

    private Ziggeo ziggeo;

    public ZiggeoModule(ReactApplicationContext reactContext) {
        super(reactContext);

        Activity activity = getCurrentActivity();
        if (activity == null) {
            return;
        }
        ziggeo = new Ziggeo(activity.getApplicationContext());
    }

    @Override
    public String getName() {
        return "ZiggeoAndroid";
    }

    @ReactMethod
    @Override
    public void setAppToken(@NonNull String appToken) {
        ziggeo.setAppToken(appToken);
    }

    @ReactMethod
    @Override
    public void setAutostartRecordingAfter(long millis) {
        ziggeo.setAutostartRecordingAfter(millis);
    }

    @ReactMethod
    @Override
    public void setVideoRecordingProcessCallback(@Nullable VideoRecordingCallback videoRecordingCallback) {
        //TODO replace with js related callback
    }

    @ReactMethod
    @Override
    public void setNetworkRequestsCallback(@Nullable Callback callback) {
        //TODO replace with js related callback
    }

    @Override
    public void setExtraArgsForCreateVideo(Map<String, Object> hashMap) {
        ziggeo.setExtraArgsForCreateVideo(hashMap);
    }

    @ReactMethod
    public void setExtraArgsForCreateVideo(ReadableMap readableMap) {
        ziggeo.setExtraArgsForCreateVideo(ConversionUtil.toMap(readableMap));
    }

    @ReactMethod
    @Override
    public void setCoverSelectorEnabled(boolean enabled) {
        ziggeo.setCoverSelectorEnabled(enabled);
    }

    @Override
    @ReactMethod
    public void setMaxRecordingDuration(long maxDuration) {
        ziggeo.setMaxRecordingDuration(maxDuration);
    }

    @Override
    @ReactMethod
    public void setPreferredCameraFacing(int facing) {
        ziggeo.setPreferredCameraFacing(facing);
    }

    @Override
    @ReactMethod
    public void setCameraSwitchEnabled(boolean enabled) {
        ziggeo.setCameraSwitchEnabled(enabled);
    }

    @Override
    @ReactMethod
    public void setSendImmediately(boolean sendImmediately) {
        ziggeo.setSendImmediately(sendImmediately);
    }

    @Override
    @ReactMethod
    public void cancelRequest() {
        ziggeo.cancelRequest();
    }

    @Override
    @ReactMethod
    public void startRecorder() {
        ziggeo.startRecorder();
    }

    @javax.annotation.Nullable
    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put(FACING_BACK, CameraView.FACING_BACK);
        constants.put(FACING_FRONT, CameraView.FACING_FRONT);
        return constants;
    }

    @Override
    public void setCacheFolder(@NonNull String s) {

    }

    @Override
    public void setMaxCacheSize(long l) {

    }

    @Override
    public void setTurnOffCameraWhileUploading(boolean b) {

    }

    @Override
    public void setColorForStoppedCameraOverlay(@ColorInt int i) {

    }

    @Override
    public void setShowCoverShotSelectionPopup(boolean b) {

    }

    @Override
    public void setPreferredQuality(@Nullable CameraHelper.Quality quality) {

    }

    @Override
    public void cancel() {

    }

    @Override
    public void attachRecorder(@NonNull FragmentManager fragmentManager, int i) {

    }

    @Override
    public void attachPlayer(FragmentManager fragmentManager, int i, Uri uri) {

    }

    @Override
    public void attachPlayer(FragmentManager fragmentManager, int i, String s) {

    }

    @Override
    public void attachRecorder(FragmentManager fragmentManager, int i, long l, Callback callback) {

    }

    @Override
    public void attachRecorder(FragmentManager fragmentManager, int i, long l, boolean b, Callback callback) {

    }

    @Override
    public void attachRecorder(FragmentManager fragmentManager, int i, long l, int i1, Callback callback) {

    }

    @Override
    public void attachRecorder(FragmentManager fragmentManager, int i, long l, CameraHelper.Quality quality, Callback callback) {

    }

    @Override
    public void attachRecorder(FragmentManager fragmentManager, int i, long l, boolean b, CameraHelper.Quality quality, Callback callback) {

    }

    @Override
    public void attachRecorder(FragmentManager fragmentManager, int i, long l, int i1, CameraHelper.Quality quality, Callback callback) {

    }

    @Override
    public void createVideo(@NonNull Context context, long l, @Nullable Callback callback) {

    }

    @Override
    public void createVideo(@NonNull Context context, long l, boolean b, @Nullable Callback callback) {

    }

    @Override
    public void createVideo(@NonNull Context context, long l, int i, @Nullable Callback callback) {

    }

    @Override
    public void createVideo(@NonNull Context context, long l, @Nullable CameraHelper.Quality quality, @Nullable Callback callback) {

    }

    @Override
    public void createVideo(@NonNull Context context, long l, boolean b, @Nullable CameraHelper.Quality quality, @Nullable Callback callback) {

    }

    @Override
    public void createVideo(@NonNull Context context, long l, int i, @Nullable CameraHelper.Quality quality, @Nullable Callback callback) {

    }

    @Override
    public void initStopRecordingConfirmationDialog(boolean b, @StringRes int i, @StringRes int i1, @StringRes int i2, @StringRes int i3) {

    }
}