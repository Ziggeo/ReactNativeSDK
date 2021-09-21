//
//  ZiggeoRecorderContext.m
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZiggeoRecorderContext.h"
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "RotatingImagePickerController.h"
#import "ButtonConfig+parse.h"
#import "RCTZiggeoRecorder.h"
#import "ZiggeoConstants.h"


@implementation ZiggeoRecorderContext

- (void)resolve:(NSString*)token {
    if (_resolveBlock) {
        _resolveBlock(token);
    }
    _resolveBlock = nil;
    _rejectBlock = nil;
    self.recorder = nil;
}

- (void)reject:(NSString*)code message:(NSString*)message {
    if (_rejectBlock) {
        _rejectBlock(code, message, [NSError errorWithDomain:@"recorder" code:0 userInfo:@{code:message}]);
    }
    _resolveBlock = nil;
    _rejectBlock = nil;
    self.recorder = nil;
}

- (void)setRecorder:(RCTZiggeoRecorder *)recorder {
    if (recorder != nil) {
        if(recorder.contexts == nil) recorder.contexts = [[NSMutableArray alloc] init];
        [recorder.contexts addObject:self];
    } else if(_recorder != nil) {
        [_recorder.contexts removeObject:self];
    }
    _recorder = recorder;
}


// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *url = info[UIImagePickerControllerMediaURL];

        NSMutableDictionary *recordingParams = [[NSMutableDictionary alloc] init];
        if (self.recorder.additionalRecordingParams != nil) {
            [recordingParams addEntriesFromDictionary:self.recorder.additionalRecordingParams];
        }
        if (self.maxAllowedDurationInSeconds > 0) {
            if (self.enforceDuration) {
                AVAsset* audioAsset = [AVURLAsset assetWithURL:url];
                CMTime assetTime = [audioAsset duration];
                Float64 duration = CMTimeGetSeconds(assetTime);
                if (duration > self.maxAllowedDurationInSeconds) {
                    [self reject:@"ERR_DURATION_EXCEEDED" message:@"video duration is more than allowed"];
                    if (_recorder != nil) {
                        [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:ERROR] body:@{}];
                    }
                    [picker dismissViewControllerAnimated:true completion:nil];
                    return;
                }
            } else {
                NSDictionary *durationRecordingParams = @{ @"max_duration" : @(self.maxAllowedDurationInSeconds), @"enforce_duration": @"false"};
                [recordingParams addEntriesFromDictionary:durationRecordingParams];
            }
        }
        
        NSString *path = url.path;
        NSString *documentsDirectory = NSTemporaryDirectory();
        NSString *newFilePath = [documentsDirectory stringByAppendingPathComponent:@"video.mp4"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:newFilePath]) {
            [[NSFileManager defaultManager] fileExistsAtPath:newFilePath];
        }
        
        NSError *error = nil;
        BOOL success = [[NSFileManager defaultManager] copyItemAtPath:path toPath:newFilePath error:&error];
        if (success) {
            path = newFilePath;
        }

        if (_recorder != nil) {
            NSMutableArray *pathList = [NSMutableArray array];
            [pathList addObject: path];
            NSString *strList = [[pathList valueForKey:@"description"] componentsJoinedByString:@""];
            [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:UPLOAD_SELECTED] body:@{@"paths": strList}];
        }
        
        Ziggeo* m_ziggeo = [[Ziggeo alloc] initWithToken:_recorder.appToken];
        m_ziggeo.connect.serverAuthToken = _recorder.serverAuthToken;
        m_ziggeo.connect.clientAuthToken = _recorder.clientAuthToken;
        [m_ziggeo.config setRecorderCacheConfig:self.recorder.cacheConfig];
        [m_ziggeo.config setDelegate:self];
        m_ziggeo.videos.uploadDelegate = self;
        [m_ziggeo.videos uploadVideoWithPath:path];
        [picker dismissViewControllerAnimated:true completion:nil];
        
    } else if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        UIImage* imageFile = info[UIImagePickerControllerOriginalImage];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *imageFilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"image.jpg"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:imageFilePath]) {
            [[NSFileManager defaultManager] fileExistsAtPath:imageFilePath];
        }
        [UIImageJPEGRepresentation(imageFile, 0) writeToFile:imageFilePath atomically:YES];

        if (_recorder != nil) {
            NSMutableArray *pathList = [NSMutableArray array];
            [pathList addObject: imageFilePath];
            NSString *strList = [[pathList valueForKey:@"description"] componentsJoinedByString:@""];
            [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:UPLOAD_SELECTED] body:@{@"paths": strList}];
        }

        Ziggeo *m_ziggeo = [[Ziggeo alloc] initWithToken:_recorder.appToken];
        m_ziggeo.connect.serverAuthToken = _recorder.serverAuthToken;
        m_ziggeo.connect.clientAuthToken = _recorder.clientAuthToken;
        [m_ziggeo.config setDelegate:self];
        m_ziggeo.images.uploadDelegate = self;
        [m_ziggeo.images uploadImageWithPath:imageFilePath];
        // [m_ziggeo.images uploadImageWithFile:imageFile];
        [picker dismissViewControllerAnimated:true completion:nil];
        
    } else {
        [picker dismissViewControllerAnimated:true completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self reject:@"ERR_CANCELLED" message:@"cancelled by the user"];

    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:CANCELLED_BY_USER] body:@{}];
    }

    [picker dismissViewControllerAnimated:true completion:nil];
}


// MARK: - ZiggeoUploadDelegate

- (void)preparingToUploadWithPath:(NSString *)sourcePath {
}

- (void)failedToUploadWithPath:(NSString *)sourcePath {
    [self reject:@"ERR_UNKNOWN" message:@"unknown upload error"];
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:ERROR] body:@{}];
    }
}

- (void)uploadStartedWithPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken backgroundTask:(NSURLSessionTask *)uploadingTask {
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:UPLOADING_STARTED] body:@{@"path": sourcePath, @"token": token, @"streamToken": streamToken}];
    }
}

- (void)uploadProgressForPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken totalBytesSent:(int)bytesSent totalBytesExpectedToSend:(int)totalBytes {
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:UPLOAD_PROGRESS] body:@{@"path": sourcePath, @"token": token, @"streamToken": streamToken, @"uploaded_bytes": @(bytesSent), @"total_bytes": @(totalBytes)}];
    }
}

- (void)uploadFinishedForPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken {
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:UPLOADED] body:@{@"path": sourcePath, @"token": token, @"streamToken": streamToken}];
    }
}

- (void)uploadVerifiedWithPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken withResponse:(NSURLResponse *)response error:(NSError *)error json:(NSDictionary *)json {
    if (error == nil) {
        [self resolve:token];
        if (_recorder != nil) {
            [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:VERIFIED] body:@{@"path": sourcePath, @"token": token, @"streamToken": streamToken}];
        }
    } else {
        [self reject:@"ERR_UNKNOWN" message:@"unknown recorder error"];
        if (_recorder != nil) {
            [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:ERROR] body:@{}];
        }
    }
}

- (void)uploadProcessingWithPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken {
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:PROCESSING] body:@{@"path": sourcePath, @"token": token, @"streamToken": streamToken}];
    }
}

- (void)uploadProcessedWithPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken {
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:PROCESSED] body:@{@"path": sourcePath, @"token": token, @"streamToken": streamToken}];
    }
}

- (void)deleteWithToken:(NSString *)token streamToken:(NSString *)streamToken withResponse:(NSURLResponse *)response error:(NSError *)error json:(NSDictionary *)json {
}


// MARK: - ZiggeoRecorderDelegate

- (void)luxMeter:(double)luminousity {
    
}

- (void)audioMeter:(double)audioLevel {
    
}

- (void)faceDetected:(int)faceID rect:(CGRect)rect {
    
}

- (void)ziggeoRecorderReady {
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:READY_TO_RECORD] body:@{}];
    }
}

- (void)ziggeoRecorderCanceled {
    [self reject:@"ERR_CANCELLED" message:@"cancelled by the user"];

    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:CANCELLED_BY_USER] body:@{}];
    }
}

- (void)ziggeoRecorderStarted {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:RECORDING_STARTED] body:@{}];
    }
}

- (void)ziggeoRecorderStopped:(NSString *)path {
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:RECORDING_STOPPED] body:@{@"path": path}];
    }
}

- (void)ziggeoRecorderCurrentRecordedDurationSeconds:(double)seconds {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:RECORDING_PROGRESS] body:@{@"millis_passed": @(seconds)}];
    }
}

- (void)ziggeoRecorderPlaying {

}

- (void)ziggeoRecorderPaused {

}

- (void)ziggeoRecorderRerecord {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:RERECORD] body:@{}];
    }
}

- (void)ziggeoRecorderManuallySubmitted {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:MANUALLY_SUBMITTED] body:@{}];
    }
}

- (void)ziggeoStreamingStarted {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:STREAMING_STARTED] body:@{}];
    }
}

- (void)ziggeoStreamingStopped {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:STREAMING_STOPPED] body:@{}];
    }
}


// MARK: - ZiggeoHardwarePermissionCheckDelegate

- (void)checkCameraPermission:(BOOL)granted {
    if (_recorder != nil) {
        if (granted) {
            [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:ACCESS_GRANTED] body:@{@"permission_type": @"camera"}];
        } else {
            [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:ACCESS_FORBIDDEN] body:@{@"permission_type": @"camera"}];
        }
    }
}

- (void)checkMicrophonePermission:(BOOL)granted {
    if (_recorder != nil) {
        if (granted) {
            [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:ACCESS_GRANTED] body:@{@"permission_type": @"microphone"}];
        } else {
            [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:ACCESS_FORBIDDEN] body:@{@"permission_type": @"microphone"}];
        }
    }
}

- (void)checkPhotoLibraryPermission:(BOOL)granted {
    if (_recorder != nil) {
        if (granted) {
            [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:ACCESS_GRANTED] body:@{@"permission_type": @"photo_library"}];
        } else {
            [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:ACCESS_FORBIDDEN] body:@{@"permission_type": @"photo_library"}];
        }
    }
}

- (void)checkHasCamera:(BOOL)hasCamera {
    if (_recorder != nil) {
        if (hasCamera) {
            [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:HAS_CAMERA] body:@{}];
        } else {
            [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:NO_CAMERA] body:@{}];
        }
    }
}

- (void)checkHasMicrophone:(BOOL)hasMicrophone {
    if (_recorder != nil) {
        if (hasMicrophone) {
            [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:HAS_MIC] body:@{}];
        } else {
            [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:NO_MIC] body:@{}];
        }
    }
}


// MARK: - ZiggeoPlayerDelegate

- (void)ziggeoPlayerPlaying {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:PLAYING] body:@{}];
    }
}

- (void)ziggeoPlayerPaused {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:PAUSED] body:@{}];
    }
}

- (void)ziggeoPlayerEnded {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:ENDED] body:@{}];
    }
}

- (void)ziggeoPlayerSeek:(double)positionMillis {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:SEEK] body:@{@"positionMillis": @(positionMillis)}];
    }
}

- (void)ziggeoPlayerReadyToPlay {
    if (_recorder != nil) {
       [_recorder sendEventWithName:[ZiggeoConstants getStringFromEvent:READY_TO_PLAY] body:@{}];
    }
}

@end
