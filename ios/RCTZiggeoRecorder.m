//
//  ZiggeoRecorderRCT.m
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTZiggeoRecorder.h"
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>

@interface UploadingContext: NSObject<UIImagePickerControllerDelegate, UINavigationControllerDelegate,ZiggeoRecorder2Delegate,ZiggeoVideosDelegate>
@property (strong, nonatomic) RCTPromiseResolveBlock resolveBlock;
@property (strong, nonatomic) RCTPromiseRejectBlock rejectBlock;
@property (strong, nonatomic) RCTZiggeoRecorder* recorder;
@property (nonatomic) int maxAllowedDurationInSeconds;
@property (nonatomic) bool enforceDuration;
@end;

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

@implementation RCTZiggeoRecorder

RCT_EXPORT_MODULE();

- (NSDictionary *)constantsToExport
{
    return @{ @"frontCamera": @(UIImagePickerControllerCameraDeviceFront),
              @"rearCamera" : @(UIImagePickerControllerCameraDeviceRear)};
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"UploadProgress"];
}

RCT_EXPORT_METHOD(setAppToken:(NSString *)token)
{
    RCTLogInfo(@"application token set: %@", token);
    _appToken = token;
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

RCT_EXPORT_METHOD(setAutostartRecordingAfter:(NSInteger)seconds)
{
    _autostartRecordingAfter = seconds;
}

RCT_EXPORT_METHOD(setExtraArgsForCreateVideo:(NSDictionary*)map)
{
    _additionalRecordingParams = map;
}

RCT_EXPORT_METHOD(setMaxRecordingDuration:(NSInteger)seconds)
{
    _maxRecordingDuration = seconds;
}

RCT_EXPORT_METHOD(setSendImmediately:(BOOL)sendImmediately)
{
    _sendImmediately = sendImmediately;
}

RCT_EXPORT_METHOD(cancelRequest)
{
    
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
        Ziggeo* m_ziggeo = [[Ziggeo alloc] initWithToken:_appToken];
        ZiggeoRecorder2* recorder = [[ZiggeoRecorder2 alloc] initWithZiggeoApplication:m_ziggeo];
        recorder.coverSelectorEnabled = _coverSelectorEnabled;
        recorder.cameraFlipButtonVisible = _cameraFlipButtonVisible;
        recorder.cameraDevice = _camera;
        recorder.recorderDelegate = context;
        recorder.extraArgsForCreateVideo = _additionalRecordingParams;
        m_ziggeo.videos.delegate = context;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:recorder animated:true completion:nil];
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
        
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = context;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:@"public.movie", nil];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:imagePicker animated:true completion:nil];
    });
}

RCT_REMAP_METHOD(uploadFromFileSelector,
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
        
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = context;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:@"public.movie", nil];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:imagePicker animated:true completion:nil];
    });
}


RCT_EXPORT_METHOD(uploadFromPath:(NSString*)fileName
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    UploadingContext* context = [[UploadingContext alloc] init];
    context.resolveBlock = resolve;
    context.rejectBlock = reject;
    context.recorder = self;
    
    if(fileName != nil)
    {
        Ziggeo* m_ziggeo = [[Ziggeo alloc] initWithToken:_appToken];
        m_ziggeo.videos.delegate = context;
        [m_ziggeo.videos createVideoWithData:_additionalRecordingParams file:fileName cover:nil callback:nil Progress:nil];
    }
    else
    {
        reject(@"ERR_NOFILE", @"empty filename", [NSError errorWithDomain:@"recorder" code:0 userInfo:@{@"ERR_NOFILE":@"empty filename"}]);
    }
}

@end

