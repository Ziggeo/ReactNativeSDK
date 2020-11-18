package com.ziggeo.utils;

public final class Events {
    private Events() {
    }
    // Camera
    public static final String EVENT_CAMERA_OPENED = "CameraOpened";
    public static final String EVENT_CAMERA_CLOSED = "CameraClosed";

    // Common
    public static final String EVENT_LOADED = "RecordingStarted";
    public static final String EVENT_CANCELLED_BY_USER = "CancelledByUser";

    // Error
    public static final String ERROR = "Error";

    // Recorder
    public static final String EVENT_MANUALLY_SUBMITTED = "ManuallySubmitted";
    public static final String EVENT_RECORDING_STARTED = "RecordingStarted";
    public static final String EVENT_RECORDING_STOPPED = "RecordingStopped";
    public static final String EVENT_COUNTDOWN = "Countdown";
    public static final String EVENT_RECORDING_PROGRESS = "RecordingProgress";
    public static final String EVENT_READY_TO_RECORD = "ReadyToRecord";
    public static final String EVENT_RERECORD = "Rerecord";

    // Streaming
    public static final String EVENT_STREAMING_STARTED = "StreamingStarted";
    public static final String EVENT_STREAMING_STOPPED = "StreamingStopped";

    // Camera hardware
    public static final String EVENT_NO_CAMERA = "NoCamera";
    public static final String EVENT_HAS_CAMERA = "HasCamera";

    // Mic hardware
    public static final String EVENT_MIC_HEALTH = "MicrophoneHealth";
    public static final String EVENT_NO_MIC = "NoMicrophone";
    public static final String EVENT_HAS_MIC = "HasMicrophone";

    // Permissions
    public static final String EVENT_ACCESS_GRANTED = "AccessGranted";
    public static final String EVENT_ACCESS_FORBIDDEN = "AccessForbidden";

    // Uploader
    public static final String EVENT_UPLOADING_STARTED = "UploadingStarted";
    public static final String EVENT_UPLOAD_PROGRESS = "UploadProgress";
    public static final String EVENT_VERIFIED = "Verified";
    public static final String EVENT_PROCESSING = "Processing";
    public static final String EVENT_PROCESSED = "Processed";

    // File selector
    public static final String EVENT_UPLOAD_SELECTED = "UploadSelected";

    // Player
    public static final String EVENT_PLAYING = "Playing";
    public static final String EVENT_PAUSED = "Paused";
    public static final String EVENT_ENDED = "Ended";
    public static final String EVENT_SEEK = "Seek";
    public static final String EVENT_READY_TO_PLAY = "ReadyToPlay";

    // QR scanner
    public static final String EVENT_QR_DECODED = "QrDecoded";
}
