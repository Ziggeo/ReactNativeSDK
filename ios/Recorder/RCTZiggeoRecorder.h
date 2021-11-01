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


// FOUNDATION_EXPORT NSString *const rearCamera;
// FOUNDATION_EXPORT NSString *const frontCamera;
// FOUNDATION_EXPORT NSString *const highQuality;
// FOUNDATION_EXPORT NSString *const mediumQuality;
// FOUNDATION_EXPORT NSString *const lowQuality;
// FOUNDATION_EXPORT NSString *const ERR_UNKNOWN;
// FOUNDATION_EXPORT NSString *const ERR_DURATION_EXCEEDED;
// FOUNDATION_EXPORT NSString *const ERR_FILE_DOES_NOT_EXIST;
// FOUNDATION_EXPORT NSString *const ERR_PERMISSION_DENIED;
// FOUNDATION_EXPORT NSString *const max_duration;
// FOUNDATION_EXPORT NSString *const enforce_duration;

// FOUNDATION_EXPORT NSString *const video;
// FOUNDATION_EXPORT NSString *const audio;
// FOUNDATION_EXPORT NSString *const image;


@interface RCTZiggeoRecorder : RCTEventEmitter <RCTBridgeModule>

@property (strong, nonatomic) NSString *appToken;
@property (strong, nonatomic) NSString *serverAuthToken;
@property (strong, nonatomic) NSString *clientAuthToken;
@property (strong, nonatomic) NSMutableArray* contexts;


@end


#endif /* RCTZiggeoRecorder_h */

