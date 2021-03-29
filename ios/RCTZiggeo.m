#import "RCTZiggeo.h"


@implementation RCTZiggeo

static NSString *_appToken;
static NSString *_serverAuthToken;
static NSString *_clientAuthToken;

+ (NSString *)appToken {
    return _appToken;
}

+ (void)setAppToken:(NSString *)token {
    _appToken = token;
}

+ (NSString *)serverAuthToken {
    return _serverAuthToken;
}

+ (void)setServerAuthToken:(NSString *)token {
    _serverAuthToken = token;
}

+ (NSString *)clientAuthToken {
    return _clientAuthToken;
}

+ (void)setClientAuthToken:(NSString *)token {
    _clientAuthToken = token;
}

@end