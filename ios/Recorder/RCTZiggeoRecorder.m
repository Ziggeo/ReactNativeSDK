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
    NSInteger _startDelay;
    ZiggeoRecorderContext *context;
}

@synthesize startDelay = _startDelay;

RCT_EXPORT_MODULE();

- (NSDictionary *)constantsToExport
{
    return @{
              @"frontCamera": @(UIImagePickerControllerCameraDeviceFront),
              @"rearCamera" : @(UIImagePickerControllerCameraDeviceRear),
              @"highQuality" : @(HighestQuality),
              @"mediumQuality" : @(MediumQuality),
              @"lowQuality" : @(LowQuality)
    };
}

- (NSArray<NSString *> *)supportedEvents
{
    return [[NSArray alloc] initWithObjects:kZiggeoEventsArray];;
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
    RCTLogInfo(@"server auth token set: %@", token);
    _clientAuthToken = token;
}

RCT_EXPORT_METHOD(setCameraSwitchEnabled:(BOOL)visible)
{
    RCTLogInfo(@"flip button visible: %i", visible);
    _cameraFlipButtonVisible = visible;
}

RCT_EXPORT_METHOD(setCoverSelectorEnabled:(BOOL)enabled)
{
    RCTLogInfo(@"cover selector enabled: %i", enabled);
    _coverSelectorEnabled = enabled;
}

RCT_EXPORT_METHOD(setCamera:(NSInteger)cameraDevice)
{
    RCTLogInfo(@"camera device: %li", (long)cameraDevice);
    _camera = cameraDevice;
}

RCT_EXPORT_METHOD(setQuality:(NSInteger)quality)
{
    _quality = quality;
}

RCT_EXPORT_METHOD(setAutostartRecordingAfter:(NSInteger)seconds)
{
    _autostartRecordingAfter = seconds;
}

RCT_EXPORT_METHOD(setExtraArgsForCreateVideo:(NSDictionary*)map)
{
    _additionalRecordingParams = map;
}

RCT_EXPORT_METHOD(setExtraArgsForRecorder:(NSDictionary*)map)
{
    _additionalRecordingParams = map;
}

RCT_EXPORT_METHOD(setThemeArgsForRecorder:(NSDictionary*)map)
{
    _additionalThemeParams = map;
}

RCT_EXPORT_METHOD(setMaxRecordingDuration:(NSInteger)seconds)
{
    _maxRecordingDuration = seconds;
}

RCT_EXPORT_METHOD(setSendImmediately:(BOOL)sendImmediately)
{
    _sendImmediately = sendImmediately;
}

RCT_EXPORT_METHOD(setLiveStreamingEnabled:(BOOL)enabled)
{
    _liveStreamingEnabled = enabled;
}

RCT_EXPORT_METHOD(setVideoWidth:(NSInteger)videoWidth)
{
    _videoWidth = videoWidth;
}

RCT_EXPORT_METHOD(setVideoHeight:(NSInteger)videoHeight)
{
    _videoHeight = videoHeight;
}

RCT_EXPORT_METHOD(setVideoBitrate:(NSInteger)videoBitrate)
{
    _videoBitrate = videoBitrate;
}

RCT_EXPORT_METHOD(setAudioSampleRate:(NSInteger)audioSampleRate)
{
    _audioSampleRate = audioSampleRate;
}

RCT_EXPORT_METHOD(setAudioBitrate:(NSInteger)audioBitrate)
{
    _audioBitrate = audioBitrate;
}


RCT_EXPORT_METHOD(cancelRequest)
{
    if (context == nil) {
        context = [[ZiggeoRecorderContext alloc] init];
    }
    [context cancelRequest];
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


// MARK: - Videos
RCT_REMAP_METHOD(record,
                 recordWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    if (context == nil) {
        context = [[ZiggeoRecorderContext alloc] init];
    }
    context.resolveBlock = resolve;
    context.rejectBlock = reject;
    context.recorder = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        Ziggeo *m_ziggeo = [[Ziggeo alloc] initWithToken:self->_appToken];
        m_ziggeo.connect.serverAuthToken = self.serverAuthToken;
        m_ziggeo.connect.clientAuthToken = self.clientAuthToken;
        [m_ziggeo.config setRecorderCacheConfig:self.cacheConfig];
        [m_ziggeo checkHardwarePermission:context];
        context.currentZiggeo = m_ziggeo;

        ZiggeoRecorder* recorder = [[ZiggeoRecorder alloc] initWithZiggeoApplication:m_ziggeo];
        recorder.coverSelectorEnabled = self->_coverSelectorEnabled;
        recorder.cameraFlipButtonVisible = self->_cameraFlipButtonVisible;
        recorder.cameraDevice = self->_camera;
        recorder.recorderDelegate = context;
        recorder.uploadDelegate = context;
        recorder.extraArgsForCreateVideo = self->_additionalRecordingParams;
        recorder.useLiveStreaming = self->_liveStreamingEnabled;
        recorder.recordingQuality = self->_quality;
        recorder.interfaceConfig = parseRecorderInterfaceConfig(self.interfaceConfig);
        recorder.autostartRecordingAfterSeconds = self.autostartRecordingAfter;
        recorder.startDelay = self.startDelay;
        if (self->_videoWidth != 0) recorder.videoWidth = (int)self.videoWidth;
        if (self->_videoHeight != 0) recorder.videoHeight = (int)self.videoHeight;
        if (self->_videoBitrate != 0) recorder.videoBitrate = (int)self.videoBitrate;
        if (self->_audioSampleRate != 0) recorder.audioSampleRate = (int)self.audioSampleRate;
        if (self->_audioBitrate != 0) recorder.audioBitrate = (int)self.audioBitrate;
        if (self->_additionalThemeParams) {
            if (recorder.extraArgsForCreateVideo) {
                NSMutableDictionary* merged = [[NSMutableDictionary alloc] initWithDictionary:recorder.extraArgsForCreateVideo];
                [merged addEntriesFromDictionary:self->_additionalThemeParams];
                recorder.extraArgsForCreateVideo = merged;
            }
            else recorder.extraArgsForCreateVideo = self->_additionalThemeParams;
        }
        recorder.maxRecordedDurationSeconds = self->_maxRecordingDuration;
        if (recorder.extraArgsForCreateVideo && ([@"true" isEqualToString:recorder.extraArgsForCreateVideo[@"hideRecorderControls"]] || [[recorder.extraArgsForCreateVideo valueForKey:@"hideRecorderControls"] boolValue] )) {
            recorder.controlsVisible = false;
        }
        [self showPresentViewController:recorder];
    });
}

RCT_EXPORT_METHOD(uploadFromFileSelector:(NSDictionary*)map
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (context == nil) {
            context = [[ZiggeoRecorderContext alloc] init];
        }
        context.resolveBlock = resolve;
        context.rejectBlock = reject;
        context.recorder = self;
        [self applyAdditionalParams:map context:context];

        Ziggeo *m_ziggeo = [[Ziggeo alloc] initWithToken:self->_appToken];
        m_ziggeo.connect.serverAuthToken = self.serverAuthToken;
        m_ziggeo.connect.clientAuthToken = self.clientAuthToken;
        [m_ziggeo checkHardwarePermission:context];
        context.currentZiggeo = m_ziggeo;

        UIImagePickerController *imagePicker = [[RotatingImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = context;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:@"public.movie", nil];
        [self showPresentViewController:imagePicker];
    });
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

RCT_EXPORT_METHOD(uploadFromPath:(NSString*)fileName
                  argsMap:(NSDictionary*)map
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    if (context == nil) {
        context = [[ZiggeoRecorderContext alloc] init];
    }
    context.resolveBlock = resolve;
    context.rejectBlock = reject;
    context.recorder = self;
    [self applyAdditionalParams:map context:context];
    
    if (fileName != nil) {
        Ziggeo *m_ziggeo = [[Ziggeo alloc] initWithToken:_appToken];
        m_ziggeo.connect.serverAuthToken = self.serverAuthToken;
        m_ziggeo.connect.clientAuthToken = self.clientAuthToken;
        [m_ziggeo.config setRecorderCacheConfig:self.cacheConfig];
        [m_ziggeo checkHardwarePermission:context];
        m_ziggeo.videos.uploadDelegate = context;
        [m_ziggeo.videos uploadVideoWithPath:fileName Data:map];
        context.currentZiggeo = m_ziggeo;
    } else {
        reject(@"ERR_NOFILE", @"empty filename", [NSError errorWithDomain:@"recorder" code:0 userInfo:@{@"ERR_NOFILE":@"empty filename"}]);
    }
}

RCT_EXPORT_METHOD(setStartDelay:(NSInteger)delay)
{
    _startDelay = delay;
}

RCT_EXPORT_METHOD(setRecorderCacheConfig:(NSDictionary *)config)
{
    RCTLogInfo(@"recorder cache config set: %@", config);
    self.cacheConfig = config;
}

RCT_EXPORT_METHOD(setRecorderInterfaceConfig:(NSDictionary *)config)
{
    RCTLogInfo(@"recorder interface config set: %@", config);
    self.interfaceConfig = config;
}


// MARK: Audios

RCT_REMAP_METHOD(startAudioRecorder,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    if (context == nil) {
        context = [[ZiggeoRecorderContext alloc] init];
    }
    context.resolveBlock = resolve;
    context.rejectBlock = reject;
    context.recorder = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        Ziggeo *m_ziggeo = [[Ziggeo alloc] initWithToken:self->_appToken];
        m_ziggeo.connect.serverAuthToken = self.serverAuthToken;
        m_ziggeo.connect.clientAuthToken = self.clientAuthToken;
        [m_ziggeo checkHardwarePermission:context];
        context.currentZiggeo = m_ziggeo;

        ZiggeoAudioRecorder *audioRecorder = [[ZiggeoAudioRecorder alloc] initWithZiggeoApplication:m_ziggeo];
        audioRecorder.recorderDelegate = context;
        audioRecorder.uploadDelegate = context;
        [self showPresentViewController:audioRecorder];
    });
}

RCT_EXPORT_METHOD(startAudioPlayer:(NSString *)audioToken
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    if (context == nil) {
        context = [[ZiggeoRecorderContext alloc] init];
    }
    context.resolveBlock = resolve;
    context.rejectBlock = reject;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        Ziggeo *m_ziggeo = [[Ziggeo alloc] initWithToken:self->_appToken];
        m_ziggeo.connect.serverAuthToken = self.serverAuthToken;
        m_ziggeo.connect.clientAuthToken = self.clientAuthToken;
        [m_ziggeo checkHardwarePermission:context];
        context.currentZiggeo = m_ziggeo;

        [m_ziggeo.audios downloadAudioWithToken:audioToken Callback:^(NSString *filePath) {
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                RCTLogInfo(@"audio downloaded: %@", filePath);
                [self playAudioWithPath:filePath];
            });
        }];
    });
}

- (void)playAudioWithPath:(NSString*)path {
    dispatch_async(dispatch_get_main_queue(), ^{        
        NSURL *url = [[NSURL alloc] initWithString:path];
        AVPlayer *player = [AVPlayer playerWithURL:url];

        AVPlayerViewController *playerController = [[AVPlayerViewController alloc] init];
        playerController.player = player;
        [player play];
        [self showPresentViewController:playerController];
    });
}


// MARK: Images

RCT_REMAP_METHOD(startImageRecorder,
                 startImageRecorderResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    if (context == nil) {
        context = [[ZiggeoRecorderContext alloc] init];
    }
    context.resolveBlock = resolve;
    context.rejectBlock = reject;
    context.recorder = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        Ziggeo *m_ziggeo = [[Ziggeo alloc] initWithToken:self->_appToken];
        m_ziggeo.connect.serverAuthToken = self.serverAuthToken;
        m_ziggeo.connect.clientAuthToken = self.clientAuthToken;
        [m_ziggeo checkHardwarePermission:context];
        context.currentZiggeo = m_ziggeo;

        UIImagePickerController *imagePicker = [[RotatingImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = context;
        imagePicker.allowsEditing = false;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:@"public.image", nil];
        [self showPresentViewController:imagePicker];
    });
}

RCT_REMAP_METHOD(uploadImageFromFileSelector,
                 uploadImageFromFileSelectorResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    if (context == nil) {
        context = [[ZiggeoRecorderContext alloc] init];
    }
    context.resolveBlock = resolve;
    context.rejectBlock = reject;
    context.recorder = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        Ziggeo *m_ziggeo = [[Ziggeo alloc] initWithToken:self->_appToken];
        m_ziggeo.connect.serverAuthToken = self.serverAuthToken;
        m_ziggeo.connect.clientAuthToken = self.clientAuthToken;
        [m_ziggeo checkHardwarePermission:context];
        context.currentZiggeo = m_ziggeo;

        UIImagePickerController* imagePicker = [[RotatingImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = context;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:@"public.image", nil];
        [self showPresentViewController:imagePicker];
    });
}

RCT_EXPORT_METHOD(showImage:(NSString *)imageToken
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        Ziggeo *m_ziggeo = [[Ziggeo alloc] initWithToken:self->_appToken];
        m_ziggeo.connect.serverAuthToken = self.serverAuthToken;
        m_ziggeo.connect.clientAuthToken = self.clientAuthToken;

        [m_ziggeo.images downloadImageWithToken:imageToken Callback:^(NSString *filePath) {
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                RCTLogInfo(@"image downloaded: %@", filePath);
            });
        }];
    });
}

@end

