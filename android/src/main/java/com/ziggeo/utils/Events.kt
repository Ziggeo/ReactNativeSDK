package com.ziggeo.utils

object Events {
    // Camera
    const val CAMERA_OPENED = "CameraOpened"
    const val CAMERA_CLOSED = "CameraClosed"

    // Common
    const val LOADED = "RecordingStarted"
    const val CANCELLED_BY_USER = "CancelledByUser"

    // Error
    const val ERROR = "Error"

    // Recorder
    const val MANUALLY_SUBMITTED = "ManuallySubmitted"
    const val RECORDING_STARTED = "RecordingStarted"
    const val RECORDING_STOPPED = "RecordingStopped"
    const val COUNTDOWN = "Countdown"
    const val RECORDING_PROGRESS = "RecordingProgress"
    const val READY_TO_RECORD = "ReadyToRecord"
    const val RERECORD = "Rerecord"

    // Streaming
    const val STREAMING_STARTED = "StreamingStarted"
    const val STREAMING_STOPPED = "StreamingStopped"

    // Camera hardware
    const val NO_CAMERA = "NoCamera"
    const val HAS_CAMERA = "HasCamera"

    // Mic hardware
    const val MIC_HEALTH = "MicrophoneHealth"
    const val NO_MIC = "NoMicrophone"
    const val HAS_MIC = "HasMicrophone"

    // Permissions
    const val ACCESS_GRANTED = "AccessGranted"
    const val ACCESS_FORBIDDEN = "AccessForbidden"

    // Uploader
    const val UPLOADING_STARTED = "UploadingStarted"
    const val UPLOAD_PROGRESS = "UploadProgress"
    const val VERIFIED = "Verified"
    const val PROCESSING = "Processing"
    const val PROCESSED = "Processed"
    const val UPLOADED = "Uploaded"

    // File selector
    const val UPLOAD_SELECTED = "UploadSelected"

    // Player
    const val PLAYING = "Playing"
    const val PAUSED = "Paused"
    const val ENDED = "Ended"
    const val SEEK = "Seek"
    const val READY_TO_PLAY = "ReadyToPlay"

    // QR scanner
    const val QR_DECODED = "QrDecoded"
}