//
//  Constants.h
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#import <Foundation/Foundation.h>
#import <ZiggeoMediaSDK/ZiggeoMediaSDK.h>
#import "ZiggeoRecorderContext.h"

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

#define kZiggeoKeysArray @"bytesSent", @"totalBytes", @"fileName", @"path", @"qr", @"token", \
    @"permissions", @"sound_level", @"seconds_left", @"millis_passed", @"millis", @"files", @"value", \
    @"media_types", @"blur_effect", @"client_auth", @"server_auth", @"tags", nil

#define kZiggeoConstants  @{  \
    @"rearCamera": @"rearCamera", \
    @"frontCamera": @"frontCamera", \
    @"highQuality": @"highQuality", \
    @"mediumQuality": @"mediumQuality", \
    @"lowQuality": @"lowQuality", \
    @"ERR_UNKNOWN": @"ERR_UNKNOWN", \
    @"ERR_DURATION_EXCEEDED": @"ERR_DURATION_EXCEEDED", \
    @"ERR_FILE_DOES_NOT_EXIST": @"ERR_FILE_DOES_NOT_EXIST", \
    @"ERR_PERMISSION_DENIED": @"ERR_PERMISSION_DENIED", \
    @"max_duration": @"max_duration", \
    @"enforce_duration": @"enforce_duration", \
};

@interface ZiggeoConstants: NSObject

+ (NSString *)getEventString:(ZIGGEO_EVENTS)event;
+ (NSString *)getKeyString:(Ziggeo_Key_Type)key;
+ (void)setAppToken:(NSString *)appToken;
+ (Ziggeo *)sharedZiggeoInstance;
+ (ZiggeoRecorderContext *)sharedZiggeoRecorderContextInstance;

@end


#endif /* Constants_h */
