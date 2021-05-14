#ifndef RCTZVideoViewModule_h
#define RCTZVideoViewModule_h

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <Ziggeo/Ziggeo.h>
#import <UIKit/UIKit.h>


@interface RCTZVideoViewModule : RCTEventEmitter <RCTBridgeModule>

+ (void) setLastZiggeoPlayer:(ZiggeoPlayer *) player;

@end

#endif
