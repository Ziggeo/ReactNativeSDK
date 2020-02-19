package com.ziggeo.tasks;


import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Promise;

import java.util.HashMap;

/**
 * Created by Alex Bedulin on 06.02.2018.
 */

public class UploadFileTask extends Task {

    private HashMap<String, String> extraArgs;

    public UploadFileTask(@NonNull Promise promise) {
        super(promise);
    }

    @Nullable
    public HashMap<String, String> getExtraArgs() {
        return extraArgs;
    }

    public void setExtraArgs(@Nullable HashMap<String, String> args){
        extraArgs = args;
    }

}
