#import <Foundation/Foundation.h>

#import "RCTZiggeoVideoView.h"
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>
#import "RCTVideos.h"
@import AVKit;

@implementation RCTZiggeoVideoView {
    RCTEventDispatcher *_eventDispatcher;
    ZiggeoPlayerReferenceBlock _ref;
    NSArray *_tokens;
    AVPlayerViewController* playerController;
}

- (UIView *)view
{
    return playerController.view;
}

- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher tokens:(NSArray *)tokens {
    if ((self = [super init])) {
        _eventDispatcher = eventDispatcher;
        _tokens = tokens;
    }

    return self;
}

@end
