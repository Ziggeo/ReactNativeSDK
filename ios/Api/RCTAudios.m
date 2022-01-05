#import "RCTAudios.h"
#import <Foundation/Foundation.h>
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>


@interface AudiosContext: NSObject<ZiggeoDelegate>

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
    AudiosContext *m_context = [[AudiosContext alloc] init];
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
    [[m_ziggeo audios] index:map Callback:^(NSArray *jsonArray, NSError *error) {
        if (error == NULL) {
            resolve(jsonArray);
        } else {
            reject(@"ERR_AUDIOS", @"audio index error", error);
        }
    }];
}

RCT_EXPORT_METHOD(destroy:(NSString *)tokenOrKey resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [[m_ziggeo audios] destroy:tokenOrKey Callback:^(NSDictionary *jsonObject, NSURLResponse *response, NSError *error) {
        if (error == NULL) {
            resolve(jsonObject);
        } else {
            reject(@"ERR_AUDIOS", @"audio destroy error", error);
        }
    }];
}

RCT_EXPORT_METHOD(get:(NSString *)tokenOrKey resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [[m_ziggeo audios] get:tokenOrKey Callback:^(NSString *filePath) {
        resolve(filePath);
    }];
}

RCT_EXPORT_METHOD(create:(NSString *)file map:(NSDictionary *)map resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [[m_ziggeo audios] create:file Data:map Callback:^(NSDictionary *jsonObject, NSURLResponse *response, NSError *error) {
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

RCT_EXPORT_METHOD(update:(NSString *)model resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [[m_ziggeo audios] update:model ModelInJson:model Callback:^(NSDictionary *jsonObject, NSURLResponse *response, NSError *error) {
        if (error == NULL) {
            resolve(jsonObject);
        } else {
            reject(@"ERR_AUDIOS", @"audio update error", error);
        }
    }];
}

RCT_EXPORT_METHOD(source:(NSString *)tokenOrKey resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve([[m_ziggeo audios] getAudioUrl:tokenOrKey]);
}

RCT_EXPORT_METHOD(getAudioUrl:(NSString *)tokenOrKey resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve([[m_ziggeo audios] getAudioUrl:tokenOrKey]);
}

@end
