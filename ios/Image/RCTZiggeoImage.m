//
//  RCTZiggeoImage.m
//  ReactIntegrationDemo
//
//  Copyright © 2017 Ziggeo. All rights reserved.
//

@import AVKit;
#import <Foundation/Foundation.h>
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>
#import "RCTZiggeoImage.h"
#import "ZiggeoImageContext.h"
#import "RotatingImagePickerController.h"
#import "ZiggeoRecorderContext.h"


@implementation RCTZiggeoImage {
    
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

RCT_REMAP_METHOD(takePhoto,
                takePhotoWithResolver:(RCTPromiseResolveBlock)resolve
                rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        ZiggeoImageContext *context = [[ZiggeoImageContext alloc] init];
        context.resolveBlock = resolve;
        context.rejectBlock = reject;
        context.ziggeoImage = self;

        UIImagePickerController *imagePicker = [[RotatingImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = context;
        imagePicker.allowsEditing = false;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:@"public.image", nil];
        
        UIViewController *parentController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (parentController.presentedViewController && parentController != parentController.presentedViewController) {
            parentController = parentController.presentedViewController;
        }
        [parentController presentViewController:imagePicker animated:true completion:nil];
    });
}

RCT_REMAP_METHOD(chooseImage,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    [self chooseImage:nil resolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(chooseImage:(NSDictionary*)map
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ZiggeoImageContext *context = [[ZiggeoImageContext alloc] init];
        context.resolveBlock = resolve;
        context.rejectBlock = reject;
        context.ziggeoImage = self;
        
        UIImagePickerController* imagePicker = [[RotatingImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = context;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:@"public.image", nil];
        
        UIViewController *parentController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while(parentController.presentedViewController && parentController != parentController.presentedViewController) {
            parentController = parentController.presentedViewController;
        }
        [parentController presentViewController:imagePicker animated:true completion:nil];
    });
}

RCT_EXPORT_METHOD(downloadImage:(NSString *)imageToken
                downloadImageWithResolver:(RCTPromiseResolveBlock)resolve
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
