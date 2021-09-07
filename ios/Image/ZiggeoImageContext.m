//
//  ZiggeoImageContext.m
//  ReactIntegrationDemo
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

@import AVKit;
#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>
#import "ZiggeoImageContext.h"
#import "RCTZiggeoImage.h"

@implementation ZiggeoImageContext

- (void)resolve:(NSString*)token {
    if (_resolveBlock)
        _resolveBlock(token);
    
    _resolveBlock = nil;
    _rejectBlock = nil;
    _ziggeoImage = nil;
}

- (void)reject:(NSString*)code message:(NSString*)message {
    if (_rejectBlock)
        _rejectBlock(code, message, [NSError errorWithDomain:@"ziggeo_image" code:0 userInfo:@{code:message}]);
    
    _resolveBlock = nil;
    _rejectBlock = nil;
    _ziggeoImage = nil;
}

- (void)setZiggeoImage:(RCTZiggeoImage *)ziggeoImage {
    if (ziggeoImage != nil) {
        if (ziggeoImage.contexts == nil)
            ziggeoImage.contexts = [[NSMutableArray alloc] init];
        [ziggeoImage.contexts addObject:self];
    } else if(_ziggeoImage != nil) {
        [_ziggeoImage.contexts removeObject:self];
    }
    _ziggeoImage = ziggeoImage;
}


// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage* imageFile = info[@"UIImagePickerControllerOriginalImage"];
    Ziggeo *m_ziggeo = [[Ziggeo alloc] initWithToken:_ziggeoImage.appToken];
    m_ziggeo.connect.serverAuthToken = _ziggeoImage.serverAuthToken;
    m_ziggeo.connect.clientAuthToken = _ziggeoImage.clientAuthToken;
    m_ziggeo.images.uploadDelegate = self;
    [m_ziggeo.images uploadImageWithFile:imageFile];
    [picker dismissViewControllerAnimated:true completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"image picker cancelled delegate");
    [self reject:@"ERR_CANCELLED" message:@"cancelled by the user"];
    [picker dismissViewControllerAnimated:true completion:nil];
}

// MARK: - ZiggeoUploadDelegate

- (void)preparingToUploadWithPath:(NSString *)sourcePath {
    NSLog(@"preparingToUploadWithPath : %@", sourcePath);
}

- (void)preparingToUploadWithPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken {
    NSLog(@"preparingToUploadWithPath : %@", token);
}

- (void)failedToUploadWithPath:(NSString *)sourcePath {
}

- (void)uploadStartedWithPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken backgroundTask:(NSURLSessionTask *)uploadingTask {
    
}

- (void)uploadProgressForPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken totalBytesSent:(int)bytesSent totalBytesExpectedToSend:(int)totalBytes {
//    if (_ziggeoImage != nil) {
//        [_ziggeoImage sendEventWithName:@"UploadProgress" body:@{@"bytesSent": @(bytesSent), @"totalBytes":@(totalBytes), @"fileName":sourcePath, @"token":token }];
//    }
    NSLog(@"uploadProgressForPath : %i - %i", bytesSent, totalBytes);
}

- (void)uploadCompletedForPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken withResponse:(NSURLResponse *)response error:(NSError *)error json:(NSDictionary *)json {
    if (error == nil) {
        [self resolve:token];
    } else {
        [self reject:@"ERR_UNKNOWN" message:@"unknown recorder error"];
    }
}

- (void)deleteWithToken:(NSString *)token streamToken:(NSString *)streamToken withResponse:(NSURLResponse *)response error:(NSError *)error json:(NSDictionary *)json {
    
}

@end
