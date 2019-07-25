package com.ziggeo.modules;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.ziggeo.ui.ThemeKeys;
import com.ziggeo.utils.ConversionUtil;

import timber.log.Timber;

/**
 * Created by alex on 6/25/2017.
 */

public class ZiggeoPlayerModule extends BaseModule {

    private static final String TAG = ZiggeoPlayerModule.class.getSimpleName();

    public ZiggeoPlayerModule(final ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "ZiggeoPlayer";
    }

    @ReactMethod
    public void setAppToken(@NonNull String appToken) {
        Timber.d("setAppToken:%s", appToken);
        ziggeo.setAppToken(appToken);
    }

    @ReactMethod
    public void play(@NonNull String videoToken) {
        ziggeo.startPlayer(videoToken);
    }

    @ReactMethod
    public void setExtraArgsForPlayer(ReadableMap readableMap) {
        Timber.d("setExtraArgsForPlayer:%s", readableMap);
        ziggeo.setExtraArgsForPlayer(ConversionUtil.toMap(readableMap));
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