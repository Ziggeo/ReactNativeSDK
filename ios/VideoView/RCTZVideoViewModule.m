#import <Foundation/Foundation.h>
#import <Ziggeo/Ziggeo.h>
#import <React/RCTEventEmitter.h>
#import "RCTZVideoViewModule.h"

@implementation RCTZVideoViewModule

RCT_EXPORT_MODULE();

//RCT_EXPORT_VIEW_PROPERTY(onPlaying, RCTBubblingEventBlock);
//RCT_EXPORT_VIEW_PROPERTY(onPaused, RCTBubblingEventBlock);
//RCT_EXPORT_VIEW_PROPERTY(onEnded, RCTBubblingEventBlock);
//RCT_EXPORT_VIEW_PROPERTY(onSeek, RCTBubblingEventBlock);
//RCT_EXPORT_VIEW_PROPERTY(onReadyToPlay, RCTBubblingEventBlock);

static ZiggeoPlayer *lastZiggeoPlayer;

- (NSArray<NSString *> *)supportedEvents {
    return @[
        @"Error",
        @"Playing",
        @"Paused",
        @"Ended",
        @"Seek",
        @"ReadyToPlay",
    ];
}

- (NSArray *) customDirectEventTypes {
    return @[
        @"onFrameChange"
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
