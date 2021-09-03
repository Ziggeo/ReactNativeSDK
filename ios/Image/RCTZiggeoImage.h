//
//  RCTZiggeoImage.h
//  ReactIntegrationDemo
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#ifndef RCTZiggeoImage_h
#define RCTZiggeoImage_h

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <Ziggeo/Ziggeo.h>


@interface RCTZiggeoImage : RCTEventEmitter <RCTBridgeModule>

@property (strong, nonatomic) NSString *appToken;
@property (strong, nonatomic) NSString *serverAuthToken;
@property (strong, nonatomic) NSString *clientAuthToken;
@property (strong, nonatomic) NSMutableArray* contexts;

@end


#endif /* RCTZiggeoImage_h */
