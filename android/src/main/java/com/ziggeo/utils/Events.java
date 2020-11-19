package com.ziggeo.utils;

public final class Events {
    private Events() {
    }
    // Camera
    public static final String CAMERA_OPENED = "CameraOpened";
    public static final String CAMERA_CLOSED = "CameraClosed";

    // Common
    public static final String LOADED = "RecordingStarted";
    public static final String CANCELLED_BY_USER = "CancelledByUser";

    // Error
    public static final String ERROR = "Error";

    // Recorder
    public static final String MANUALLY_SUBMITTED = "ManuallySubmitted";
    public static final String RECORDING_STARTED = "RecordingStarted";
    public static final String RECORDING_STOPPED = "RecordingStopped";
    public static final String COUNTDOWN = "Countdown";
    public static final String RECORDING_PROGRESS = "RecordingProgress";
    public static final String READY_TO_RECORD = "ReadyToRecord";
    public static final String RERECORD = "Rerecord";

    // Streaming
    public static final String STREAMING_STARTED = "StreamingStarted";
    public static final String STREAMING_STOPPED = "StreamingStopped";

    // Camera hardware
    public static final String NO_CAMERA = "NoCamera";
    public static final String HAS_CAMERA = "HasCamera";

    // Mic hardware
    public static final String MIC_HEALTH = "MicrophoneHealth";
    public static final String NO_MIC = "NoMicrophone";
    public static final String HAS_MIC = "HasMicrophone";

    // Permissions
    public static final String ACCESS_GRANTED = "AccessGranted";
    public static final String ACCESS_FORBIDDEN = "AccessForbidden";

    // Uploader
    public static final String UPLOADING_STARTED = "UploadingStarted";
    public static final String UPLOAD_PROGRESS = "UploadProgress";
    public static final String VERIFIED = "Verified";
    public static final String PROCESSING = "Processing";
    public static final String PROCESSED = "Processed";
    public static final String UPLOADED = "Uploaded";

    // File selector
    public static final String UPLOAD_SELECTED = "UploadSelected";

    // Player
    public static final String PLAYING = "Playing";
    public static final String PAUSED = "Paused";
    public static final String ENDED = "Ended";
    public static final String SEEK = "Seek";
    public static final String READY_TO_PLAY = "ReadyToPlay";

    // QR scanner
    public static final String QR_DECODED = "QrDecoded";
}
