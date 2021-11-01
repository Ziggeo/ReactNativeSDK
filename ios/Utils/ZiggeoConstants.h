//
//  Constants.h
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#import <Foundation/Foundation.h>

typedef enum {
    // Camera
    CAMERA_OPENED,
    CAMERA_CLOSED,

    // Common
    LOADED,
    CANCELLED_BY_USER,

    // Error
    ERROR,

    // Recorder
    MANUALLY_SUBMITTED,
    RECORDING_STARTED,
    RECORDING_STOPPED,
    COUNTDOWN,
    RECORDING_PROGRESS,
    READY_TO_RECORD,
    RERECORD,

    // Streaming
    STREAMING_STARTED,
    STREAMING_STOPPED,

    // Camera hardware
    NO_CAMERA,
    HAS_CAMERA,

    // Mic hardware
    MIC_HEALTH,
    NO_MIC,
    HAS_MIC,

    // Permissions
    ACCESS_GRANTED,
    ACCESS_FORBIDDEN,

    // Uploader
    UPLOADING_STARTED,
    UPLOAD_PROGRESS,
    VERIFIED,
    PROCESSING,
    PROCESSED,
    UPLOADED,

    // File selector
    UPLOAD_SELECTED,

    // Player
    PLAYING,
    PAUSED,
    ENDED,
    SEEK,
    READY_TO_PLAY,

    // QR scanner
    QR_DECODED,
} ZIGGEO_EVENTS;

#define kZiggeoEventsArray @"CameraOpened", @"CameraClosed", \
        @"Loaded", @"CancelledByUser", \
        @"Error", \
        @"ManuallySubmitted", @"RecordingStarted", @"RecordingStopped", @"Countdown", @"RecordingProgress", @"ReadyToRecord", @"Rerecord", \
        @"StreamingStarted", @"StreamingStopped", \
        @"NoCamera", @"HasCamera", \
        @"MicrophoneHealth", @"NoMicrophone", @"HasMicrophone", \
        @"AccessGranted", @"AccessForbidden", \
        @"UploadingStarted", @"UploadProgress", @"Verified", @"Processing", @"Processed", @"Uploaded", \
        @"UploadSelected", \
        @"Playing", @"Paused", @"Ended", @"Seek", @"ReadyToPlay", \
        @"QrDecoded", nil

@interface ZiggeoConstants: NSObject

+ (NSString *)getStringFromEvent:(ZIGGEO_EVENTS)event;

@end


#endif /* Constants_h */
