#ifndef RCTZiggeo_h
#define RCTZiggeo_h

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>


@interface RCTZiggeo: RCTEventEmitter <RCTBridgeModule>

@property (class) NSString *appToken;
@property (class) NSString *serverAuthToken;
@property (class) NSString *clientAuthToken;

@end

#endif /* RCTZiggeo_h */