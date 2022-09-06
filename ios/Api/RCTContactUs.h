#ifndef ZiggeoRCTContactUs_h
#define ZiggeoRCTContactUs_h

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <Ziggeo/Ziggeo.h>
#import <UIKit/UIKit.h>


@interface RCTContactUs : RCTEventEmitter <RCTBridgeModule>

+ (NSString *)appToken;
+ (NSString *)serverAuthToken;
+ (NSString *)clientAuthToken;

@end

#endif /* ZiggeoRCTContactUs_h */

