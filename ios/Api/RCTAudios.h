#ifndef ZiggeoRCTAudios_h
#define ZiggeoRCTAudios_h

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <Ziggeo/Ziggeo.h>
#import <UIKit/UIKit.h>


@interface RCTAudios : RCTEventEmitter <RCTBridgeModule>

+ (NSString *)appToken;
+ (NSString *)serverAuthToken;
+ (NSString *)clientAuthToken;

@end

#endif /* ZiggeoRCTAudios_h */

