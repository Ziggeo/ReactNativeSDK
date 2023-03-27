//
//  RCTZiggeoPlayer.m
//  ReactIntegrationDemo
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RCTZiggeoPlayer.h"
#import <ZiggeoMediaSDK/ZiggeoMediaSDK.h>
#import <React/RCTLog.h>
@import AVKit;
#import "ZiggeoRecorderContext.h"
#import "ZiggeoConstants.h"

@implementation RCTZiggeoPlayer {
    UIViewController *_adController;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(setAppToken:(NSString *)token)
{
    RCTLogInfo(@"application token set: %@", token);
    _appToken = token;
    [ZiggeoConstants setAppToken:_appToken];
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


RCT_EXPORT_METHOD(playVideo:(NSArray *)videoTokens)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] playVideo:videoTokens];
}

RCT_EXPORT_METHOD(playFromUri:(NSArray *)urls)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] playFromUri:urls];
}

RCT_EXPORT_METHOD(setExtraArgsForPlayer:(NSDictionary *)map)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setExtraArgsForPlayer:map];
}

RCT_EXPORT_METHOD(setThemeArgsForPlayer:(NSDictionary *)map)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setThemeArgsForPlayer:map];
}

RCT_EXPORT_METHOD(setPlayerCacheConfig:(NSDictionary *)config)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setPlayerCacheConfig:config];
}

RCT_EXPORT_METHOD(setAdsURL:(NSString *)url)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setAdsURL:url];
}

@end
