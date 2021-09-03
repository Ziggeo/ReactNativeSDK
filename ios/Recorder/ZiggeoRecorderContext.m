//
//  ZiggeoRecorderContext.m
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZiggeoRecorderContext.h"
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>
#import "RotatingImagePickerController.h"
#import "ButtonConfig+parse.h"
#import "RCTZiggeoRecorder.h"

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
    NSURL* url = info[@"UIImagePickerControllerMediaURL"];
    
    NSMutableDictionary* recordingParams = [[NSMutableDictionary alloc] init];
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
                [picker dismissViewControllerAnimated:true completion:nil];
                return;
            }
        } else {
            NSDictionary *durationRecordingParams = @{ @"max_duration" : @(self.maxAllowedDurationInSeconds), @"enforce_duration": @"false"};
            [recordingParams addEntriesFromDictionary:durationRecordingParams];
        }
    }
    
    Ziggeo* m_ziggeo = [[Ziggeo alloc] initWithToken:_recorder.appToken];
    m_ziggeo.connect.serverAuthToken = _recorder.serverAuthToken;
    m_ziggeo.connect.clientAuthToken = _recorder.clientAuthToken;
    [m_ziggeo.config setRecorderCacheConfig:self.recorder.cacheConfig];
    m_ziggeo.videos.uploadDelegate = self;
    [m_ziggeo.videos uploadVideoWithPath:url.path];
    
    _pickerController = picker;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"image picker cancelled delegate");
    [self reject:@"ERR_CANCELLED" message:@"cancelled by the user"];
    [picker dismissViewControllerAnimated:true completion:nil];
}


// MARK: - ZiggeoUploadDelegate

- (void)preparingToUploadWithPath:(NSString *)sourcePath {
}

- (void)preparingToUploadWithPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken {
    // dispatch_async(dispatch_get_main_queue(), ^{
    //     if (self->_pickerController != nil) {
    //         [self->_pickerController dismissViewControllerAnimated:true completion:nil];
    //         self->_pickerController = nil;
    //     }
    // });
}

- (void)failedToUploadWithPath:(NSString *)sourcePath {
    // dispatch_async(dispatch_get_main_queue(), ^{
    //     if (self->_pickerController != nil) {
    //         [self->_pickerController dismissViewControllerAnimated:true completion:nil];
    //         self->_pickerController = nil;
    //     }
    // });
}

- (void)uploadStartedWithPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken backgroundTask:(NSURLSessionTask *)uploadingTask {
}

- (void)uploadProgressForPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken totalBytesSent:(int)bytesSent totalBytesExpectedToSend:(int)totalBytes {
//    if (_recorder != nil) {
//        [_recorder sendEventWithName:@"UploadProgress" body:@{@"bytesSent": @(bytesSent), @"totalBytes":@(totalBytes), @"fileName":sourcePath, @"token":token }];
//    }
}

- (void)uploadCompletedForPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken withResponse:(NSURLResponse *)response error:(NSError *)error json:(NSDictionary *)json {
    if (error == nil) {
        [self resolve:token];
    } else {
        [self reject:@"ERR_UNKNOWN" message:@"unknown recorder error"];
    }
}

- (void)deleteWithToken:(NSString *)token streamToken:(NSString *)streamToken withResponse:(NSURLResponse *)response error:(NSError *)error json:(NSDictionary *)json {
}


// MARK: - ZiggeoRecorderDelegate

- (void)ziggeoRecorderDidCancel {
    [self reject:@"ERR_CANCELLED" message:@"cancelled by the user"];
}

- (void)ziggeoRecorderDidStop {
//    if (_recorder != nil) {
//        [_recorder sendEventWithName:@"RecordingStopped" body:@{}];
//    }
}

- (void)ziggeoRecorderCurrentRecordedDurationSeconds:(double)seconds {
//    if (_recorder != nil) {
//        [_recorder sendEventWithName:@"RecordingProcessing" body:@{@"currentTime": @(seconds)}];
//    }
}

- (void)luxMeter:(double)luminousity {
    
}

- (void)audioMeter:(double)audioLevel {
    
}

- (void)faceDetected:(int)faceID rect:(CGRect)rect {
    
}

@end
