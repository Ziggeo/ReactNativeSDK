//
//  RCTZiggeoRecorder.m
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTZiggeoRecorder.h"
#import <ZiggeoMediaSDK/ZiggeoMediaSDK.h>
#import <React/RCTLog.h>
#import "ZiggeoRecorderContext.h"
#import "ZiggeoConstants.h"
#import "ZiggeoQRScannerContext.h"

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
    
    [ZiggeoConstants setAppToken:_appToken];
    [[ZiggeoConstants sharedZiggeoRecorderContextInstance] setRecorder:self];
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
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setRecorderCacheConfig:config];
}

RCT_EXPORT_METHOD(setRecorderInterfaceConfig:(NSDictionary *)config)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setRecorderInterfaceConfig:config];
}

RCT_EXPORT_METHOD(setUploadingConfig:(NSDictionary *)config)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setUploadingConfig:config];
}

RCT_EXPORT_METHOD(setLiveStreamingEnabled:(BOOL)enabled)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setLiveStreamingEnabled:enabled];
}

RCT_EXPORT_METHOD(setAutostartRecordingAfter:(NSInteger)seconds)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setAutostartRecordingAfter:(int)seconds];
}

RCT_EXPORT_METHOD(setStartDelay:(NSInteger)delay)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setStartDelay:(int)delay];
}

RCT_EXPORT_METHOD(setBlurMode:(BOOL)enabled)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setBlurMode:enabled];
}

RCT_EXPORT_METHOD(setExtraArgsForRecorder:(NSDictionary*)map)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setExtraArgsForRecorder:map];
}

RCT_EXPORT_METHOD(setThemeArgsForRecorder:(NSDictionary*)map)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setThemeArgsForRecorder:map];
}

RCT_EXPORT_METHOD(setCoverSelectorEnabled:(BOOL)enabled)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setCoverSelectorEnabled:enabled];
}

RCT_EXPORT_METHOD(setMaxRecordingDuration:(NSInteger)seconds)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setMaxRecordingDuration:(int)seconds];
}

RCT_EXPORT_METHOD(setVideoWidth:(NSInteger)videoWidth)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setVideoWidth:(int)videoWidth];
}

RCT_EXPORT_METHOD(setVideoHeight:(NSInteger)videoHeight)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setVideoHeight:(int)videoHeight];
}

RCT_EXPORT_METHOD(setVideoBitrate:(NSInteger)videoBitrate)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setVideoBitrate:(int)videoBitrate];
}

RCT_EXPORT_METHOD(setAudioSampleRate:(NSInteger)audioSampleRate)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setAudioSampleRate:(int)audioSampleRate];
}

RCT_EXPORT_METHOD(setAudioBitrate:(NSInteger)audioBitrate)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setAudioBitrate:(int)audioBitrate];
}

RCT_EXPORT_METHOD(setCameraSwitchEnabled:(BOOL)visible)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setCameraSwitchEnabled:visible];
}

RCT_EXPORT_METHOD(setSendImmediately:(BOOL)sendImmediately)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setSendImmediately:sendImmediately];
}

RCT_EXPORT_METHOD(setQuality:(id)quality)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setQuality:(int)quality];
}

RCT_EXPORT_METHOD(setCamera:(id)cameraDevice)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] setCamera:(NSString *)cameraDevice];
}

// MARK: - Videos
RCT_REMAP_METHOD(record,
                 recordWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [ZiggeoConstants sharedZiggeoRecorderContextInstance].resolveBlock = resolve;
    [ZiggeoConstants sharedZiggeoRecorderContextInstance].rejectBlock = reject;

    dispatch_async(dispatch_get_main_queue(), ^{
        // [[ZiggeoConstants sharedZiggeoInstance] setBlurringEffect:true];
        // [[ZiggeoConstants sharedZiggeoInstance] setBlurringMaskColor:UIColor.redColor];
        // [[ZiggeoConstants sharedZiggeoInstance] setBlurringMaskAlpha:0.6];
        // [[ZiggeoConstants sharedZiggeoInstance] setMaxRecordingDuration:30];
        [[ZiggeoConstants sharedZiggeoInstance] record];
    });
}

RCT_REMAP_METHOD(startImageRecorder,
                 startImageRecorderResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [ZiggeoConstants sharedZiggeoRecorderContextInstance].resolveBlock = resolve;
    [ZiggeoConstants sharedZiggeoRecorderContextInstance].rejectBlock = reject;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ZiggeoConstants sharedZiggeoInstance] startImageRecorder];
    });
}

RCT_EXPORT_METHOD(showImage:(NSArray *)imageTokens
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [ZiggeoConstants sharedZiggeoRecorderContextInstance].resolveBlock = resolve;
    [ZiggeoConstants sharedZiggeoRecorderContextInstance].rejectBlock = reject;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[ZiggeoConstants sharedZiggeoInstance] showImage:imageTokens];
    });
}

RCT_REMAP_METHOD(startAudioRecorder,
                 startAudioRecorderResolver:(RCTPromiseResolveBlock)resolve
                 startAudioRecorderRejecter:(RCTPromiseRejectBlock)reject)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [ZiggeoConstants sharedZiggeoRecorderContextInstance].resolveBlock = resolve;
    [ZiggeoConstants sharedZiggeoRecorderContextInstance].rejectBlock = reject;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[ZiggeoConstants sharedZiggeoInstance] startAudioRecorder];
    });
}

RCT_EXPORT_METHOD(startAudioPlayer:(NSArray *)audioTokens
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [ZiggeoConstants sharedZiggeoRecorderContextInstance].resolveBlock = resolve;
    [ZiggeoConstants sharedZiggeoRecorderContextInstance].rejectBlock = reject;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ZiggeoConstants sharedZiggeoInstance] startAudioPlayer:audioTokens];
    });
}

RCT_EXPORT_METHOD(startScreenRecorder:(NSString *)appGroup
                  preferredExtension:(NSString *)preferredExtension
                  startScreenRecorderResolver:(RCTPromiseResolveBlock)resolve
                  startScreenRecorderRejecter:(RCTPromiseRejectBlock)reject)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [ZiggeoConstants sharedZiggeoRecorderContextInstance].resolveBlock = resolve;
    [ZiggeoConstants sharedZiggeoRecorderContextInstance].rejectBlock = reject;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[ZiggeoConstants sharedZiggeoInstance] startScreenRecorderWithAppGroup:appGroup preferredExtension:preferredExtension];
    });
}

RCT_EXPORT_METHOD(uploadFromPath:(NSString*)fileName
                  argsMap:(NSDictionary*)map
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [ZiggeoConstants sharedZiggeoRecorderContextInstance].resolveBlock = resolve;
    [ZiggeoConstants sharedZiggeoRecorderContextInstance].rejectBlock = reject;
    
    if (fileName != nil) {
        [[ZiggeoConstants sharedZiggeoInstance] uploadFromPath:fileName
                                                          Data:map
                                                      Callback:^(NSDictionary *jsonObject, NSURLResponse *response, NSError *error) {
        } Progress:^(int totalBytesSent, int totalBytesExpectedToSend) {
        } ConfirmCallback:^(NSDictionary *jsonObject, NSURLResponse *response, NSError *error) {
        }];
    } else {
        reject(@"ERR_NOFILE", @"empty filename", [NSError errorWithDomain:@"recorder" code:0 userInfo:@{@"ERR_NOFILE": @"empty filename"}]);
    }
}

RCT_EXPORT_METHOD(uploadFromFileSelector:(NSDictionary*)map
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [ZiggeoConstants sharedZiggeoRecorderContextInstance].resolveBlock = resolve;
    [ZiggeoConstants sharedZiggeoRecorderContextInstance].rejectBlock = reject;

    [self applyAdditionalParams:map context:[ZiggeoConstants sharedZiggeoRecorderContextInstance]];

    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        data[@"media_types"] = @[@"video", @"audio", @"image"];
        [[ZiggeoConstants sharedZiggeoInstance] uploadFromFileSelector:data];
    });
}

RCT_EXPORT_METHOD(cancelCurrentUpload:(BOOL)delete_file
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [ZiggeoConstants sharedZiggeoRecorderContextInstance].resolveBlock = resolve;
    [ZiggeoConstants sharedZiggeoRecorderContextInstance].rejectBlock = reject;
    
    [[ZiggeoConstants sharedZiggeoInstance] cancelUpload:@"" :delete_file];
}

RCT_EXPORT_METHOD(cancelUploadByPath:(NSString *)path
                  delete_file:(BOOL)delete_file
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [ZiggeoConstants sharedZiggeoRecorderContextInstance].resolveBlock = resolve;
    [ZiggeoConstants sharedZiggeoRecorderContextInstance].rejectBlock = reject;
    
    [[ZiggeoConstants sharedZiggeoInstance] cancelUpload:path :delete_file];
}

RCT_EXPORT_METHOD(startQrScanner:(NSDictionary*)map
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    ZiggeoQRScannerContext *context = [[ZiggeoQRScannerContext alloc] init];
    [context setRecorder:self];
    Ziggeo *ziggeo = [[Ziggeo alloc] init];
    [ziggeo setQRScannerDelegate:context];

    context.resolveBlock = resolve;
    context.rejectBlock = reject;

    dispatch_async(dispatch_get_main_queue(), ^{
        [ziggeo startQrScanner:map];
    });
}

@end
