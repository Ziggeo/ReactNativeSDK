#import <Foundation/Foundation.h>
#import "RCTZVideoViewModule.h"
#import "RCTZiggeoVideoView.h"
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTComponent.h>

#import "RCTZVideoViewModule.h"
#import "RCTVideos.h"
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
    NSLog(@"__appToken: %@", [RCTVideos _appToken]);

    _m_ziggeo = [[Ziggeo alloc] initWithToken: [RCTVideos _appToken]];
    _m_ziggeo.connect.serverAuthToken = [RCTVideos _serverAuthToken];
    _m_ziggeo.connect.clientAuthToken = [RCTVideos _clientAuthToken];

    _m_ziggeo.token = [RCTVideos _appToken];
    _m_ziggeo.connect.serverAuthToken = [RCTVideos _serverAuthToken];
    _m_ziggeo.connect.clientAuthToken = [RCTVideos _clientAuthToken];

    ZiggeoPlayer* player = [[ZiggeoPlayer alloc] initWithZiggeoApplication:_m_ziggeo videoToken:token];

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

-(void)dealloc {
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


    if (context == @"AVPlayerStatus") {
        AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];

        switch (status) {
            case AVPlayerStatusUnknown:
                break;

            case AVPlayerStatusReadyToPlay:
                if (self.onReadyToPlay) {
                    self.onReadyToPlay([NSDictionary new]);
                }
                break;

            case AVPlayerStatusFailed:
                if (self.onError) {
                    self.onError([NSDictionary new]);
                }
                break;
        }
    }
}

@end
