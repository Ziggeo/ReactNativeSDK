#import "ZiggeoConstants.h"

@implementation ZiggeoConstants

+ (NSString *)getStringFromEvent:(ZIGGEO_EVENTS)event {
    NSArray *typeArray = [[NSArray alloc] initWithObjects:kZiggeoEventsArray];
    return [typeArray objectAtIndex:event];
}

@end
