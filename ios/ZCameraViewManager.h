#ifndef ZCameraViewManager_h
#define ZCameraViewManager_h

#import <Foundation/Foundation.h>
#import "RCTViewManager.h"

@interface ZCameraViewManager: RCTViewManager

@property (nonatomic, assign) NSString *style;

@property (nonatomic, assign) NSString *ref;

@end;

#endif /* ZCameraViewManager_h */
