#import "RCTContactUs.h"
#import <Foundation/Foundation.h>
#import <ZiggeoMediaSDK/ZiggeoMediaSDK.h>
#import <React/RCTLog.h>
#import "ZiggeoConstants.h"

@implementation RCTContactUs {
    
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


RCT_EXPORT_METHOD(sendReport:(NSArray *)logsList)
{
    RCTLogInfo(@"sendReport: %@", logsList);
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] sendReport:logsList];
}

RCT_EXPORT_METHOD(sendEmailToSupport)
{
    RCTLogInfo(@"sendEmailToSupport");
    if ([ZiggeoConstants sharedZiggeoInstance] == nil) return;
    [[ZiggeoConstants sharedZiggeoInstance] sendEmailToSupport];
}

@end

