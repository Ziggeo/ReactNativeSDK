#ifndef RCTCameraModule_h
#define RCTCameraModule_h

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <Ziggeo/Ziggeo.h>
#import <UIKit/UIKit.h>


@interface RCTZCameraModule : RCTEventEmitter <RCTBridgeModule>

+ (void) setLastZiggeoRecorder:(ZiggeoRecorder *) recorder;

@end

#endif
