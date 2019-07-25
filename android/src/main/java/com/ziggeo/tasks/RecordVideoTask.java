package com.ziggeo.tasks;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;

/**
 * Created by Alex Bedulin on 08.02.2018.
 */

public class RecordVideoTask extends Task {
    private boolean uploadingStarted;

    public RecordVideoTask(@NonNull Promise promise) {
        super(promise);
    }

    public boolean isUploadingStarted() {
        return uploadingStarted;
    }

    public void setUploadingStarted(boolean uploadingStarted) {
        this.uploadingStarted = uploadingStarted;
    }
}
