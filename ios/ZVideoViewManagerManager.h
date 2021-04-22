#ifndef ZVideoViewManagerManager_h
#define ZVideoViewManagerManager_h

#import <Foundation/Foundation.h>
#import <React/RCTViewManager.h>

// We use the word "Manager" two times because RN function requireNativeComponent() removes
// the second word "Manager" from class names and it's called like this:
// requireNativeComponent('ZCameraViewManager',...).
// So to match the string 'ZCameraViewManager' the class should be called ZCameraViewManagerManager.
// Note that requireNativeComponent doesn't remove the prefix RCT, so we can't call this class
// RCTZCameraViewManagerManager like other classes in RN native modules.
@interface ZVideoViewManagerManager: RCTViewManager

@property (nonatomic, assign) NSString *style;

@property (nonatomic, assign) NSString *ref;

@end;

#endif /* ZCameraViewManager_h */
