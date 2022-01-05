#ifndef ZiggeoRCTVideos_h
#define ZiggeoRCTVideos_h

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <Ziggeo/Ziggeo.h>
#import <UIKit/UIKit.h>


@interface RCTVideos : RCTEventEmitter <RCTBridgeModule>

+ (NSString *)appToken;
+ (NSString *)serverAuthToken;
+ (NSString *)clientAuthToken;

@end

#endif /* ZiggeoRCTVideos_h */

