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

@implementation RCTZiggeoPlayer {
    UIViewController *_adController;
    Ziggeo *m_ziggeo;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(setAppToken:(NSString *)token)
{
  RCTLogInfo(@"application token set: %@", token);
  _appToken = token;
  ZiggeoRecorderContext *m_context = [[ZiggeoRecorderContext alloc] init];
  m_ziggeo = [[Ziggeo alloc] initWithToken:_appToken Delegate:m_context];
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
    if (m_ziggeo == nil) return;
    [m_ziggeo playVideo:videoTokens];
}

RCT_EXPORT_METHOD(playFromUri:(NSArray *)urls)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo playFromUri:urls];
}

RCT_EXPORT_METHOD(setExtraArgsForPlayer:(NSDictionary *)map)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setExtraArgsForPlayer:map];
}

RCT_EXPORT_METHOD(setThemeArgsForPlayer:(NSDictionary *)map)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setThemeArgsForPlayer:map];
}

RCT_EXPORT_METHOD(setPlayerCacheConfig:(NSDictionary *)config)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setPlayerCacheConfig:config];
}

RCT_EXPORT_METHOD(setAdsURL:(NSString *)url)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setAdsURL:url];
}

@end
