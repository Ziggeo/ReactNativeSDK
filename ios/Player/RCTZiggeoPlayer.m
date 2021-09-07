//
//  RCTZiggeoPlayer.m
//  ReactIntegrationDemo
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RCTZiggeoPlayer.h"
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>
@import AVKit;
#import <GoogleInteractiveMediaAds/GoogleInteractiveMediaAds.h>

@implementation RCTZiggeoPlayer {
    UIViewController *_adController;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(setAppToken:(NSString *)token)
{
  RCTLogInfo(@"application token set: %@", token);
  _appToken = token;
}

RCT_EXPORT_METHOD(setServerAuthToken:(NSString *)token)
{
  RCTLogInfo(@"server auth token set: %@", token);
  _serverAuthToken = token;
}

RCT_EXPORT_METHOD(setClientAuthToken:(NSString *)token)
{
  RCTLogInfo(@"client auth token set: %@", token);
  _clientAuthToken = token;
}

RCT_EXPORT_METHOD(setPlayerCacheConfig:(NSDictionary *)config)
{
    RCTLogInfo(@"player cache config set: %@", config);
    self.cacheConfig = config;
}

RCT_EXPORT_METHOD(playVideo:(NSString*)videoToken)
{
    // NSMutableDictionary *themeArgsForPlayer = [NSMutableDictionary dictionary];
    // themeArgsForPlayer[@"hidePlayerControls"] = false;
    // [self setThemeArgsForPlayer:themeArgsForPlayer];
    [self playTokenOrUrl:videoToken URL:nil];
}

RCT_EXPORT_METHOD(playFromUri:(NSString*)url)
{
    [self playTokenOrUrl:nil URL:url];
}

RCT_EXPORT_METHOD(downloadVideo:(NSString *)videoToken
                downloadVideoWithResolver:(RCTPromiseResolveBlock)resolve
                rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        Ziggeo *m_ziggeo = [[Ziggeo alloc] initWithToken:self->_appToken];
        m_ziggeo.connect.serverAuthToken = self.serverAuthToken;
        m_ziggeo.connect.clientAuthToken = self.clientAuthToken;

        [m_ziggeo.videos downloadVideoWithToken:videoToken Callback:^(NSString *filePath) {
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                RCTLogInfo(@"video downloaded: %@", filePath);
            });
        }];
    });
}

- (void)playTokenOrUrl:(NSString *)videoToken URL:(NSString*)url {
    dispatch_async(dispatch_get_main_queue(), ^{
        Ziggeo* ziggeo = [[Ziggeo alloc] initWithToken:self.appToken];
        [ziggeo connect].serverAuthToken = self.serverAuthToken;
        [ziggeo connect].clientAuthToken = self.clientAuthToken;
        [ziggeo.config setPlayerCacheConfig:self.cacheConfig];
        

        NSMutableDictionary* mergedParams = nil;
        if (self->_additionalParams != nil) {
            mergedParams = [[NSMutableDictionary alloc] initWithDictionary:self->_additionalParams];
            if(self->_themeParams) [mergedParams addEntriesFromDictionary:self->_themeParams];
        } else if(self->_themeParams != nil) {
            mergedParams = [[NSMutableDictionary alloc] initWithDictionary:self->_themeParams];
        }

        bool hideControls = mergedParams && ([@"true" isEqualToString:mergedParams[@"hidePlayerControls"]] || [[mergedParams valueForKey:@"hidePlayerControls"] boolValue] );
        if (mergedParams == nil) {
            ZiggeoPlayer* player = [[ZiggeoPlayer alloc] initWithZiggeoApplication:ziggeo videoToken:videoToken videoUrl:url];
            AVPlayerViewController* playerController = [[AVPlayerViewController alloc] init];
            playerController.player = player;

            [self startPlaybackWithPlayer:player playerController: playerController];

        } else {
            [ZiggeoPlayer createPlayerWithAdditionalParams:ziggeo videoToken:videoToken videoUrl:url params:mergedParams callback:^(ZiggeoPlayer *player) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    AVPlayerViewController* playerController = [[AVPlayerViewController alloc] init];
                    playerController.player = player;
                    if (hideControls) {
                        player.didFinishPlaying = ^(NSString *videoToken, NSError *error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [playerController dismissViewControllerAnimated:true completion:nil];
                            });
                        };
                        playerController.showsPlaybackControls = false;
                    }
                    
                    [self startPlaybackWithPlayer:player playerController:playerController];
                });
            }];
        }
    });
}

- (void)startPlaybackWithPlayer:(AVPlayer *)player playerController:(AVPlayerViewController *)playerController {
    dispatch_async(dispatch_get_main_queue(), ^{

        playerController.player = player;

        if (!_adController) {
            _adController = [[UIViewController alloc] init];
        }

        UIViewController *parentController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while(parentController.presentedViewController && parentController != parentController.presentedViewController) {
            parentController = parentController.presentedViewController;
        }

        if (_adsUrl && [player isKindOfClass:[ZiggeoPlayer class]]) {
            [parentController presentViewController:_adController animated:YES completion:nil];
            [(ZiggeoPlayer *) player playWithAdsWithAdTagURL:_adsUrl playerContainer:_adController.view playerViewController:playerController];
        } else {
            [parentController presentViewController:playerController animated:YES completion:nil];
            [player play];
        }

    });
}

RCT_EXPORT_METHOD(setExtraArgsForPlayer:(NSDictionary*)map)
{
    _additionalParams = map;
}

RCT_EXPORT_METHOD(setThemeArgsForPlayer:(NSDictionary*)map)
{
    _themeParams = map;
}

RCT_EXPORT_METHOD(setAdsURL:(NSString*)url)
{
    _adsUrl = url;
}

@end
