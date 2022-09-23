#import "RCTContactUs.h"
#import <Foundation/Foundation.h>
#import <ZiggeoMediaSDK/ZiggeoMediaSDK.h>
#import <React/RCTLog.h>


@implementation RCTContactUs {
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
    m_ziggeo = [[Ziggeo alloc] initWithToken:_appToken Delegate:NULL];
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
    [m_ziggeo sendReport:logsList];
}

RCT_EXPORT_METHOD(sendEmailToSupport)
{
    RCTLogInfo(@"sendEmailToSupport");
    [m_ziggeo sendEmailToSupport];
}

@end

