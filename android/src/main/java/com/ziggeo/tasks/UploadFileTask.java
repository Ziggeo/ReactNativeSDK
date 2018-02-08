package com.ziggeo.tasks;

import android.support.annotation.NonNull;

import com.facebook.react.bridge.Promise;

/**
 * Created by Alex Bedulin on 06.02.2018.
 */

public class UploadFileTask extends Task {

    private int maxAllowedDurationInSeconds;
    private boolean enforceDuration;

    public UploadFileTask(@NonNull Promise promise) {
        super(promise);
    }

    public void setMaxAllowedDurationInSeconds(int maxAllowedDurationInSeconds) {
        this.maxAllowedDurationInSeconds = maxAllowedDurationInSeconds;
    }

    public int getMaxAllowedDurationInSeconds() {
        return maxAllowedDurationInSeconds;
    }

    public void setEnforceDuration(boolean enforceDuration) {
        this.enforceDuration = enforceDuration;
    }

    public boolean isEnforceDuration() {
        return enforceDuration;
    }

}
