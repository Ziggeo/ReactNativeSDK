#ifndef ZiggeoRCTVideos_h
#define ZiggeoRCTVideos_h

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <Ziggeo/Ziggeo.h>
#import <UIKit/UIKit.h>


@interface RCTVideos : RCTEventEmitter <RCTBridgeModule>

+ (NSString *) _appToken;
+ (NSString *) _serverAuthToken;
+ (NSString *) _clientAuthToken;

@end

#endif /* ZiggeoRCTVideos_h */

