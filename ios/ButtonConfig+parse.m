#import "ButtonConfig+parse.h"

@implementation ButtonConfig (parse)

- (void)parse:(NSDictionary *)dictionary {
    id value;

    value = dictionary[@"imagePath"];
    if (value && [value isKindOfClass:[NSString class]]) {
        self.imagePath = (NSString *)value;
    }

    value = dictionary[@"selectedImagePath"];
    if (value && [value isKindOfClass:[NSString class]]) {
        self.selectedImagePath = (NSString *)value;
    }

    value = dictionary[@"scale"];
    if (value && [value isKindOfClass:[NSNumber class]]) {
        CGFloat cgf = [((NSNumber *)value) doubleValue];
        self.scale = cgf;
    }

    value = dictionary[@"width"];
    if (value && [value isKindOfClass:[NSNumber class]]) {
        CGFloat cgf = [((NSNumber *)value) doubleValue];
        self.width = cgf;
    }

    value = dictionary[@"height"];
    if (value && [value isKindOfClass:[NSNumber class]]) {
        CGFloat cgf = [((NSNumber *)value) doubleValue];
        self.height = cgf;
    }
}

@end