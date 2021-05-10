#import <Foundation/Foundation.h>
#import "RCTZVideoViewModule.h"
#import "RCTZiggeoVideoView.h"
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>
#import "RCTVideos.h"
@import AVKit;

@implementation RCTZiggeoVideoView {
    RCTEventDispatcher *_eventDispatcher;
    ZiggeoPlayerReferenceBlock _ref;
    NSArray *_tokens;
}

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
    
    [RCTZVideoViewModule setLastZiggeoPlayer:player];

    if (_playerController != nil) {
        _playerController.player = player;
    }
}

@end
