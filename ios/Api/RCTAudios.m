#import "RCTAudios.h"
#import <Foundation/Foundation.h>
#import <ZiggeoMediaSDK/ZiggeoMediaSDK.h>
#import <React/RCTLog.h>
#import "ZiggeoConstants.h"


@interface AudiosContext: NSObject

@property (strong, nonatomic) RCTPromiseResolveBlock resolveBlock;
@property (strong, nonatomic) RCTPromiseRejectBlock rejectBlock;
@property (strong, nonatomic) RCTAudios* audios;

@end;


@implementation AudiosContext

- (void)resolve:(NSString *)token {
    if (_resolveBlock) 
        _resolveBlock(token);
    _resolveBlock = nil;
    _rejectBlock = nil;
    self.audios = nil;
}

- (void)reject:(NSString *)code message:(NSString *)message {
    if (_rejectBlock) 
        _rejectBlock(code, message, [NSError errorWithDomain:@"audios" code:0 userInfo:@{code:message}]);
    _resolveBlock = nil;
    _rejectBlock = nil;
    self.audios = nil;
}

@end;


@implementation RCTAudios {
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
    AudiosContext *m_context = [[AudiosContext alloc] init];
    [ZiggeoConstants setAppToken:_appToken];
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
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[[ZiggeoConstants sharedZiggeoInstance] audios] index:map
                                                  Callback:^(NSArray *jsonArray, NSError *error) {
        if (error == NULL) {
            resolve(jsonArray);
        } else {
            reject(@"ERR_AUDIOS", @"audio index error", error);
        }
    }];
}

RCT_EXPORT_METHOD(destroy:(NSString *)tokenOrKey resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[[ZiggeoConstants sharedZiggeoInstance] audios] destroy:tokenOrKey
                                                    Callback:^(NSDictionary *jsonObject, NSURLResponse *response, NSError *error) {
        if (error == NULL) {
            resolve(jsonObject);
        } else {
            reject(@"ERR_AUDIOS", @"audio destroy error", error);
        }
    }];
}

RCT_EXPORT_METHOD(get:(NSString *)tokenOrKey resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[[ZiggeoConstants sharedZiggeoInstance] audios] get:tokenOrKey
                                                    Data:NULL
                                                Callback:^(ContentModel *content, NSURLResponse *response, NSError *error) {
        resolve(content);
    }];
}

RCT_EXPORT_METHOD(create:(NSString *)file map:(NSDictionary *)map resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[[ZiggeoConstants sharedZiggeoInstance] audios] create:file
                                                       Data:map
                                                   Callback:^(NSDictionary *jsonObject, NSURLResponse *response, NSError *error) {
        if (error != NULL) {
            reject(@"ERR_AUDIOS", @"audio create error", error);
        }
    } Progress:^(int totalBytesSent, int totalBytesExpectedToSend) {
    } ConfirmCallback:^(NSDictionary *jsonObject, NSURLResponse *response, NSError *error) {
        if (error == NULL) {
            resolve(jsonObject);
        } else {
            reject(@"ERR_AUDIOS", @"audio create error", error);
        }
    }];
}

RCT_EXPORT_METHOD(update:(NSString *)token map:(NSDictionary *)map resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[[ZiggeoConstants sharedZiggeoInstance] audios] update:token Data:map Callback:^(ContentModel *content, NSURLResponse *response, NSError *error) {
        if (error == NULL) {
            resolve(content);
        } else {
            reject(@"ERR_AUDIOS", @"audio update error", error);
        }
    }];
}

RCT_EXPORT_METHOD(source:(NSString *)tokenOrKey resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    resolve([[[ZiggeoConstants sharedZiggeoInstance] audios] getAudioUrl:tokenOrKey]);
}

RCT_EXPORT_METHOD(getAudioUrl:(NSString *)tokenOrKey resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    resolve([[[ZiggeoConstants sharedZiggeoInstance] audios] getAudioUrl:tokenOrKey]);
}

@end
