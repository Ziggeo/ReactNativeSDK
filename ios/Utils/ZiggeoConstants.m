#import "ZiggeoConstants.h"

@implementation ZiggeoConstants

+ (NSString *)getEventString:(ZIGGEO_EVENTS)event {
    NSArray *typeArray = [[NSArray alloc] initWithObjects:kZiggeoEventsArray];
    return [typeArray objectAtIndex:event];
}

+ (NSString *)getKeyString:(Ziggeo_Key_Type)key {
    NSArray *typeArray = [[NSArray alloc] initWithObjects:kZiggeoKeysArray];
    return [typeArray objectAtIndex:key];
}

@end
