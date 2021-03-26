#import <Foundation/Foundation.h>
#import <Ziggeo/Ziggeo.h>

#import "RCTBridgeModule.h"
#import "RCTEventDispatcher.h"
#import "UIView+React.h"


@implementation RCTZiggeoCameraView : UIView {
    RCTEventDispatcher *_eventDispatcher;

    dispatch_block_t cleanup;
    NSString *m_videoToken;
    NSTimer *durationUpdateTimer;
    bool _showLightIndicator, _showFaceOutline, _showAudioIndicator;
    AVLayerVideoGravity _videoGravity;
    int delayCountdownCounter;
}

- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher {
    if ((self = [super init])) {
        _eventDispatcher = eventDispatcher;
    }

    return self;
}

@end;
