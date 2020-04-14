package com.ziggeo;

import androidx.annotation.NonNull;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;
import com.ziggeo.modules.Videos;
import com.ziggeo.modules.ZiggeoPlayer;
import com.ziggeo.modules.ZiggeoRecorder;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Created by alex on 6/25/2017.
 */

public class ZiggeoPackage implements ReactPackage {

    @Override
    public List<NativeModule> createNativeModules(@NonNull ReactApplicationContext reactContext) {
        List<NativeModule> modules = new ArrayList<>();
        modules.add(new ZiggeoRecorder(reactContext));
        modules.add(new ZiggeoPlayer(reactContext));
        modules.add(new Videos(reactContext));

        return modules;
    }

    @Override
    public List<ViewManager> createViewManagers(@NonNull ReactApplicationContext reactContext) {
        return Collections.emptyList();
    }

}
