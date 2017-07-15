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

@interface RCTZiggeoRecorder : RCTEventEmitter <RCTBridgeModule, ZiggeoRecorder2Delegate, ZiggeoVideosDelegate>

@property (strong, nonatomic) NSString *appToken;
@property (nonatomic) BOOL cameraFlipButtonVisible;
@property (nonatomic) BOOL coverSelectorEnabled;
@property (nonatomic) NSInteger camera;


@end


#endif /* ZiggeoRecorderRCT_h */
