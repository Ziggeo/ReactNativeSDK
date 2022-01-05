#import "RCTImages.h"
#import <Foundation/Foundation.h>
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>


@interface ImagesContext: NSObject<ZiggeoDelegate>

@property (strong, nonatomic) RCTPromiseResolveBlock resolveBlock;
@property (strong, nonatomic) RCTPromiseRejectBlock rejectBlock;
@property (strong, nonatomic) RCTImages* images;

@end;


@implementation ImagesContext

- (void)resolve:(NSString *)token {
    if (_resolveBlock) 
        _resolveBlock(token);
    _resolveBlock = nil;
    _rejectBlock = nil;
    self.images = nil;
}

- (void)reject:(NSString *)code message:(NSString *)message {
    if (_rejectBlock) 
        _rejectBlock(code, message, [NSError errorWithDomain:@"images" code:0 userInfo:@{code:message}]);
    _resolveBlock = nil;
    _rejectBlock = nil;
    self.images = nil;
}

@end;


@implementation RCTImages {
    Ziggeo *m_ziggeo;
}

static NSString *_appToken;
static NSString *_serverAuthToken;
static NSString *_clientAuthToken;

+ (NSString *)appToken { return _appToken; }
+ (NSString *)serverAuthToken { return _serverAuthToken; }
+ (NSString *)clientAuthToken { return _clientAuthToken; }


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
    ImagesContext *m_context = [[ImagesContext alloc] init];
    m_ziggeo = [[Ziggeo alloc] initWithToken:_appToken Delegate:m_context];
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


RCT_EXPORT_METHOD(index:(NSDictionary *)map resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [[m_ziggeo images] index:map Callback:^(NSArray *jsonArray, NSError *error) {
        if (error == NULL) {
            resolve(jsonArray);
        } else {
            reject(@"ERR_IMAGES", @"image index error", error);
        }
    }];
}

RCT_EXPORT_METHOD(destroy:(NSString *)tokenOrKey resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [[m_ziggeo images] destroy:tokenOrKey Callback:^(NSDictionary *jsonObject, NSURLResponse *response, NSError *error) {
        if (error == NULL) {
            resolve(jsonObject);
        } else {
            reject(@"ERR_IMAGES", @"image destroy error", error);
        }
    }];
}

RCT_EXPORT_METHOD(get:(NSString *)tokenOrKey resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [[m_ziggeo images] get:tokenOrKey Callback:^(NSString *filePath) {
        resolve(filePath);
    }];
}

RCT_EXPORT_METHOD(create:(NSString *)file map:(NSDictionary *)map resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [[m_ziggeo images] create:file Data:map Callback:^(NSDictionary *jsonObject, NSURLResponse *response, NSError *error) {
        if (error != NULL) {
            reject(@"ERR_IMAGES", @"image create error", error);
        }
    } Progress:^(int totalBytesSent, int totalBytesExpectedToSend) {
    } ConfirmCallback:^(NSDictionary *jsonObject, NSURLResponse *response, NSError *error) {
        if (error == NULL) {
            resolve(jsonObject);
        } else {
            reject(@"ERR_IMAGES", @"image create error", error);
        }
    }];
}

RCT_EXPORT_METHOD(update:(NSString *)model resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [[m_ziggeo images] update:model ModelInJson:model Callback:^(NSDictionary *jsonObject, NSURLResponse *response, NSError *error) {
        if (error == NULL) {
            resolve(jsonObject);
        } else {
            reject(@"ERR_IMAGES", @"image update error", error);
        }
    }];
}

RCT_EXPORT_METHOD(source:(NSString *)tokenOrKey resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve([[m_ziggeo images] getImageUrl:tokenOrKey]);
}

RCT_EXPORT_METHOD(getImageUrl:(NSString *)tokenOrKey resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve([[m_ziggeo images] getImageUrl:tokenOrKey]);
}

@end
