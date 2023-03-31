#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>
#import "RCTBridge.h"
#import <ZiggeoMediaSDK/ZiggeoMediaSDK.h>
#import <React/RCTLog.h>
#import <UIKit/UIKit.h>
#import "ZVideoViewManagerManager.h"
#import "RCTZCameraModule.h"
#import "RCTZiggeoVideoView.h"
#import "RCTZVideoViewModule.h"

@implementation ZVideoViewManagerManager {
    AVPlayerViewController *playerController;
    RCTZiggeoVideoView *_view;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_VIEW_PROPERTY(style, NSString *);

RCT_EXPORT_VIEW_PROPERTY(ref, NSString *);

RCT_CUSTOM_VIEW_PROPERTY(tokens, NSArray *, NSString *)
{
    _tokens = json;
    
    if (_view != nil) {
        [_view setVideoToken:[_tokens firstObject]];
    }
}

@synthesize bridge = _bridge;

- (UIView *)view {
    NSLog(@"Video tokens to play: %@", _tokens);

    // todo implement playback of playlist consisting of video tokens
    
    playerController = [[AVPlayerViewController alloc] init];
    playerController.showsPlaybackControls = false;

    RCTZiggeoVideoView *view = [[RCTZiggeoVideoView alloc] initWithEventDispatcher:self.bridge.eventDispatcher];


    UIView *playerView = playerController.view;
    // todo? view.player = player;

    [view addSubview:playerView];

    playerView.translatesAutoresizingMaskIntoConstraints = false;
    
    [view.leadingAnchor constraintEqualToAnchor:playerView.leadingAnchor].active = true;
    [view.trailingAnchor constraintEqualToAnchor:playerView.trailingAnchor].active = true;
    [view.topAnchor constraintEqualToAnchor:playerView.topAnchor].active = true;
    [view.bottomAnchor constraintEqualToAnchor:playerView.bottomAnchor].active = true;
    
    view.playerController = playerController;

    [view setVideoToken:[_tokens firstObject]];
    
    _view = view;
    
    return view;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

@end;
