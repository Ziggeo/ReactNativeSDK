package com.ziggeo.cameraview;

import android.content.Context;

import com.facebook.react.bridge.LifecycleEventListener;
import com.ziggeo.androidsdk.widgets.cameraview.CameraView;

/**
 * Created by Alexander Bedulin on 22-May-20.
 * Ziggeo, Inc.
 * alexb@ziggeo.com
 */
public class RnCameraView extends CameraView implements LifecycleEventListener {

    public RnCameraView(Context context) {
        super(context);
    }

    @Override
    public void onHostResume() {
        start();
    }

    @Override
    public void onHostPause() {
        stop();
    }

    @Override
    public void onHostDestroy() {
        stop();
    }
}
