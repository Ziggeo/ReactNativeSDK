package com.ziggeo.modules;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.ziggeo.androidsdk.Ziggeo;

public abstract class BaseModule extends ReactContextBaseJavaModule {

    protected Ziggeo ziggeo;

    public BaseModule(ReactApplicationContext reactContext) {
        super(reactContext);
        ziggeo = Ziggeo.getInstance(reactContext.getApplicationContext());
    }

    @ReactMethod
    public void setClientAuthToken(@NonNull String token) {
        ziggeo.setClientAuthToken(token);
    }

    @ReactMethod
    public void setServerAuthToken(@NonNull String token) {
        ziggeo.setServerAuthToken(token);
    }
}
