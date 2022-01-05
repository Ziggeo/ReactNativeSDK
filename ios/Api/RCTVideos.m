#import "RCTVideos.h"
#import <Foundation/Foundation.h>
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>


@interface VideosContext: NSObject<ZiggeoDelegate>

@property (strong, nonatomic) RCTPromiseResolveBlock resolveBlock;
@property (strong, nonatomic) RCTPromiseRejectBlock rejectBlock;
@property (strong, nonatomic) RCTVideos* videos;

@end;


@implementation VideosContext

- (void)resolve:(NSString *)token {
    if (_resolveBlock) 
        _resolveBlock(token);
    _resolveBlock = nil;
    _rejectBlock = nil;
    self.videos = nil;
}

- (void)reject:(NSString *)code message:(NSString *)message {
    if (_rejectBlock) 
        _rejectBlock(code, message, [NSError errorWithDomain:@"videos" code:0 userInfo:@{code:message}]);
    _resolveBlock = nil;
    _rejectBlock = nil;
    self.videos = nil;
}

@end;


@implementation RCTVideos {
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
    VideosContext *m_context = [[VideosContext alloc] init];
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
    [[m_ziggeo videos] index:map Callback:^(NSArray *jsonArray, NSError *error) {
        if (error == NULL) {
            resolve(jsonArray);
        } else {
            reject(@"ERR_VIDEOS", @"video index error", error);
        }
    }];
}

RCT_EXPORT_METHOD(destroy:(NSString *)tokenOrKey resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [[m_ziggeo videos] destroy:tokenOrKey Callback:^(NSDictionary *jsonObject, NSURLResponse *response, NSError *error) {
        if (error == NULL) {
            resolve(jsonObject);
        } else {
            reject(@"ERR_VIDEOS", @"video destroy error", error);
        }
    }];
}

RCT_EXPORT_METHOD(get:(NSString *)tokenOrKey resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [[m_ziggeo videos] get:tokenOrKey Callback:^(NSString *filePath) {
        resolve(filePath);
    }];
}

RCT_EXPORT_METHOD(create:(NSString *)file map:(NSDictionary *)map resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [[m_ziggeo videos] create:file Data:map Callback:^(NSDictionary *jsonObject, NSURLResponse *response, NSError *error) {
        if (error != NULL) {
            reject(@"ERR_VIDEOS", @"video create error", error);
        }
    } Progress:^(int totalBytesSent, int totalBytesExpectedToSend) {
    } ConfirmCallback:^(NSDictionary *jsonObject, NSURLResponse *response, NSError *error) {
        if (error == NULL) {
            resolve(jsonObject);
        } else {
            reject(@"ERR_VIDEOS", @"video create error", error);
        }
    }];
}

RCT_EXPORT_METHOD(update:(NSString *)model resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [[m_ziggeo videos] update:model ModelInJson:model Callback:^(NSDictionary *jsonObject, NSURLResponse *response, NSError *error) {
        if (error == NULL) {
            resolve(jsonObject);
        } else {
            reject(@"ERR_VIDEOS", @"video update error", error);
        }
    }];
}

RCT_EXPORT_METHOD(getImageUrl:(NSString *)tokenOrKey resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve([[m_ziggeo videos] getImageUrl:tokenOrKey]);
}

RCT_EXPORT_METHOD(getVideoUrl:(NSString *)tokenOrKey resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve([[m_ziggeo videos] getVideoUrl:tokenOrKey]);
}

@end
