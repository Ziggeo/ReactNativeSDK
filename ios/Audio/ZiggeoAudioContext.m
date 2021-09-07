//
//  ZiggeoAudioContext.m
//  ReactIntegrationDemo
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

@import AVKit;
#import <Foundation/Foundation.h>
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>
#import "ZiggeoAudioContext.h"
#import "RCTZiggeoAudio.h"

@implementation ZiggeoAudioContext

- (void)resolve:(NSString*)token {
    if (_resolveBlock)
        _resolveBlock(token);
    
    _resolveBlock = nil;
    _rejectBlock = nil;
    _ziggeoAudio = nil;
}

- (void)reject:(NSString*)code message:(NSString*)message {
    if (_rejectBlock)
        _rejectBlock(code, message, [NSError errorWithDomain:@"ziggeo_audio" code:0 userInfo:@{code:message}]);
    
    _resolveBlock = nil;
    _rejectBlock = nil;
    _ziggeoAudio = nil;
}

- (void)setZiggeoAudio:(RCTZiggeoAudio *)ziggeoAudio {
    if (ziggeoAudio != nil) {
        if (ziggeoAudio.contexts == nil)
            ziggeoAudio.contexts = [[NSMutableArray alloc] init];
        [ziggeoAudio.contexts addObject:self];
    } else if(_ziggeoAudio != nil) {
        [_ziggeoAudio.contexts removeObject:self];
    }
    _ziggeoAudio = ziggeoAudio;
}


// MARK: - ZiggeoUploadDelegate

- (void)preparingToUploadWithPath:(NSString *)sourcePath {
    
}

- (void)preparingToUploadWithPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken {
    
}

- (void)failedToUploadWithPath:(NSString *)sourcePath {
    
}

- (void)uploadStartedWithPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken backgroundTask:(NSURLSessionTask *)uploadingTask {
    
}

- (void)uploadProgressForPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken totalBytesSent:(int)bytesSent totalBytesExpectedToSend:(int)totalBytes {
//    if (_ziggeoAudio != nil) {
//        [_ziggeoAudio sendEventWithName:@"UploadProgress" body:@{@"bytesSent": @(bytesSent), @"totalBytes":@(totalBytes), @"fileName":sourcePath, @"token":token }];
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


// MARK: - ZiggeoAudioRecorderDelegate

- (void)ziggeoAudioRecorderReady {
    
}

- (void)ziggeoAudioRecorderCanceled {
    
}

- (void)ziggeoAudioRecorderRecoding {
    
}

- (void)ziggeoAudioRecorderCurrentRecordedDurationSeconds:(double)seconds {
    
}

- (void)ziggeoAudioRecorderFinished:(double)seconds {
    
}

- (void)ziggeoAudioRecorderPlaying {
    
}

- (void)ziggeoAudioRecorderPaused {
    
}

@end
