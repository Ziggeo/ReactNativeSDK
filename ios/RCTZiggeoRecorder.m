//
//  ZiggeoRecorderRCT.m
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTZiggeoRecorder.h"
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>

@implementation RCTZiggeoRecorder
{
    RCTPromiseResolveBlock _resolveBlock;
    RCTPromiseRejectBlock _rejectBlock;
}

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

-(void) ziggeoRecorderDidCancel
{
    if(_rejectBlock) _rejectBlock(@"cancelled", @"recording was cancelled", [NSError errorWithDomain:@"recorder" code:0 userInfo:@{@"error":@"recording was cancelled"}]);
    _rejectBlock = nil;
}

RCT_REMAP_METHOD(record,
                 recordWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    _resolveBlock = resolve;
    _rejectBlock = reject;
    dispatch_async(dispatch_get_main_queue(), ^{
        Ziggeo* m_ziggeo = [[Ziggeo alloc] initWithToken:_appToken];
        ZiggeoRecorder2* recorder = [[ZiggeoRecorder2 alloc] initWithZiggeoApplication:m_ziggeo];
        recorder.coverSelectorEnabled = _coverSelectorEnabled;
        recorder.cameraFlipButtonVisible = _cameraFlipButtonVisible;
        recorder.cameraDevice = _camera;
        recorder.recorderDelegate = self;
        recorder.extraArgsForCreateVideo = _additionalRecordingParams;
        m_ziggeo.videos.delegate = self;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:recorder animated:true completion:nil];
    });
}

RCT_EXPORT_METHOD(upload:(NSString*)fileName
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    _resolveBlock = resolve;
    _rejectBlock = reject;
    
    if(fileName != nil)
    {
        Ziggeo* m_ziggeo = [[Ziggeo alloc] initWithToken:_appToken];
        m_ziggeo.videos.delegate = self;
        [m_ziggeo.videos createVideoWithData:_additionalRecordingParams file:fileName cover:nil callback:nil Progress:nil];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.delegate = self;
            imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:@"public.movie", nil];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:imagePicker animated:true completion:nil];
        });
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:true completion:nil];
    NSURL* url = info[@"UIImagePickerControllerMediaURL"];
    Ziggeo* m_ziggeo = [[Ziggeo alloc] initWithToken:_appToken];
    m_ziggeo.videos.delegate = self;
    [m_ziggeo.videos createVideoWithData:_additionalRecordingParams file:url.path cover:nil callback:nil Progress:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:true completion:nil];
    if(_rejectBlock) _rejectBlock(@"cancelled", @"uploading was cancelled", [NSError errorWithDomain:@"recorder" code:0 userInfo:@{@"error":@"uploading was cancelled"}]);
    _rejectBlock = nil;
}


-(void) videoUploadCompleteForPath:(NSString*)sourcePath token:(NSString*)token withResponse:(NSURLResponse*)response error:(NSError*)error json:(NSDictionary*)json
{
    if(error == nil)
    {
        if(_resolveBlock)
        {
            _resolveBlock(token);
            _resolveBlock = nil;
        }
    }
    else if(_rejectBlock)
    {
        _rejectBlock(@"error", @"recorder error", error);
        _rejectBlock = nil;
    }
}

-(void) videoPreparingToUploadWithPath:(NSString*)sourcePath {}
-(void) videoPreparingToUploadWithPath:(NSString*)sourcePath token:(NSString*)token {}

-(void) videoUploadStartedWithPath:(NSString*)sourcePath token:(NSString*)token backgroundTask:(NSURLSessionTask*)uploadingTask {}
-(void) videoUploadProgressForPath:(NSString*)sourcePath token:(NSString*)token totalBytesSent:(int)bytesSent totalBytesExpectedToSend:(int)totalBytes
{
    [self sendEventWithName:@"UploadProgress" body:@{@"bytesSent": @(bytesSent), @"totalBytes":@(totalBytes), @"fileName":sourcePath, @"token":token }];
}


@end
