//
//  ZiggeoRecorderRCT.m
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTZiggeoRecorder.h"
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>
#import "RotatingImagePickerController.h"
#import "ButtonConfig+parse.h"
#import "ZiggeoRecorderContext.h"
#import "ZiggeoConstants.h"


ButtonConfig *parseButtonConfig(NSDictionary *dictionary) {
    ButtonConfig *config = [ButtonConfig new];
    id value;

    value = dictionary[@"imagePath"];
    if (value && [value isKindOfClass:[NSString class]]) {
        config.imagePath = (NSString *)value;
    }

    value = dictionary[@"selectedImagePath"];
    if (value && [value isKindOfClass:[NSString class]]) {
        config.selectedImagePath = (NSString *)value;
    }

    value = dictionary[@"scale"];
    if (value && [value isKindOfClass:[NSNumber class]]) {
        config.scale = [((NSNumber *)value) doubleValue];
    }

    value = dictionary[@"width"];
    if (value && [value isKindOfClass:[NSNumber class]]) {
        CGFloat *val = calloc(1, sizeof(CGFloat));
        *val = [((NSNumber *)value) doubleValue];
        config.width = val;
    }

    value = dictionary[@"height"];
    if (value && [value isKindOfClass:[NSNumber class]]) {
        CGFloat *val = calloc(1, sizeof(CGFloat));
        *val = [((NSNumber *)value) doubleValue];
        config.height = val;
    }

    return config;
}

ZiggeoRecorderInterfaceConfig *parseRecorderInterfaceConfig(NSDictionary *config) {
    ZiggeoRecorderInterfaceConfig *conf = [ZiggeoRecorderInterfaceConfig new];

    id recordButtonConfig = config[@"recordButton"];
    if (recordButtonConfig && [recordButtonConfig isKindOfClass:[NSDictionary class]]) {
        conf.recordButton = parseButtonConfig(recordButtonConfig);
    }
    
    id closeButtonConfig = config[@"closeButton"];
    if (closeButtonConfig && [closeButtonConfig isKindOfClass:[NSDictionary class]]) {
        conf.closeButton = parseButtonConfig(closeButtonConfig);
    }
    
    id cameraFlipButtonConfig = config[@"cameraFlipButton"];
    if (cameraFlipButtonConfig && [cameraFlipButtonConfig isKindOfClass:[NSDictionary class]]) {
        conf.cameraFlipButton = parseButtonConfig(cameraFlipButtonConfig);
    }
    
    return conf;
}


@implementation RCTZiggeoRecorder {
    ZiggeoRecorderContext *m_context;
    Ziggeo *m_ziggeo;
}

RCT_EXPORT_MODULE();


- (NSDictionary *)constantsToExport
{
 return kZiggeoConstants;
}

- (NSArray<NSString *> *)supportedEvents
{
    return [[NSArray alloc] initWithObjects:kZiggeoEventsArray];
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (void)showPresentViewController:(UIViewController *)viewController {
    UIViewController *parentController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while(parentController.presentedViewController && parentController != parentController.presentedViewController) {
        parentController = parentController.presentedViewController;
    }
    [parentController presentViewController:viewController animated:true completion:nil];
}

- (void)applyAdditionalParams:(NSDictionary*)map context:(ZiggeoRecorderContext*)context {
    context.extraArgs = map;
    
    if (map != nil) {
        if ([map objectForKey:@"max_duration"] != nil) {
            context.maxAllowedDurationInSeconds = [[map objectForKey:@"max_duration"] intValue];
        }
        if ([map objectForKey:@"enforce_duration"] != nil) {
            context.enforceDuration = [[map objectForKey:@"enforce_duration"] boolValue];
        }
    }
}


RCT_EXPORT_METHOD(setAppToken:(NSString *)token)
{
    RCTLogInfo(@"application token set: %@", token);
    _appToken = token;

    m_context = [[ZiggeoRecorderContext alloc] init];
    m_context.recorder = self;
    m_ziggeo = [[Ziggeo alloc] initWithToken:_appToken Delegate:m_context];
}

RCT_EXPORT_METHOD(setServerAuthToken:(NSString *)token)
{
  RCTLogInfo(@"server auth token set: %@", token);
  _serverAuthToken = token;
}

RCT_EXPORT_METHOD(setClientAuthToken:(NSString *)token)
{
    RCTLogInfo(@"server auth token set: %@", token);
    _clientAuthToken = token;
}


RCT_EXPORT_METHOD(setRecorderCacheConfig:(NSDictionary *)config)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setRecorderCacheConfig:config];
}

RCT_EXPORT_METHOD(setRecorderInterfaceConfig:(NSDictionary *)config)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setRecorderInterfaceConfig:config];
}

RCT_EXPORT_METHOD(setUploadingConfig:(NSDictionary *)config)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setUploadingConfig:config];
}

RCT_EXPORT_METHOD(setLiveStreamingEnabled:(BOOL)enabled)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setLiveStreamingEnabled:enabled];
}

RCT_EXPORT_METHOD(setAutostartRecordingAfter:(NSInteger)seconds)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setAutostartRecordingAfter:(int)seconds];
}

RCT_EXPORT_METHOD(setStartDelay:(NSInteger)delay)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setStartDelay:(int)delay];
}

RCT_EXPORT_METHOD(setExtraArgsForRecorder:(NSDictionary*)map)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setExtraArgsForRecorder:map];
}

RCT_EXPORT_METHOD(setThemeArgsForRecorder:(NSDictionary*)map)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setThemeArgsForRecorder:map];
}

RCT_EXPORT_METHOD(setCoverSelectorEnabled:(BOOL)enabled)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setCoverSelectorEnabled:enabled];
}

RCT_EXPORT_METHOD(setMaxRecordingDuration:(NSInteger)seconds)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setMaxRecordingDuration:(int)seconds];
}

RCT_EXPORT_METHOD(setVideoWidth:(NSInteger)videoWidth)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setVideoWidth:(int)videoWidth];
}

RCT_EXPORT_METHOD(setVideoHeight:(NSInteger)videoHeight)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setVideoHeight:(int)videoHeight];
}

RCT_EXPORT_METHOD(setVideoBitrate:(NSInteger)videoBitrate)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setVideoBitrate:(int)videoBitrate];
}

RCT_EXPORT_METHOD(setAudioSampleRate:(NSInteger)audioSampleRate)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setAudioSampleRate:(int)audioSampleRate];
}

RCT_EXPORT_METHOD(setAudioBitrate:(NSInteger)audioBitrate)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setAudioBitrate:(int)audioBitrate];
}

RCT_EXPORT_METHOD(setCameraSwitchEnabled:(BOOL)visible)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setCameraSwitchEnabled:visible];
}

RCT_EXPORT_METHOD(setSendImmediately:(BOOL)sendImmediately)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setSendImmediately:sendImmediately];
}

RCT_EXPORT_METHOD(setQuality:(id)quality)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setQuality:(int)quality];
}

RCT_EXPORT_METHOD(setCamera:(id)cameraDevice)
{
    if (m_ziggeo == nil) return;
    [m_ziggeo setCamera:(int)cameraDevice];
}

// MARK: - Videos
RCT_REMAP_METHOD(record,
                 recordWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    if (m_ziggeo == nil) return;
    m_context.resolveBlock = resolve;
    m_context.rejectBlock = reject;

    dispatch_async(dispatch_get_main_queue(), ^{
        // [self->m_ziggeo setBlurringEffect:true];
        // [self->m_ziggeo setBlurringMaskColor:UIColor.redColor];
        // [self->m_ziggeo setBlurringMaskAlpha:0.6];
        // [self->m_ziggeo setMaxRecordingDuration:30];
        [self->m_ziggeo record];
    });
}

RCT_REMAP_METHOD(startImageRecorder,
                 startImageRecorderResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    if (m_ziggeo == nil) return;
    m_context.resolveBlock = resolve;
    m_context.rejectBlock = reject;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->m_ziggeo startImageRecorder];
    });
}

RCT_EXPORT_METHOD(showImage:(NSString *)imageToken
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    if (m_ziggeo == nil) return;
    m_context.resolveBlock = resolve;
    m_context.rejectBlock = reject;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self->m_ziggeo showImage:imageToken];
    });
}

RCT_REMAP_METHOD(startAudioRecorder,
                 startAudioRecorderResolver:(RCTPromiseResolveBlock)resolve
                 startAudioRecorderRejecter:(RCTPromiseRejectBlock)reject)
{
    if (m_ziggeo == nil) return;
    m_context.resolveBlock = resolve;
    m_context.rejectBlock = reject;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self->m_ziggeo startAudioRecorder];
    });
}

RCT_EXPORT_METHOD(startAudioPlayer:(NSString *)audioToken
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    if (m_ziggeo == nil) return;
    m_context.resolveBlock = resolve;
    m_context.rejectBlock = reject;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->m_ziggeo startAudioPlayer:audioToken];
    });
}

RCT_REMAP_METHOD(startScreenRecorder,
                 startScreenRecorderResolver:(RCTPromiseResolveBlock)resolve
                 startScreenRecorderRejecter:(RCTPromiseRejectBlock)reject)
{
    if (m_ziggeo == nil) return;
    m_context.resolveBlock = resolve;
    m_context.rejectBlock = reject;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self->m_ziggeo startScreenRecorder];
    });
}

RCT_EXPORT_METHOD(uploadFromPath:(NSString*)fileName
                  argsMap:(NSDictionary*)map
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    if (m_ziggeo == nil) return;
    m_context.resolveBlock = resolve;
    m_context.rejectBlock = reject;
    
    if (fileName != nil) {
        [m_ziggeo uploadFromPath:fileName :map];
    } else {
        reject(@"ERR_NOFILE", @"empty filename", [NSError errorWithDomain:@"recorder" code:0 userInfo:@{@"ERR_NOFILE": @"empty filename"}]);
    }
}

RCT_EXPORT_METHOD(uploadFromFileSelector:(NSDictionary*)map
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    if (m_ziggeo == nil) return;
    m_context.resolveBlock = resolve;
    m_context.rejectBlock = reject;

    [self applyAdditionalParams:map context:m_context];

    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        data[@"media_types"] = @[@"video", @"audio", @"image"];
        [self->m_ziggeo uploadFromFileSelector:data];
    });
}

RCT_EXPORT_METHOD(cancelCurrentUpload:(BOOL)delete_file
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    if (m_ziggeo == nil) return;
    m_context.resolveBlock = resolve;
    m_context.rejectBlock = reject;
    
    [m_ziggeo cancelUpload:@"" :delete_file];
}

RCT_EXPORT_METHOD(cancelUploadByPath:(NSString *)path
                  delete_file:(BOOL)delete_file
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    if (m_ziggeo == nil) return;
    m_context.resolveBlock = resolve;
    m_context.rejectBlock = reject;
    
    [m_ziggeo cancelUpload:path :delete_file];
}

RCT_EXPORT_METHOD(startQrScanner:(NSDictionary*)map
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    if (m_ziggeo == nil) return;
    m_context.resolveBlock = resolve;
    m_context.rejectBlock = reject;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self->m_ziggeo startQrScanner:map];
    });
}

@end
