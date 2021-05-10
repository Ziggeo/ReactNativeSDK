#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>

#import "RCTBridge.h"
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>
#import <UIKit/UIKit.h>
#import "ZVideoViewManagerManager.h"
#import "RCTZCameraModule.h"
#import "RCTVideos.h"
#import "RCTZiggeoVideoView.h"
#import "RCTZVideoViewModule.h"

@implementation ZVideoViewManagerManager {
    AVPlayerViewController *playerController;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_VIEW_PROPERTY(style, NSString);

RCT_EXPORT_VIEW_PROPERTY(ref, NSString);

RCT_EXPORT_VIEW_PROPERTY(tokens, NSArray);

@synthesize bridge = _bridge;

- (UIView *)view {
    Ziggeo* m_ziggeo = [[Ziggeo alloc] initWithToken:__appToken];
    m_ziggeo.connect.serverAuthToken = __serverAuthToken;
    m_ziggeo.connect.clientAuthToken = __clientAuthToken;
    // todo? [m_ziggeo.config setRecorderCacheConfig:self.cacheConfig];

    // todo implement playback of playlist consisting of video tokens
    ZiggeoPlayer* player = [[ZiggeoPlayer alloc] initWithZiggeoApplication:m_ziggeo videoToken:[_tokens firstObject]];

    playerController = [[AVPlayerViewController alloc] init];
    playerController.player = player;
    playerController.showsPlaybackControls = false;

    [RCTZVideoViewModule setLastZiggeoPlayer:player];

    // todo? m_ziggeo.videos.delegate = context;

    RCTZiggeoVideoView *view = [[RCTZiggeoVideoView alloc] initWithEventDispatcher:self.bridge.eventDispatcher tokens:_tokens];

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
