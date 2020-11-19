package com.ziggeo;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.google.gson.Gson;
import com.ziggeo.androidsdk.Ziggeo;
import com.ziggeo.androidsdk.log.ZLog;
import com.ziggeo.tasks.Task;

public abstract class BaseModule extends ReactContextBaseJavaModule {
    private static final String ERR_CANCELLED = "ERR_CANCELLED";

    protected Ziggeo ziggeo;
    protected Gson gson;

    public BaseModule(ReactApplicationContext reactContext) {
        super(reactContext);
        ziggeo = Ziggeo.getInstance(reactContext.getApplicationContext());
        gson = new Gson();
    }

    @ReactMethod
    public void setClientAuthToken(@NonNull String token) {
        ziggeo.setClientAuthToken(token);
    }

    @ReactMethod
    public void setServerAuthToken(@NonNull String token) {
        ziggeo.setServerAuthToken(token);
    }

    public void sendEvent(String eventName) {
        getReactApplicationContext()
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, null);
    }

    public void sendEvent(String eventName, @Nullable WritableMap params) {
        getReactApplicationContext()
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }

    public void resolve(@NonNull Task task, @Nullable Object object) {
        task.resolve(object);
    }

    public void reject(@NonNull Task task, @NonNull String err) {
        task.reject(err);
    }

    public void reject(@NonNull Task task, @NonNull String err, @Nullable String message) {
        task.reject(err, message);
    }

    public void cancel(@NonNull Task task) {
        final String message = "Cancelled by the user.";
        ZLog.d(message);
        reject(task, ERR_CANCELLED, message);
    }

}
