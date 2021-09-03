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
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:@"public.image", nil];
        
        UIViewController* parentController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (parentController.presentedViewController && parentController != parentController.presentedViewController) {
            parentController = parentController.presentedViewController;
        }
        [parentController presentViewController:imagePicker animated:true completion:nil];
    });
}

RCT_REMAP_METHOD(chooseImage,
                chooseImageWithResolver:(RCTPromiseResolveBlock)resolve
                rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        ZiggeoImageContext *context = [[ZiggeoImageContext alloc] init];
        context.resolveBlock = resolve;
        context.rejectBlock = reject;
        context.ziggeoImage = self;

        UIImagePickerController *imagePicker = [[RotatingImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = context;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:@"public.image", nil];
        
        UIViewController* parentController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (parentController.presentedViewController && parentController != parentController.presentedViewController) {
            parentController = parentController.presentedViewController;
        }
        [parentController presentViewController:imagePicker animated:true completion:nil];
    });
}

RCT_EXPORT_METHOD(showImage:(NSString *)imageToken
                showImageWithResolver:(RCTPromiseResolveBlock)resolve
                rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        Ziggeo *m_ziggeo = [[Ziggeo alloc] initWithToken:self->_appToken];
        m_ziggeo.connect.serverAuthToken = self.serverAuthToken;
        m_ziggeo.connect.clientAuthToken = self.clientAuthToken;

        [m_ziggeo.images downloadImageWithToken:imageToken Callback:^(NSString *filePath) {
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
                if (data == nil)
                    return;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    resolve([UIImage imageWithData: data]);
                });
            });
        }];
    });
}

@end
