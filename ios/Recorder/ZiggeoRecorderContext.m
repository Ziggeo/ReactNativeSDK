//
//  ZiggeoRecorderContext.m
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZiggeoRecorderContext.h"
#import <ZiggeoMediaSDK/ZiggeoMediaSDK.h>
#import <React/RCTLog.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "RCTZiggeoRecorder.h"
#import "ZiggeoConstants.h"


@implementation ZiggeoRecorderContext {
    NSURLSessionTask *currentTask;
}

- (void)resolve:(NSString*)token {
    if (_resolveBlock) {
        _resolveBlock(token);
    }
    _resolveBlock = nil;
    _rejectBlock = nil;
    // self.recorder = nil;
}

- (void)reject:(NSString*)code message:(NSString*)message {
    if (_rejectBlock) {
        _rejectBlock(code, message, [NSError errorWithDomain:@"recorder" code:0 userInfo:@{code:message}]);
    }
    _resolveBlock = nil;
    _rejectBlock = nil;
    // self.recorder = nil;
}

- (void)setRecorder:(RCTZiggeoRecorder *)recorder {
    if (recorder != nil) {
        if (recorder.contexts == nil) recorder.contexts = [[NSMutableArray alloc] init];
        [recorder.contexts addObject:self];
    } 
    if (_recorder != nil) {
        [_recorder.contexts removeObject:self];
    }
    _recorder = recorder;

    Ziggeo* m_ziggeo = [ZiggeoConstants sharedZiggeoInstance];
    [m_ziggeo setHardwarePermissionDelegate:self];
    [m_ziggeo setUploadingDelegate:self];
    [m_ziggeo setFileSelectorDelegate:self];
    [m_ziggeo setRecorderDelegate:self];
    [m_ziggeo setSensorDelegate:self];
    [m_ziggeo setPlayerDelegate:self];
    [m_ziggeo setScreenRecorderDelegate:self];
}


// MARK: - ZiggeoHardwarePermissionDelegate

- (void)checkCameraPermission:(BOOL)granted {
    if (_recorder != nil) {
        if (granted) {
            [_recorder sendEventWithName:[ZiggeoConstants getEventString:ACCESS_GRANTED]
                                    body:@{[ZiggeoConstants getKeyString:PERMISSIONS]: @"camera"}];
        } else {
            [_recorder sendEventWithName:[ZiggeoConstants getEventString:ACCESS_FORBIDDEN]
                                    body:@{[ZiggeoConstants getKeyString:PERMISSIONS]: @"camera"}];
        }
    }
}

- (void)checkMicrophonePermission:(BOOL)granted {
    if (_recorder != nil) {
        if (granted) {
            [_recorder sendEventWithName:[ZiggeoConstants getEventString:ACCESS_GRANTED]
                                    body:@{[ZiggeoConstants getKeyString:PERMISSIONS]: @"microphone"}];
        } else {
            [_recorder sendEventWithName:[ZiggeoConstants getEventString:ACCESS_FORBIDDEN]
                                    body:@{[ZiggeoConstants getKeyString:PERMISSIONS]: @"microphone"}];
        }
    }
}

- (void)checkPhotoLibraryPermission:(BOOL)granted {
    if (_recorder != nil) {
        if (granted) {
            [_recorder sendEventWithName:[ZiggeoConstants getEventString:ACCESS_GRANTED]
                                    body:@{[ZiggeoConstants getKeyString:PERMISSIONS]: @"photo_library"}];
        } else {
            [_recorder sendEventWithName:[ZiggeoConstants getEventString:ACCESS_FORBIDDEN]
                                    body:@{[ZiggeoConstants getKeyString:PERMISSIONS]: @"photo_library"}];
        }
    }
}

- (void)checkHasCamera:(BOOL)hasCamera {
    if (_recorder != nil) {
        if (hasCamera) {
            [_recorder sendEventWithName:[ZiggeoConstants getEventString:HAS_CAMERA] body:@{}];
        } else {
            [_recorder sendEventWithName:[ZiggeoConstants getEventString:NO_CAMERA] body:@{}];
        }
    }
}

- (void)checkHasMicrophone:(BOOL)hasMicrophone {
    if (_recorder != nil) {
        if (hasMicrophone) {
            [_recorder sendEventWithName:[ZiggeoConstants getEventString:HAS_MIC] body:@{}];
        } else {
            [_recorder sendEventWithName:[ZiggeoConstants getEventString:NO_MIC] body:@{}];
        }
    }
}


// MARK: - ZiggeoUploadingDelegate

- (void)preparingToUploadWithPath:(NSString *)sourcePath {
}

- (void)failedToUploadWithPath:(NSString *)sourcePath {
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getEventString:ERROR] body:@{}];
    }
    [self reject:@"ERR_UNKNOWN" message:@"unknown upload error"];
}

- (void)uploadStartedWithPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken backgroundTask:(NSURLSessionTask *)uploadingTask {
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getEventString:UPLOADING_STARTED]
                                body:@{[ZiggeoConstants getKeyString:PATH]: sourcePath,
                                       [ZiggeoConstants getKeyString:TOKEN]: token,
                                       @"stream_token": streamToken
                                     }
        ];
    }
    currentTask = uploadingTask;
}

- (void)uploadProgressWithPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken totalBytesSent:(int)bytesSent totalBytesExpectedToSend:(int)totalBytes {
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getEventString:UPLOAD_PROGRESS]
                                body:@{[ZiggeoConstants getKeyString:PATH]: sourcePath,
                                       [ZiggeoConstants getKeyString:TOKEN]: token,
                                       @"stream_token": streamToken,
                                       [ZiggeoConstants getKeyString:BYTES_SENT]: @(bytesSent),
                                       [ZiggeoConstants getKeyString:BYTES_TOTAL]: @(totalBytes)
                                     }
        ];
    }
}

- (void)uploadFinishedWithPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken {
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getEventString:UPLOADED]
                                body:@{[ZiggeoConstants getKeyString:PATH]: sourcePath,
                                       [ZiggeoConstants getKeyString:TOKEN]: token,
                                       @"stream_token": streamToken
                                     }
        ];
    }
}

- (void)uploadVerifiedWithPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken withResponse:(NSURLResponse *)response error:(NSError *)error json:(NSDictionary *)json {
    if (error == nil) {
        if (_recorder != nil) {
            [_recorder sendEventWithName:[ZiggeoConstants getEventString:VERIFIED]
                                    body:@{[ZiggeoConstants getKeyString:PATH]: sourcePath,
                                           [ZiggeoConstants getKeyString:TOKEN]: token,
                                           @"stream_token": streamToken
                                         }
            ];
        }
    } else {
        if (_recorder != nil) {
            [_recorder sendEventWithName:[ZiggeoConstants getEventString:ERROR] body:@{}];
        }
        [self reject:@"ERR_UNKNOWN" message:@"unknown recorder error"];
    }
}

- (void)uploadProcessingWithPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken {
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getEventString:PROCESSING]
                                body:@{[ZiggeoConstants getKeyString:PATH]: sourcePath,
                                       [ZiggeoConstants getKeyString:TOKEN]: token,
                                       @"stream_token": streamToken
                                     }
        ];
    }
}

- (void)uploadProcessedWithPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken {
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getEventString:PROCESSED]
                                body:@{[ZiggeoConstants getKeyString:PATH]: sourcePath,
                                       [ZiggeoConstants getKeyString:TOKEN]: token,
                                       @"stream_token": streamToken
                                     }
        ];
    }
    [self resolve:token];
}

- (void)deleteWithToken:(NSString *)token streamToken:(NSString *)streamToken withResponse:(NSURLResponse *)response error:(NSError *)error json:(NSDictionary *)json {
}

- (void)cancelUploadByPath:(NSString *)sourcePath deleteFile:(BOOL)deleteFile {
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getEventString:CANCELLED_BY_USER]
                                body:@{@"type": @"Upload"}
        ];
    }
    [self reject:@"ERR_CANCELLED" message:@"cancelled by the user"];
}

- (void)cancelCurrentUpload:(BOOL)deleteFile {
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getEventString:CANCELLED_BY_USER]
                                body:@{@"type": @"Upload"}
        ];
    }
    [self reject:@"ERR_CANCELLED" message:@"cancelled by the user"];
}


// MARK: - ZiggeoFileSelectorDelegate

- (void)uploadSelected:(NSArray *)paths {
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getEventString:UPLOAD_SELECTED]
                                body:@{[ZiggeoConstants getKeyString:PATH]: paths}
        ];
    }
}

- (void)uploadCancelledByUser {    
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getEventString:CANCELLED_BY_USER]
                                body:@{@"type": @"Upload"}
        ];
    }
    [self reject:@"ERR_CANCELLED" message:@"cancelled by the user"];
}


// MARK: - ZiggeoRecorderDelegate

- (void)recorderReady {
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getEventString:READY_TO_RECORD] body:@{}];
    }
}

- (void)recorderCancelledByUser {
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getEventString:CANCELLED_BY_USER]
                                body:@{@"type": @"Recorder"}
        ];
    }
    [self reject:@"ERR_CANCELLED" message:@"cancelled by the user"];
}

- (void)recorderStarted {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getEventString:RECORDING_STARTED] body:@{}];
    }
}

- (void)recorderStopped:(NSString *)path {
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getEventString:RECORDING_STOPPED]
                                body:@{[ZiggeoConstants getKeyString:PATH]: path}];
    }
}

- (void)recorderCurrentRecordedDurationSeconds:(double)seconds {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getEventString:RECORDING_PROGRESS]
                               body:@{[ZiggeoConstants getKeyString:MILLIS_PASSED]: @(seconds)}];
    }
}

- (void)recorderPlaying {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getEventString:PLAYING] body:@{}];
    }
}

- (void)recorderPaused {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getEventString:PAUSED] body:@{}];
    }
}

- (void)recorderRerecord {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getEventString:RERECORD] body:@{}];
    }
}

- (void)recorderManuallySubmitted {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getEventString:MANUALLY_SUBMITTED] body:@{}];
    }
}

- (void)streamingStarted {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getEventString:STREAMING_STARTED] body:@{}];
    }
}

- (void)streamingStopped {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getEventString:STREAMING_STOPPED] body:@{}];
    }
}


// MARK: - ZiggeoSensorDelegate

- (void)luxMeter:(double)luminousity {
    
}

- (void)audioMeter:(double)audioLevel {
    
}

- (void)faceDetected:(int)faceID rect:(CGRect)rect {
    
}


// MARK: - ZiggeoPlayerDelegate

- (void)playerPlaying {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getEventString:PLAYING] body:@{}];
    }
}

- (void)playerPaused {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getEventString:PAUSED] body:@{}];
    }
}

- (void)playerEnded {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getEventString:ENDED] body:@{}];
    }
}

- (void)playerSeek:(double)positionMillis {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getEventString:SEEK]
                               body:@{[ZiggeoConstants getKeyString:MILLIS]: @(positionMillis)}];
    }
}

- (void)playerReadyToPlay {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getEventString:READY_TO_PLAY] body:@{}];
    }
}

- (void)playerCancelledByUser {
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getEventString:CANCELLED_BY_USER]
                                body:@{@"type": @"Player"}
        ];
    }
    [self reject:@"ERR_CANCELLED" message:@"cancelled by the user"];
}


// MARK: - ZiggeoScreenRecorderDelegate


@end
