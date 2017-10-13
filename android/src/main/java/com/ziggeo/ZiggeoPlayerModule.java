package com.ziggeo;

import android.app.Activity;
import android.support.annotation.NonNull;
import android.support.v4.app.FragmentActivity;
import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.ziggeo.androidsdk.IZiggeo;
import com.ziggeo.androidsdk.Ziggeo;

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
        final Activity activity = getCurrentActivity();
        if (activity != null) {
            ziggeo.startPlayer(activity, videoToken);
        }
    }

}