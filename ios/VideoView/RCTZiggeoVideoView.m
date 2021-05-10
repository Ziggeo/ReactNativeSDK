#import <Foundation/Foundation.h>

#import "RCTZiggeoVideoView.h"
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>
#import "RCTVideos.h"
@import AVKit;

@implementation RCTZiggeoVideoView {
    RCTEventDispatcher *_eventDispatcher;
    ZiggeoPlayer *_player;
    ZiggeoPlayerReferenceBlock _ref;
    NSArray *_tokens;
    AVPlayerViewController* playerController;
}

- (UIView *)view
{
    return playerController.view;
}

RCT_EXPORT_MODULE();


- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher tokens:(NSArray *)tokens {
    if ((self = [super init])) {
        _eventDispatcher = eventDispatcher;
        _tokens = tokens;
        
        [self initPlayer];
    }

    return self;
}


- (void)initPlayer {
    dispatch_async(dispatch_get_main_queue(), ^{
        Ziggeo* ziggeo = [[Ziggeo alloc] initWithToken:__appToken];
        [ziggeo connect].serverAuthToken = __serverAuthToken;
        [ziggeo connect].clientAuthToken = __clientAuthToken;
        // todo [ziggeo.config setPlayerCacheConfig:self.cacheConfig];
        ZiggeoPlayer* player = nil;

        NSMutableDictionary* mergedParams = nil;
        
        /*
        if(self->_additionalParams != nil)
        {
            mergedParams = [[NSMutableDictionary alloc] initWithDictionary:self->_additionalParams];
            if(self->_themeParams) [mergedParams addEntriesFromDictionary:self->_themeParams];
        }
        else if(self->_themeParams != nil)
        {
            mergedParams = [[NSMutableDictionary alloc] initWithDictionary:self->_themeParams];
        }
        */
         
        bool hideControls = true;

        player = [[ZiggeoPlayer alloc] initWithZiggeoApplication:ziggeo videoToken:[_tokens firstObject] videoUrl:nil];
        playerController = [[AVPlayerViewController alloc] init];
        playerController.player = player;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:playerController animated:true completion:nil];
        [playerController.player play];
        playerController.showsPlaybackControls = false;
        
        /*
         Alternative method:
            
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
        */
    });
}


@end
