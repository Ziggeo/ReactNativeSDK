//
//  ZiggeoAudioContext.h
//  ReactIntegrationDemo
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#ifndef ZiggeoAudioContext_h
#define ZiggeoAudioContext_h

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTLog.h>
#import <Ziggeo/Ziggeo.h>

@class RCTZiggeoAudio;

@interface ZiggeoAudioContext: NSObject<ZiggeoAudioRecorderDelegate, ZiggeoUploadDelegate>

@property (strong, nonatomic) RCTPromiseResolveBlock resolveBlock;
@property (strong, nonatomic) RCTPromiseRejectBlock rejectBlock;
@property (strong, nonatomic) RCTZiggeoAudio* ziggeoAudio;

- (void)resolve:(NSString*)token;
- (void)reject:(NSString*)code message:(NSString*)message;
- (void)setAudio:(RCTZiggeoAudio *)audio;

@end;


#endif /* RCTZiggeoAudioContext_h */
