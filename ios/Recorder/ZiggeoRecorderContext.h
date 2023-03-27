//
//  ZiggeoRecorderContext.h
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#ifndef ZiggeoRecorderContext_h
#define ZiggeoRecorderContext_h

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <ZiggeoMediaSDK/ZiggeoMediaSDK.h>
#import <UIKit/UIKit.h>
@class RCTZiggeoRecorder;


@interface ZiggeoRecorderContext: NSObject<ZiggeoHardwarePermissionDelegate, ZiggeoUploadingDelegate, ZiggeoFileSelectorDelegate, ZiggeoRecorderDelegate, ZiggeoSensorDelegate, ZiggeoPlayerDelegate, ZiggeoScreenRecorderDelegate>

@property (strong, nonatomic) RCTPromiseResolveBlock resolveBlock;
@property (strong, nonatomic) RCTPromiseRejectBlock rejectBlock;
@property (strong, nonatomic) RCTZiggeoRecorder *recorder;
@property (nonatomic) int maxAllowedDurationInSeconds;
@property (nonatomic) bool enforceDuration;
@property (nonatomic) NSDictionary *extraArgs;

@end;

#endif /* ZiggeoRecorderContext_h */

