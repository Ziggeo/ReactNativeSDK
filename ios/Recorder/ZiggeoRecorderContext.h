//
//  ZiggeoRecorderContext.h
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#ifndef ZiggeoRecorderContext_h
#define ZiggeoRecorderContext_h

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <Ziggeo/Ziggeo.h>
#import <UIKit/UIKit.h>
@class RCTZiggeoRecorder;


@interface ZiggeoRecorderContext: NSObject<UIImagePickerControllerDelegate, UINavigationControllerDelegate, ZiggeoRecorderDelegate, ZiggeoUploadDelegate, ZiggeoHardwarePermissionCheckDelegate, ZiggeoPlayerDelegate>

@property (strong, nonatomic) RCTPromiseResolveBlock resolveBlock;
@property (strong, nonatomic) RCTPromiseRejectBlock rejectBlock;
@property (strong, nonatomic) RCTZiggeoRecorder *recorder;
@property (nonatomic) int maxAllowedDurationInSeconds;
@property (nonatomic) bool enforceDuration;
@property (nonatomic) Ziggeo *currentZiggeo;
@property (nonatomic) NSDictionary *extraArgs;

- (void)cancelRequest;

@end;

#endif /* ZiggeoRecorderContext_h */

