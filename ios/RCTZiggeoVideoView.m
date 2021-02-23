#import <Foundation/Foundation.h>

#import "RCTZiggeoVideoView.h"
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>
@import AVKit;
@implementation RCTZiggeoVideoView {
    ZiggeoPlayer *_player;
    ZiggeoPlayerReferenceBlock _ref;
    AVPlayerViewController* playerController;
}

- (UIView *)view
{
    return playerController.view;
}

RCT_EXPORT_MODULE();


- (instancetype)init {
    self = [super init];
    if (self) {
        _player = [[ZiggeoPlayer alloc] init];
    }

    [self initPlayer];

    return self;
}

- (id)initPlayer {
    dispatch_async(dispatch_get_main_queue(), ^{
        Ziggeo* ziggeo = [[Ziggeo alloc] initWithToken:self.appToken];
        [ziggeo connect].serverAuthToken = self.serverAuthToken;
        [ziggeo connect].clientAuthToken = self.clientAuthToken;
        [ziggeo.config setPlayerCacheConfig:self.cacheConfig];
        ZiggeoPlayer* player = nil;

        NSMutableDictionary* mergedParams = nil;
        if(self->_additionalParams != nil)
        {
            mergedParams = [[NSMutableDictionary alloc] initWithDictionary:self->_additionalParams];
            if(self->_themeParams) [mergedParams addEntriesFromDictionary:self->_themeParams];
        }
        else if(self->_themeParams != nil)
        {
            mergedParams = [[NSMutableDictionary alloc] initWithDictionary:self->_themeParams];
        }
        bool hideControls = mergedParams && ([@"true" isEqualToString:mergedParams[@"hidePlayerControls"]] || [[mergedParams valueForKey:@"hidePlayerControls"] boolValue] );

        if(mergedParams == nil)
        {
            player = [[ZiggeoPlayer alloc] initWithZiggeoApplication:ziggeo videoToken:videoToken videoUrl:URL];
            playerController = [[AVPlayerViewController alloc] init];
            playerController.player = player;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:playerController animated:true completion:nil];
            [playerController.player play];
        }
        else {
            [ZiggeoPlayer createPlayerWithAdditionalParams:ziggeo videoToken:videoToken videoUrl:URL params:mergedParams callback:^(ZiggeoPlayer *player) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    playerController = [[AVPlayerViewController alloc] init];
                    playerController.player = player;

                    if(hideControls)
                    {
                        player.didFinishPlaying = ^(NSString *videoToken, NSError *error) {
                            dispatch_async(dispatch_get_main_queue(), ^
                            {
                                [playerController dismissViewControllerAnimated:true completion:nil];
                            });
                        };
                        playerController.showsPlaybackControls = false;
                    }

                    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:playerController animated:true completion:nil];
                    [playerController.player play];
                });
            }];
        }
}

- (void)setRef:(ZiggeoPlayerReferenceBlock) ref {
    _ref = ref;
    if (ref != nil) {
        ref(_player);
    }
}


@end
