package com.ziggeo.contactus;


import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.ziggeo.BaseModule;
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
    public void sendReport(@Nullable ReadableArray logsArray, @NonNull Promise promise) {
        SimpleTask task = new SimpleTask(promise);
        List<String> logs = new ArrayList<>();
        if (logsArray != null) {
            for (Object object : logsArray.toArrayList()) {
                logs.add(object.toString());
            }
        }
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
