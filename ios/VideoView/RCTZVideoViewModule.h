#ifndef RCTZVideoViewModule_h
#define RCTZVideoViewModule_h

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <ZiggeoMediaSDK/ZiggeoMediaSDK.h>
#import <UIKit/UIKit.h>


@interface RCTZVideoViewModule : RCTEventEmitter <RCTBridgeModule>

+ (void) setLastZiggeoPlayer:(ZiggeoPlayer *) player;

+ (RCTZVideoViewModule *) instance;

@end

#endif
