#import "ZiggeoConstants.h"

@implementation ZiggeoConstants

+ (NSString *)getStringFromEvent:(ZIGGEO_EVENTS)event {
    NSArray *typeArray = [[NSArray alloc] initWithObjects:kZiggeoEventsArray];
    return [typeArray objectAtIndex:event];
}

+ (NSString *)getStringFromConstants:(ZIGGEO_CONSTANTS)constants {
    NSArray *typeArray = [[NSArray alloc] initWithObjects:kZiggeoConstantsArray];
    return [typeArray objectAtIndex:constants];
}

@end
