#include "RCTZiggeoCameraViewManager.h"

#import <Foundation/Foundation.h>

#import "RCTBridge.h"


@implementation RCTZiggeoCameraViewManager

RCT_EXPORT_MODULE();

@synthesize bridge = _bridge;

- (UIView *)view {
    return [[RCTZiggeoCameraView alloc] initWithEventDispatcher:self.bridge.eventDispatcher];
}

- (NSArray *) customDirectEventTypes {
    return @[
        @"onFrameChange"
    ];
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}


RCT_EXPORT_VIEW_PROPERTY(style, NSString);

RCT_EXPORT_VIEW_PROPERTY(ref, NSString);



@end;
