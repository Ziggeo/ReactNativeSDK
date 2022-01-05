#ifndef ZiggeoRCTImages_h
#define ZiggeoRCTImages_h

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <Ziggeo/Ziggeo.h>
#import <UIKit/UIKit.h>


@interface RCTImages : RCTEventEmitter <RCTBridgeModule>

+ (NSString *)appToken;
+ (NSString *)serverAuthToken;
+ (NSString *)clientAuthToken;

@end

#endif /* ZiggeoRCTImages_h */

