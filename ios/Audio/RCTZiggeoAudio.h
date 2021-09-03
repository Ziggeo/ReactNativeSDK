//
//  RCTZiggeoAudio.h
//  ReactIntegrationDemo
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#ifndef RCTZiggeoAudio_h
#define RCTZiggeoAudio_h

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <Ziggeo/Ziggeo.h>


@interface RCTZiggeoAudio : RCTEventEmitter <RCTBridgeModule>

@property (strong, nonatomic) NSString *appToken;
@property (strong, nonatomic) NSString *serverAuthToken;
@property (strong, nonatomic) NSString *clientAuthToken;
@property (strong, nonatomic) NSMutableArray* contexts;

@end


#endif /* RCTZiggeoAudio_h */
