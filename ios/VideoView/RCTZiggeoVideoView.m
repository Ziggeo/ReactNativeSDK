#import <Foundation/Foundation.h>
#import "RCTZVideoViewModule.h"
#import "RCTZiggeoVideoView.h"
#import <ZiggeoMediaSDK/ZiggeoMediaSDK.h>
#import <React/RCTLog.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTComponent.h>
#import <React/RCTEventDispatcher.h>
#import "RCTZVideoViewModule.h"
#import "RCTVideos.h"
#import "ZiggeoConstants.h"
@import AVKit;

@implementation RCTZiggeoVideoView {
    RCTEventDispatcher *_eventDispatcher;
    ZiggeoPlayerReferenceBlock _ref;
    NSArray *_tokens;
    AVPlayerItem *lastPlayerItem;
}

static void * const RCTZiggeoVideoViewKVOContext = (void*)&RCTZiggeoVideoViewKVOContext;

- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher {
    if ((self = [super init])) {
        _eventDispatcher = eventDispatcher;
    }

    return self;
}

- (void)setVideoToken:(NSString *)token {
    NSLog(@"__appToken: %@", [RCTVideos appToken]);

    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [ZiggeoConstants sharedZiggeoInstance].connect.serverAuthToken = [RCTVideos serverAuthToken];
    [ZiggeoConstants sharedZiggeoInstance].connect.clientAuthToken = [RCTVideos clientAuthToken];

    [ZiggeoConstants sharedZiggeoInstance].token = [RCTVideos appToken];
    [ZiggeoConstants sharedZiggeoInstance].connect.serverAuthToken = [RCTVideos serverAuthToken];
    [ZiggeoConstants sharedZiggeoInstance].connect.clientAuthToken = [RCTVideos clientAuthToken];

    ZiggeoPlayer* player = [[ZiggeoPlayer alloc] initWithZiggeoApplication:[ZiggeoConstants sharedZiggeoInstance] videoToken:token];

    if (lastPlayerItem != nil) {
        [lastPlayerItem removeObserver:self forKeyPath:@"status" context:RCTZiggeoVideoViewKVOContext];
    }

    lastPlayerItem = player.currentItem;

    [lastPlayerItem addObserver:self
                     forKeyPath:@"status"
                        options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                        context:RCTZiggeoVideoViewKVOContext
    ];

    [RCTZVideoViewModule setLastZiggeoPlayer:player];

    if (_playerController != nil) {
        _playerController.player = player;
    }
}

- (void)dealloc {
    if (lastPlayerItem != nil) {
        [lastPlayerItem removeObserver:self forKeyPath:@"status" context:RCTZiggeoVideoViewKVOContext];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    // Only handle observations for the playerItemContext
    if (context != RCTZiggeoVideoViewKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    if (keyPath == @"rate") {
        float rate = [change[NSKeyValueChangeNewKey] floatValue];
        if (rate == 0) {
            [[RCTZVideoViewModule instance] sendEventWithName:@"Ended" body:@{}];
        } else {
            [[RCTZVideoViewModule instance] sendEventWithName:@"Playing" body:@{}];
        }
    }

    if (keyPath == @"status") {
        AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerStatusUnknown:
                break;

            case AVPlayerStatusReadyToPlay: {
                [[RCTZVideoViewModule instance] sendEventWithName:@"ReadyToPlay" body:@{}];
                break;
            }

            case AVPlayerStatusFailed: {
                [[RCTZVideoViewModule instance] sendEventWithName:@"Error" body:@{}];
                break;
            }
        }
    }
}

@end
