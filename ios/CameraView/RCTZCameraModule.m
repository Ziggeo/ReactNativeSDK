#import <Foundation/Foundation.h>
#import <Ziggeo/Ziggeo.h>
#import "RCTZCameraModule.h"

@implementation RCTZCameraModule

RCT_EXPORT_MODULE();

static ZiggeoRecorder *lastZiggeoRecorder;

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

+ (void)setLastZiggeoRecorder:(ZiggeoRecorder *) recorder {
    lastZiggeoRecorder = recorder;
}


@end
