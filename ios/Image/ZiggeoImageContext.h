//
//  ZiggeoImageContext.h
//  ReactIntegrationDemo
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#ifndef ZiggeoImageContext_h
#define ZiggeoImageContext_h

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTLog.h>
#import <Ziggeo/Ziggeo.h>

@class RCTZiggeoImage;

@interface ZiggeoImageContext: NSObject<UIImagePickerControllerDelegate, UINavigationControllerDelegate, ZiggeoUploadDelegate>

@property (strong, nonatomic) RCTPromiseResolveBlock resolveBlock;
@property (strong, nonatomic) RCTPromiseRejectBlock rejectBlock;
@property (strong, nonatomic) RCTZiggeoImage* ziggeoImage;

- (void)resolve:(NSString*)token;
- (void)reject:(NSString*)code message:(NSString*)message;
- (void)setImage:(RCTZiggeoImage *)image;

@end;


#endif /* ZiggeoImageContext_h */
