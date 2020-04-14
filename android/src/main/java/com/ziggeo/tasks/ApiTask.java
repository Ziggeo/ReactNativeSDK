package com.ziggeo.tasks;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;

/**
 * Created by Alex Bedulin on 08.02.2018.
 */

public class ApiTask extends Task {

    public ApiTask(@NonNull Promise promise) {
        super(promise);
    }
}
