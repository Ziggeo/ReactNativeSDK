#ifndef ZCameraViewManager_h
#define ZCameraViewManager_h

#import <Foundation/Foundation.h>
#import <React/RCTViewManager.h>

@interface RCTCameraViewManager: RCTViewManager

@property (nonatomic, assign) NSString *style;

@property (nonatomic, assign) NSString *ref;

@end;

#endif /* ZCameraViewManager_h */
