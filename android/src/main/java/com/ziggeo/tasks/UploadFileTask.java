package com.ziggeo.tasks;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.facebook.react.bridge.Promise;

import java.util.Map;

/**
 * Created by Alex Bedulin on 06.02.2018.
 */

public class UploadFileTask extends Task {

    private Map<String, String> extraArgs;

    public UploadFileTask(@NonNull Promise promise) {
        super(promise);
    }

    @Nullable
    public Map<String, String> getExtraArgs() {
        return extraArgs;
    }

    public void setExtraArgs(@Nullable Map<String, String> args){
        extraArgs = args;
    }

}
