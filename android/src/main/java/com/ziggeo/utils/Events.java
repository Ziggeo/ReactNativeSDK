package com.ziggeo.utils;

public final class Events {
    private Events() {
    }

    // Error
    public static final String ERROR = "Error";

    // Camera
    public static final String EVENT_CAMERA_OPENED = "CameraOpened";
    public static final String EVENT_CAMERA_CLOSED = "CameraClosed";
    public static final String EVENT_STREAMING_STARTED = "StreamingStarted";
    public static final String EVENT_STREAMING_STOPPED = "StreamingStopped";

    // Recorder
    public static final String EVENT_RECORDING_STARTED = "RecordingStarted";
    public static final String EVENT_RECORDING_STOPPED = "RecordingStopped";

    // Uploader
    public static final String EVENT_PROGRESS = "UploadProgress";
    public static final String EVENT_PROCESSING = "Processing";
    public static final String EVENT_VERIFIED = "Verified";
    public static final String EVENT_PROCESSED = "Processed";
    public static final String EVENT_QR_DECODED = "QrDecoded";
}
