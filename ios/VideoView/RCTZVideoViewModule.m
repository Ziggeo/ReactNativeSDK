#import <Foundation/Foundation.h>
#import <Ziggeo/Ziggeo.h>
#import "RCTZVideoViewModule.h"

@implementation RCTZVideoViewModule

RCT_EXPORT_MODULE();

static ZiggeoPlayer *lastZiggeoPlayer;

- (NSArray<NSString *> *)supportedEvents
{
    return @[
    ];
}

+ (void)setLastZiggeoPlayer:(ZiggeoPlayer *) player {
    lastZiggeoPlayer = player;
}

RCT_EXPORT_METHOD(startPlaying) {
    if (lastZiggeoPlayer != nil) {
        [lastZiggeoPlayer play];
    }
}

@end
