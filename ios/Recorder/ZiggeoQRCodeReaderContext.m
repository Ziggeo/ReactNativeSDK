//
//  ZiggeoQRCodeReaderContext.m
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZiggeoQRCodeReaderContext.h"
#import <ZiggeoMediaSDK/ZiggeoMediaSDK.h>
#import <React/RCTLog.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "RCTZiggeoRecorder.h"
#import "ZiggeoConstants.h"


@implementation ZiggeoQRCodeReaderContext {
    NSURLSessionTask *currentTask;
}

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
        if (recorder.contexts == nil) recorder.contexts = [[NSMutableArray alloc] init];
        [recorder.contexts addObject:self];
    } else if(_recorder != nil) {
        [_recorder.contexts removeObject:self];
    }
    _recorder = recorder;
}

// MARK: - ZiggeoQRCodeReaderDelegate
- (void)ziggeoQRCodeScaned:(NSString *)qrCode {
    NSLog(@"sdfsdfsdfd");
    if (_recorder != nil) {
        [_recorder sendEventWithName:[ZiggeoConstants getEventString:QR_DECODED]
                                body:@{[ZiggeoConstants getKeyString:VALUE]: qrCode}];
    }
}

@end
