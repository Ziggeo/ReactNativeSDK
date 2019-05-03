package com.ziggeo.modules;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;
import com.ziggeo.ZiggeoRecorderModule;
import com.ziggeo.ui.CameraViewManager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Created by alex on 6/25/2017.
 */

public class ZiggeoPackage implements ReactPackage {

    private static final String TAG = ZiggeoPackage.class.getSimpleName();

    @Override
    public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
        List<NativeModule> modules = new ArrayList<>();
        modules.add(new ZiggeoRecorderModule(reactContext));
        modules.add(new ZiggeoPlayerModule(reactContext));

        return modules;
    }

    @Override
    public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
        return Collections.emptyList();
    }

}
