package com.ziggeo.tasks;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Promise;

import java.util.concurrent.atomic.AtomicInteger;

/**
 * Created by Alex Bedulin on 08.02.2018.
 */

public abstract class Task {

    public static final AtomicInteger GLOBAL_ID = new AtomicInteger();

    protected int id;
    protected Promise promise;
    protected Thread thread;

    public Task(@NonNull Promise promise) {
        this.id = GLOBAL_ID.getAndIncrement();
        this.promise = promise;
    }

    public void setRunnable(Runnable runnable) {
        this.thread = new Thread(runnable);
    }

    public int getId() {
        return id;
    }

    public void execute() {
        thread.start();
    }

    public void resolve(@Nullable Object object) {
        if (promise != null) {
            try {
                promise.resolve(object);
            } finally {
                promise = null;
            }
        }
    }

    public void reject(@NonNull String err) {
        reject(err, "");
    }

    public void reject(@NonNull String err, @Nullable String message) {
        if (promise != null) {
            try {
                promise.reject(err, message);
            } finally {
                promise = null;
            }
        }
    }
}
