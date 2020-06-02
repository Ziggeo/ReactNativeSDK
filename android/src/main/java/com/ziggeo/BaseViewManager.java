package com.ziggeo;

import android.view.View;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.uimanager.SimpleViewManager;

/**
 * Created by Alexander Bedulin on 02-Jun-20.
 * Ziggeo, Inc.
 * alexb@ziggeo.com
 */
public abstract class BaseViewManager<T extends View> extends SimpleViewManager<T> {
    protected ReactApplicationContext context;

    public void sendEvent(String eventName, @Nullable WritableMap params) {
        context.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }
}
