#import <Foundation/Foundation.h>
#import <Ziggeo/Ziggeo.h>

#import "RCTBridgeModule.h"
#import "RCTEventDispatcher.h"
#import "UIView+React.h"
#import "ZVideoView.h"
#import "RCTVideos.h"


@implementation ZVideoView {
    RCTEventDispatcher *_eventDispatcher;
}

- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher {
    if ((self = [super init])) {
        _eventDispatcher = eventDispatcher;
    }

    return self;
}

@end;
