//
//  ZiggeoRecorderRCT.h
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#ifndef ZiggeoRecorderRCT_h
#define ZiggeoRecorderRCT_h

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <Ziggeo/Ziggeo.h>
#import <UIKit/UIKit.h>


@interface RCTZiggeoRecorder : RCTEventEmitter <RCTBridgeModule>

@property (strong, nonatomic) NSString *appToken;
@property (strong, nonatomic) NSString *serverAuthToken;
@property (nonatomic) BOOL cameraFlipButtonVisible;
@property (nonatomic) BOOL coverSelectorEnabled;
@property (nonatomic) BOOL liveStreamingEnabled;
@property (nonatomic) NSInteger camera;
@property (nonatomic) NSInteger quality;
@property (nonatomic) NSInteger autostartRecordingAfter;
@property (nonatomic) NSInteger maxRecordingDuration;
@property (nonatomic) NSInteger videoWidth;
@property (nonatomic) NSInteger videoHeight;
@property (nonatomic) NSInteger videoBitrate;
@property (nonatomic) NSInteger audioSampleRate;
@property (nonatomic) NSInteger audioBitrate;
@property (nonatomic) NSDictionary* additionalRecordingParams;
@property (nonatomic) NSDictionary* additionalThemeParams;
@property (nonatomic) BOOL sendImmediately;
@property (strong, nonatomic) NSDictionary *cacheConfig;

@property (strong, nonatomic) NSMutableArray* contexts;

@end


#endif /* ZiggeoRecorderRCT_h */

