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
    m_ziggeo.videos.delegate = self;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:recorder animated:true completion:nil];
  });
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
  [self sendEventWithName:@"UploadProgress" body:@{@"bytesSent": @(bytesSent), @"totalBytes":@(totalBytes)}];
}


@end
