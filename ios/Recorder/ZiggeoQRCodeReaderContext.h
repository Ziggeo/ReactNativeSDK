//
//  ZiggeoQRCodeReaderContext.h
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#ifndef ZiggeoQRCodeReaderContext_h
#define ZiggeoQRCodeReaderContext_h

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <ZiggeoMediaSDK/ZiggeoMediaSDK.h>
#import <UIKit/UIKit.h>
@class RCTZiggeoRecorder;


@interface ZiggeoQRCodeReaderContext: NSObject<ZiggeoQRCodeReaderDelegate>

@property (strong, nonatomic) RCTPromiseResolveBlock resolveBlock;
@property (strong, nonatomic) RCTPromiseRejectBlock rejectBlock;
@property (strong, nonatomic) RCTZiggeoRecorder *recorder;

@end;

#endif /* ZiggeoQRCodeReaderContext_h */

