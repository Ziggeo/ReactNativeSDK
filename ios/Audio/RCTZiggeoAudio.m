//
//  RCTZiggeoAudio.m
//  ReactIntegrationDemo
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

@import AVKit;
#import <Foundation/Foundation.h>
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>
#import "RCTZiggeoAudio.h"
#import "ZiggeoAudioContext.h"

@implementation RCTZiggeoAudio {
}

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents
{
    return @[
    ];
}

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

RCT_EXPORT_METHOD(playAudio:(NSString *)audioToken
                  playAudioWithResolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        Ziggeo *m_ziggeo = [[Ziggeo alloc] initWithToken:self->_appToken];
        m_ziggeo.connect.serverAuthToken = self.serverAuthToken;
        m_ziggeo.connect.clientAuthToken = self.clientAuthToken;

        [m_ziggeo.audios downloadAudioWithToken:audioToken Callback:^(NSString *filePath) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self playAudioFromUri:filePath playAudioWithResolver:resolve rejecter:reject];
            });
        }];
    });
}

RCT_EXPORT_METHOD(playAudioFromUri:(NSString*)path
                  playAudioWithResolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    // RCTZiggeoAudioContext *context = [[RCTZiggeoAudioContext alloc] init];
    // context.resolveBlock = resolve;
    // context.rejectBlock = reject;
    // context.ziggeoAudio = self;

    // dispatch_async(dispatch_get_main_queue(), ^{
    //     Ziggeo *m_ziggeo = [[Ziggeo alloc] initWithToken:self->_appToken];
    //     m_ziggeo.connect.serverAuthToken = self.serverAuthToken;
    //     m_ziggeo.connect.clientAuthToken = self.clientAuthToken;

    //     ZiggeoAudioPlayer *audioPlayer;
    //     if (URL != nil) {
    //         audioPlayer = [[ZiggeoAudioPlayer alloc] initWithZiggeoApplication:m_ziggeo audioToken:audioToken];
    //     } else {
    //         audioPlayer = [[ZiggeoAudioPlayer alloc] initWithZiggeoApplication:m_ziggeo audioToken:audioToken audioUrl:URL];
    //     }

    //     UIViewController *parentController = [UIApplication sharedApplication].keyWindow.rootViewController;
    //     while(parentController.presentedViewController && parentController != parentController.presentedViewController) {
    //         parentController = parentController.presentedViewController;
    //     }
    //     [parentController presentViewController:audioPlayer animated:true completion:nil];
    // });
}

RCT_REMAP_METHOD(recordAudio,
                 recorderAudioWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    // RCTZiggeoAudioContext* context = [[RCTZiggeoAudioContext alloc] init];
    // context.resolveBlock = resolve;
    // context.rejectBlock = reject;
    // context.ziggeoAudio = self;

    // dispatch_async(dispatch_get_main_queue(), ^{
    //     Ziggeo* m_ziggeo = [[Ziggeo alloc] initWithToken:self->_appToken];
    //     m_ziggeo.connect.serverAuthToken = self.serverAuthToken;
    //     m_ziggeo.connect.clientAuthToken = self.clientAuthToken;

    //     ZiggeoAudioRecorder *audioRecorder = [[ZiggeoAudioRecorder alloc] initWithZiggeoApplication:m_ziggeo];
    //     audioRecorder.recorderDelegate = context;
    //     audioRecorder.uploadDelegate = context;

    //     UIViewController* parentController = [UIApplication sharedApplication].keyWindow.rootViewController;
    //     while(parentController.presentedViewController && parentController != parentController.presentedViewController) {
    //         parentController = parentController.presentedViewController;
    //     }
    //     [parentController presentViewController:audioRecorder animated:true completion:nil];
    // });
}

@end
