//
//  RCTZiggeoRecorder.h
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#ifndef RCTZiggeoRecorder_h
#define RCTZiggeoRecorder_h

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <Ziggeo/Ziggeo.h>
#import <UIKit/UIKit.h>


@interface RCTZiggeoRecorder : RCTEventEmitter <RCTBridgeModule>

@property (strong, nonatomic) NSString *appToken;
@property (strong, nonatomic) NSString *serverAuthToken;
@property (strong, nonatomic) NSString *clientAuthToken;
@property (strong, nonatomic) NSMutableArray* contexts;

@end


#endif /* RCTZiggeoRecorder_h */

