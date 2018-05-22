package com.ziggeo;

import android.support.annotation.NonNull;
import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.ziggeo.androidsdk.IZiggeo;
import com.ziggeo.androidsdk.Ziggeo;
import com.ziggeo.utils.ConversionUtil;

/**
 * Created by alex on 6/25/2017.
 */

public class ZiggeoPlayerModule extends ReactContextBaseJavaModule {

    private static final String TAG = ZiggeoPlayerModule.class.getSimpleName();

    private IZiggeo ziggeo;

    public ZiggeoPlayerModule(final ReactApplicationContext reactContext) {
        super(reactContext);
        ziggeo = new Ziggeo(reactContext.getApplicationContext());
    }

    @Override
    public String getName() {
        return "ZiggeoPlayer";
    }

    @ReactMethod
    public void setAppToken(@NonNull String appToken) {
        Log.d(TAG, "setAppToken:" + appToken);
        ziggeo.setAppToken(appToken);
    }

    @ReactMethod
    public void play(@NonNull String videoToken) {
        ziggeo.startPlayer(videoToken);
    }

    @ReactMethod
    public void setExtraArgsForPlayer(ReadableMap readableMap) {
        Log.d(TAG, "setExtraArgsForPlayer:" + readableMap);
        ziggeo.setExtraArgsForPlayer(ConversionUtil.toMap(readableMap));
    }
}