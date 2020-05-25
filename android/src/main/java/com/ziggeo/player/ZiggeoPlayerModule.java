package com.ziggeo.player;


import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.ziggeo.BaseModule;
import com.ziggeo.androidsdk.log.ZLog;
import com.ziggeo.utils.ConversionUtil;
import com.ziggeo.utils.ThemeKeys;

/**
 * Created by alex on 6/25/2017.
 */

public class ZiggeoPlayerModule extends BaseModule {

    public ZiggeoPlayerModule(final ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "ZiggeoPlayer";
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
    public void play(@NonNull String videoToken) {
        ziggeo.startPlayer(videoToken);
    }

    @ReactMethod
    public void setExtraArgsForPlayer(ReadableMap readableMap) {
        ZLog.d("setExtraArgsForPlayer:%s", readableMap);
        ziggeo.getPlayerConfig().setExtraArgs(ConversionUtil.toMap(readableMap));
    }

    @ReactMethod
    public void setThemeArgsForPlayer(@Nullable ReadableMap data) {
        if (data != null) {
            if (data.hasKey(ThemeKeys.KEY_HIDE_PLAYER_CONTROLS)) {
                boolean hideControls = data.getBoolean(ThemeKeys.KEY_HIDE_PLAYER_CONTROLS);
                ziggeo.getPlayerConfig().getStyle().setHideControls(hideControls);
            }
        }
    }

}