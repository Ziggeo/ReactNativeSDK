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
@implementation RCTZiggeoPlayer

RCT_EXPORT_MODULE();


RCT_EXPORT_METHOD(setAppToken:(NSString *)token)
{
  RCTLogInfo(@"application token set: %@", token);
  _appToken = token;
}

RCT_EXPORT_METHOD(play:(NSString*)videoToken)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    Ziggeo* ziggeo = [[Ziggeo alloc] initWithToken:_appToken];
    ZiggeoPlayer* player = [[ZiggeoPlayer alloc] initWithZiggeoApplication:ziggeo videoToken:videoToken];
    AVPlayerViewController* playerController = [[AVPlayerViewController alloc] init];
    playerController.player = player;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:playerController animated:true completion:nil];
    [playerController.player play];
  });
}

@end
