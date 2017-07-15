//
//  RCTZiggeoPlayer.h
//  ReactIntegrationDemo
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#ifndef RCTZiggeoPlayer_h
#define RCTZiggeoPlayer_h


#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <Ziggeo/Ziggeo.h>

@interface RCTZiggeoPlayer : NSObject <RCTBridgeModule>

@property (strong, nonatomic) NSString *appToken;

@end


#endif /* RCTZiggeoPlayer_h */
