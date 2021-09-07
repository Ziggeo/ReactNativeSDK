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


@interface ZiggeoRecorderContext: NSObject<UIImagePickerControllerDelegate, UINavigationControllerDelegate, ZiggeoRecorderDelegate, ZiggeoUploadDelegate>

@property (strong, nonatomic) RCTPromiseResolveBlock resolveBlock;
@property (strong, nonatomic) RCTPromiseRejectBlock rejectBlock;
@property (strong, nonatomic) RCTZiggeoRecorder *recorder;
@property (nonatomic) int maxAllowedDurationInSeconds;
@property (nonatomic) bool enforceDuration;

@end;

#endif /* ZiggeoRecorderContext_h */

