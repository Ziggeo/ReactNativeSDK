package com.ziggeo.contactus;


import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.ziggeo.BaseModule;
import com.ziggeo.androidsdk.log.LogModel;
import com.ziggeo.androidsdk.log.ZLog;
import com.ziggeo.tasks.SimpleTask;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by alex on 6/25/2017.
 */
public class ContactUs extends BaseModule {

    public ContactUs(final ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "ContactUs";
    }

    @ReactMethod
    public void sendReport(@Nullable ReadableMap args, @NonNull Promise promise) {
        SimpleTask task = new SimpleTask(promise);
        List<LogModel> logs = new ArrayList<>();
        ziggeo.sendReport(logs);
        task.resolve(null);
    }

    @ReactMethod
    public void sendEmailToSupport(@Nullable ReadableMap args, @NonNull Promise promise) {
        SimpleTask task = new SimpleTask(promise);
        ziggeo.sendEmailToSupport();
        task.resolve(null);
    }
}
