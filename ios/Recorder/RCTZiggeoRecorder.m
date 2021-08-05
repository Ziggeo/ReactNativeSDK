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

@interface UploadingContext: NSObject<UIImagePickerControllerDelegate, UINavigationControllerDelegate, ZiggeoRecorderDelegate, ZiggeoVideosDelegate>
@property (strong, nonatomic) RCTPromiseResolveBlock resolveBlock;
@property (strong, nonatomic) RCTPromiseRejectBlock rejectBlock;
@property (strong, nonatomic) RCTZiggeoRecorder* recorder;
@property (nonatomic) int maxAllowedDurationInSeconds;
@property (nonatomic) bool enforceDuration;
@end;

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

@implementation UploadingContext
-(void)resolve:(NSString*)token {
    if(_resolveBlock) _resolveBlock(token);
    _resolveBlock = nil;
    _rejectBlock = nil;
    self.recorder = nil;
}

-(void)reject:(NSString*)code message:(NSString*)message {
    if(_rejectBlock) _rejectBlock(code, message, [NSError errorWithDomain:@"recorder" code:0 userInfo:@{code:message}]);
    _resolveBlock = nil;
    _rejectBlock = nil;
    self.recorder = nil;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:true completion:nil];
    NSURL* url = info[@"UIImagePickerControllerMediaURL"];
    
    NSMutableDictionary* recordingParams = [[NSMutableDictionary alloc] init];
    if(self.recorder.additionalRecordingParams != nil) [recordingParams addEntriesFromDictionary:self.recorder.additionalRecordingParams];
    if(self.maxAllowedDurationInSeconds > 0)
    {
        if(self.enforceDuration)
        {
            AVAsset* audioAsset = [AVURLAsset assetWithURL:url];
            CMTime assetTime = [audioAsset duration];
            Float64 duration = CMTimeGetSeconds(assetTime);
            if(duration > self.maxAllowedDurationInSeconds) {
                [self reject:@"ERR_DURATION_EXCEEDED" message:@"video duration is more than allowed"];
                return;
            }
        }
        else
        {
            NSDictionary* durationRecordingParams = @{ @"max_duration" : @(self.maxAllowedDurationInSeconds), @"enforce_duration": @"false"};
            [recordingParams addEntriesFromDictionary:durationRecordingParams];
        }
    }
    
    Ziggeo* m_ziggeo = [[Ziggeo alloc] initWithToken:_recorder.appToken];
    m_ziggeo.connect.serverAuthToken = _recorder.serverAuthToken;
    m_ziggeo.connect.clientAuthToken = _recorder.clientAuthToken;
    [m_ziggeo.config setRecorderCacheConfig:self.recorder.cacheConfig];
    m_ziggeo.videos.delegate = self;
    [m_ziggeo.videos createVideoWithData:recordingParams file:url.path cover:nil callback:nil Progress:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"image picker cancelled delegate");
    [picker dismissViewControllerAnimated:true completion:nil];
    [self reject:@"ERR_CANCELLED" message:@"cancelled by the user"];
}

-(void) videoUploadCompleteForPath:(NSString*)sourcePath token:(NSString*)token withResponse:(NSURLResponse*)response error:(NSError*)error json:(NSDictionary*)json
{
    if(error == nil)
    {
        [self resolve:token];
    }
    else
    {
        [self reject:@"ERR_UNKNOWN" message:@"unknown recorder error"];
    }
}

-(void) videoPreparingToUploadWithPath:(NSString*)sourcePath {}
-(void) videoPreparingToUploadWithPath:(NSString*)sourcePath token:(NSString*)token {}

-(void) videoUploadStartedWithPath:(NSString*)sourcePath token:(NSString*)token backgroundTask:(NSURLSessionTask*)uploadingTask {}
-(void) videoUploadProgressForPath:(NSString*)sourcePath token:(NSString*)token totalBytesSent:(int)bytesSent totalBytesExpectedToSend:(int)totalBytes
{
    if(_recorder != nil) [_recorder sendEventWithName:@"UploadProgress" body:@{@"bytesSent": @(bytesSent), @"totalBytes":@(totalBytes), @"fileName":sourcePath, @"token":token }];
}

-(void) ziggeoRecorderDidCancel
{
    [self reject:@"ERR_CANCELLED" message:@"cancelled by the user"];
}

-(void) ziggeoRecorderDidStop {
    if (_recorder != nil) {
        [_recorder sendEventWithName:@"RecordingStopped" body:@{}];
    }
}

-(void) ziggeoRecorderDidVerify {
    if (_recorder != nil) {
        [_recorder sendEventWithName:@"Verified" body:@{}];
    }
}

-(void) ziggeoRecorderDidProcess {
    if (_recorder != nil) {
        [_recorder sendEventWithName:@"Processed" body:@{}];
    }
}

-(void) ziggeoRecorderProcessing {
    if (_recorder != nil) {
        [_recorder sendEventWithName:@"Processing" body:@{}];
    }
}

-(void)setRecorder:(RCTZiggeoRecorder *)recorder {
    if(recorder != nil)
    {
        if(recorder.contexts == nil) recorder.contexts = [[NSMutableArray alloc] init];
        [recorder.contexts addObject:self];
    }
    else if(_recorder != nil)
    {
        [_recorder.contexts removeObject:self];
    }
    _recorder = recorder;
}

@end

@implementation RCTZiggeoRecorder {
    NSInteger _startDelay;
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
    return @[
        @"UploadProgress",
        @"RecordingStopped",
        @"Verified",
        @"Processed",
        @"Processing",
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
    
}

+(BOOL)requiresMainQueueSetup
{
    return YES;
}

RCT_REMAP_METHOD(record,
                 recordWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    UploadingContext* context = [[UploadingContext alloc] init];
    context.resolveBlock = resolve;
    context.rejectBlock = reject;
    context.recorder = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        Ziggeo* m_ziggeo = [[Ziggeo alloc] initWithToken:self->_appToken];
        m_ziggeo.connect.serverAuthToken = self.serverAuthToken;
        m_ziggeo.connect.clientAuthToken = self.clientAuthToken;
        [m_ziggeo.config setRecorderCacheConfig:self.cacheConfig];

        ZiggeoRecorder* recorder = [[ZiggeoRecorder alloc] initWithZiggeoApplication:m_ziggeo];
        recorder.coverSelectorEnabled = self->_coverSelectorEnabled;
        recorder.cameraFlipButtonVisible = self->_cameraFlipButtonVisible;
        recorder.cameraDevice = self->_camera;
        recorder.recorderDelegate = context;
        recorder.extraArgsForCreateVideo = self->_additionalRecordingParams;
        recorder.useLiveStreaming = self->_liveStreamingEnabled;
        recorder.recordingQuality = self->_quality;
        recorder.interfaceConfig = parseRecorderInterfaceConfig(self.interfaceConfig);
        recorder.autostartRecordingAfterSeconds = self.autostartRecordingAfter;
        recorder.startDelay = self.startDelay;
        if(self->_videoWidth != 0) recorder.videoWidth = (int)self.videoWidth;
        if(self->_videoHeight != 0) recorder.videoHeight = (int)self.videoHeight;
        if(self->_videoBitrate != 0) recorder.videoBitrate = (int)self.videoBitrate;
        if(self->_audioSampleRate != 0) recorder.audioSampleRate = (int)self.audioSampleRate;
        if(self->_audioBitrate != 0) recorder.audioBitrate = (int)self.audioBitrate;
        if(self->_additionalThemeParams)
        {
            if(recorder.extraArgsForCreateVideo) {
                NSMutableDictionary* merged = [[NSMutableDictionary alloc] initWithDictionary:recorder.extraArgsForCreateVideo];
                [merged addEntriesFromDictionary:self->_additionalThemeParams];
                recorder.extraArgsForCreateVideo = merged;
            }
            else recorder.extraArgsForCreateVideo = self->_additionalThemeParams;
        }
        recorder.maxRecordedDurationSeconds = self->_maxRecordingDuration;
        if(recorder.extraArgsForCreateVideo && ([@"true" isEqualToString:recorder.extraArgsForCreateVideo[@"hideRecorderControls"]] || [[recorder.extraArgsForCreateVideo valueForKey:@"hideRecorderControls"] boolValue] ))
        {
            recorder.controlsVisible = false;
        }
        m_ziggeo.videos.delegate = context;
        // [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:recorder animated:true completion:nil];
        UIViewController* parentController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while(parentController.presentedViewController && parentController != parentController.presentedViewController) {
            parentController = parentController.presentedViewController;
        }
        [parentController presentViewController:recorder animated:true completion:nil];
    });
    //_currentContext = context;
}


RCT_EXPORT_METHOD(uploadFromFileSelectorWithDurationLimit:(int)maxAllowedDurationInSeconds
                  enforceDuration:(int)enforceDuration
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UploadingContext* context = [[UploadingContext alloc] init];
        context.resolveBlock = resolve;
        context.rejectBlock = reject;
        context.recorder = self;
        context.maxAllowedDurationInSeconds = maxAllowedDurationInSeconds;
        context.enforceDuration = (enforceDuration != 0);

        UIImagePickerController* imagePicker = [[RotatingImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = context;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:@"public.movie", nil];
        
        UIViewController* parentController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while(parentController.presentedViewController && parentController != parentController.presentedViewController) {
            parentController = parentController.presentedViewController;
        }
        [parentController presentViewController:imagePicker animated:true completion:nil];
    });
}


RCT_REMAP_METHOD(uploadFromFileSelector,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    [self uploadFromFileSelector:nil resolver:resolve rejecter:reject];
}

-(void)applyAdditionalParams:(NSDictionary*)map context:(UploadingContext*)context {
    if(map != nil)
    {
        if([map objectForKey:@"max_duration"] != nil) {
            context.maxAllowedDurationInSeconds = [[map objectForKey:@"max_duration"] intValue];
        }
        if([map objectForKey:@"enforce_duration"] != nil) {
            context.enforceDuration = [[map objectForKey:@"enforce_duration"] boolValue];
        }
    }
}

RCT_EXPORT_METHOD(uploadFromFileSelector:(NSDictionary*)map
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UploadingContext* context = [[UploadingContext alloc] init];
        context.resolveBlock = resolve;
        context.rejectBlock = reject;
        context.recorder = self;
        context.maxAllowedDurationInSeconds = 0;
        context.enforceDuration = false;
        [self applyAdditionalParams:map context:context];
        
        UIImagePickerController* imagePicker = [[RotatingImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = context;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:@"public.movie", nil];
        
        UIViewController* parentController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while(parentController.presentedViewController && parentController != parentController.presentedViewController) {
            parentController = parentController.presentedViewController;
        }
        [parentController presentViewController:imagePicker animated:true completion:nil];
    });
}


RCT_EXPORT_METHOD(uploadFromPath:(NSString*)fileName
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self uploadFromPath:fileName argsMap:nil resolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(uploadFromPath:(NSString*)fileName
                  argsMap:(NSDictionary*)map
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    UploadingContext* context = [[UploadingContext alloc] init];
    context.resolveBlock = resolve;
    context.rejectBlock = reject;
    context.recorder = self;
    [self applyAdditionalParams:map context:context];
    
    if(fileName != nil)
    {
        Ziggeo* m_ziggeo = [[Ziggeo alloc] initWithToken:_appToken];
        m_ziggeo.connect.serverAuthToken = self.serverAuthToken;
        m_ziggeo.connect.clientAuthToken = self.clientAuthToken;
        [m_ziggeo.config setRecorderCacheConfig:self.cacheConfig];
        m_ziggeo.videos.delegate = context;
        [m_ziggeo.videos createVideoWithData:_additionalRecordingParams file:fileName cover:nil callback:nil Progress:nil];
    }
    else
    {
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

@end

