#import <React/RCTLog.h>
#import "RCTZiggeo.h"


@implementation RCTZiggeo

RCT_EXPORT_MODULE();

static NSString *_appToken;
static NSString *_serverAuthToken;
static NSString *_clientAuthToken;

+ (NSString *)appToken {
    return _appToken;
}

RCT_EXPORT_METHOD(setAppToken:(NSString *)token) {
    _appToken = token;
}

+ (NSString *)serverAuthToken {
    return _serverAuthToken;
}

RCT_EXPORT_METHOD(setServerAuthToken:(NSString *)token) {
    _serverAuthToken = token;
}

+ (NSString *)clientAuthToken {
    return _clientAuthToken;
}

RCT_EXPORT_METHOD(setClientAuthToken:(NSString *)token) {
    _clientAuthToken = token;
}

- (NSArray<NSString *> *)supportedEvents {
    return @[
    ];
}

@end
