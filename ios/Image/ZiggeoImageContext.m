//
//  ZiggeoImageContext.m
//  ReactIntegrationDemo
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

@import AVKit;
#import <Foundation/Foundation.h>
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>
#import "ZiggeoImageContext.h"
#import "RCTZiggeoImage.h"

@implementation ZiggeoImageContext

- (void)resolve:(NSString*)token {
    if (self.resolveBlock)
        self.resolveBlock(token);
    
    self.resolveBlock = nil;
    self.rejectBlock = nil;
    self.ziggeoImage = nil;
}

- (void)reject:(NSString*)code message:(NSString*)message {
    if (self.rejectBlock)
        self.rejectBlock(code, message, [NSError errorWithDomain:@"ziggeo_image" code:0 userInfo:@{code:message}]);
    
    self.resolveBlock = nil;
    self.rejectBlock = nil;
    self.ziggeoImage = nil;
}

- (void)setImage:(RCTZiggeoImage *)image {
    if (image != nil) {
        if (image.contexts == nil)
            image.contexts = [[NSMutableArray alloc] init];
        [image.contexts addObject:self];
    } else if(self.ziggeoImage != nil) {
        [self.ziggeoImage.contexts removeObject:self];
    }
    self.ziggeoImage = image;
}


// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage* imageFile = info[@"UIImagePickerControllerOriginalImage"];

    Ziggeo *m_ziggeo = [[Ziggeo alloc] initWithToken:_ziggeoImage.appToken];
    m_ziggeo.connect.serverAuthToken = _ziggeoImage.serverAuthToken;
    m_ziggeo.connect.clientAuthToken = _ziggeoImage.clientAuthToken;
    m_ziggeo.images.uploadDelegate = self;
    [m_ziggeo.images uploadImageWithFile:imageFile];
    
    _pickerController = picker;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"image picker cancelled delegate");
    [self reject:@"ERR_CANCELLED" message:@"cancelled by the user"];
    [picker dismissViewControllerAnimated:true completion:nil];
}

// MARK: - ZiggeoUploadDelegate

- (void)preparingToUploadWithPath:(NSString *)sourcePath {
    
}

- (void)preparingToUploadWithPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_pickerController != nil) {
            [self->_pickerController dismissViewControllerAnimated:true completion:nil];
            self->_pickerController = nil;
        }
    });
}

- (void)failedToUploadWithPath:(NSString *)sourcePath {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_pickerController != nil) {
            [self->_pickerController dismissViewControllerAnimated:true completion:nil];
            self->_pickerController = nil;
        }
    });
}

- (void)uploadStartedWithPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken backgroundTask:(NSURLSessionTask *)uploadingTask {
    
}

- (void)uploadProgressForPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken totalBytesSent:(int)bytesSent totalBytesExpectedToSend:(int)totalBytes {
//    if (_ziggeoImage != nil) {
//        [_ziggeoImage sendEventWithName:@"UploadProgress" body:@{@"bytesSent": @(bytesSent), @"totalBytes":@(totalBytes), @"fileName":sourcePath, @"token":token }];
//    }
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
