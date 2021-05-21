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

static RCTZVideoViewModule *_instance;

- (NSArray<NSString *> *)supportedEvents {
    _instance = self;

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
    return @[];
}

+ (void)setLastZiggeoPlayer:(ZiggeoPlayer *) player {
    lastZiggeoPlayer = player;
}

+ (RCTZVideoViewModule *)instance {
    return _instance;
}


RCT_EXPORT_METHOD(startPlaying) {
    if (lastZiggeoPlayer != nil) {
        [lastZiggeoPlayer play];
    }
}

@end
