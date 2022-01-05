#import "RCTContactUs.h"
#import <Foundation/Foundation.h>
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>


@implementation RCTContactUs {
}

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents
{
    return @[
    ];
}

RCT_EXPORT_METHOD(sendReport:(NSArray *)logsList)
{
    RCTLogInfo(@"sendReport: %@", logsList);
}

RCT_EXPORT_METHOD(sendEmailToSupport:(NSString *)token)
{
    RCTLogInfo(@"sendEmailToSupport");
}

@end

