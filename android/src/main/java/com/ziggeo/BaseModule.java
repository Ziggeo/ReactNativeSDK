package com.ziggeo;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.ziggeo.androidsdk.Ziggeo;

public abstract class BaseModule extends ReactContextBaseJavaModule {

    protected ReactContext context;
    protected Ziggeo ziggeo;

    public BaseModule(ReactApplicationContext reactContext) {
        super(reactContext);
        ziggeo = (Ziggeo) Ziggeo.getInstance(reactContext.getApplicationContext());
    }
}
