#ifndef ZiggeoRCTVideos_h
#define ZiggeoRCTVideos_h

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <Ziggeo/Ziggeo.h>
#import <UIKit/UIKit.h>


@interface RCTVideos : RCTEventEmitter <RCTBridgeModule>

@property (strong, nonatomic) NSString *appToken;
@property (strong, nonatomic) NSString *serverAuthToken;
@property (strong, nonatomic) NSString *clientAuthToken;

+ (NSString *) _appToken;
+ (NSString *) _serverAuthToken;
+ (NSString *) _clientAuthToken;

@end

#endif /* ZiggeoRCTVideos_h */

