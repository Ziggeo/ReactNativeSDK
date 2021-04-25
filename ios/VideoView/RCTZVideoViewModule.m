#import <Foundation/Foundation.h>
#import <Ziggeo/Ziggeo.h>
#import "RCTZVideoViewModule.h"

@implementation RCTZVideoViewModule

RCT_EXPORT_MODULE();

static ZiggeoPlayer *lastZiggeoPlayer;

RCT_EXPORT_METHOD(startRecording:(NSString *)path maxDuration:(int)maxDuration) {
    if (lastZiggeoRecorder != nil) {
        lastZiggeoRecorder.maxRecordedDurationSeconds = (double)maxDuration;
        [lastZiggeoRecorder startRecordingToFile:path];
    }
}

RCT_EXPORT_METHOD(stopRecording) {
    if (lastZiggeoRecorder != nil) {
        [lastZiggeoRecorder stopRecording];
    }
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[
    ];
}

+ (void)setLastZiggeoRecorder:(ZiggeoRecorder2 *) recorder {
    lastZiggeoRecorder = recorder;
}


@end
