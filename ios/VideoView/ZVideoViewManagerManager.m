#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>

#import "RCTBridge.h"
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>
#import <UIKit/UIKit.h>
#import "ZCameraView.h"
#import "RCTZiggeo.h"
#import "ZVideoViewManagerManager.h"
#import "RCTZCameraModule.h"
#import "ZVideoView.h"

@implementation ZVideoViewManagerManager {
    AVPlayerViewController *playerController;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_VIEW_PROPERTY(style, NSString);

RCT_EXPORT_VIEW_PROPERTY(ref, NSString);

RCT_EXPORT_VIEW_PROPERTY(tokens, NSArray);

@synthesize bridge = _bridge;

- (UIView *)view {
    Ziggeo* m_ziggeo = [[Ziggeo alloc] initWithToken:[RCTZiggeo appToken]];
    m_ziggeo.connect.serverAuthToken = [RCTZiggeo serverAuthToken];
    m_ziggeo.connect.clientAuthToken = [RCTZiggeo clientAuthToken];
    // todo? [m_ziggeo.config setRecorderCacheConfig:self.cacheConfig];

    ZiggeoPlayer* player = [[ZiggeoPlayer alloc] initWithZiggeoApplication:m_ziggeo videoToken:[tokens firstObject]];

    playerController = [[AVPlayerViewController alloc] init];
    playerController.player = player;
    playerController.showsPlaybackControls = false;

    [RCTZCameraModule setLastZiggeoRecorder:player];

    // todo? m_ziggeo.videos.delegate = context;

    ZVideoView *view = [[ZVideoView alloc] initWithEventDispatcher:self.bridge.eventDispatcher];

    UIView *playerView = playerController.view;
    // todo? view.player = player;

    [view addSubview:playerView];

    playerView.translatesAutoresizingMaskIntoConstraints = false;
    
    [view.leadingAnchor constraintEqualToAnchor:playerView.leadingAnchor].active = true;
    [view.trailingAnchor constraintEqualToAnchor:playerView.trailingAnchor].active = true;
    [view.topAnchor constraintEqualToAnchor:playerView.topAnchor].active = true;
    [view.bottomAnchor constraintEqualToAnchor:playerView.bottomAnchor].active = true;

    return view;
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[
        @"Error"
        @"Playing"
        @"Paused"
        @"Ended"
        @"Seek"
        @"ReadyToPlay"
    ];
}

- (NSArray *) customDirectEventTypes {
    return @[
        @"onFrameChange"
    ];
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

@end;
