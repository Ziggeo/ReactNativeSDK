#include "RCTZiggeoCameraViewManager.h"

#import <Foundation/Foundation.h>

#import "RCTBridge.h"
#import "RCTZiggeoCameraView.h"
#import "../../ZigiOS-SDK/Ziggeo/Recorder2/ZiggeoRecorder2.h"
#import "../../ZigiOS-SDK/Ziggeo/Ziggeo.h"

#import <Foundation/Foundation.h>
#import "RCTZiggeoRecorder.h"
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>

@implementation RCTZiggeoCameraViewManager

RCT_EXPORT_MODULE();

RCT_EXPORT_VIEW_PROPERTY(style, NSString);

RCT_EXPORT_VIEW_PROPERTY(ref, NSString);

@synthesize bridge = _bridge;

- (UIView *)view {
    Ziggeo* m_ziggeo = [[Ziggeo alloc] initWithToken:self->_appToken];
    m_ziggeo.connect.serverAuthToken = self.serverAuthToken;
    m_ziggeo.connect.clientAuthToken = self.clientAuthToken;
    [m_ziggeo.config setRecorderCacheConfig:self.cacheConfig];

    ZiggeoRecorder2* recorder = [[ZiggeoRecorder2 alloc] initWithZiggeoApplication:m_ziggeo];
    /*
    recorder.coverSelectorEnabled = self->_coverSelectorEnabled;
    recorder.cameraFlipButtonVisible = self->_cameraFlipButtonVisible;
    recorder.cameraDevice = self->_camera;
    recorder.recorderDelegate = context;
    recorder.extraArgsForCreateVideo = self->_additionalRecordingParams;
    recorder.useLiveStreaming = self->_liveStreamingEnabled;
    recorder.recordingQuality = self->_quality;
    recorder.interfaceConfig = parseRecorderInterfaceConfig(self.interfaceConfig);
    recorder.autostartRecordingAfterSeconds = self.autostartRecordingAfter;
    recorder.startDelay = self.startDelay;
    if(self->_videoWidth != 0) recorder.videoWidth = (int)self.videoWidth;
    if(self->_videoHeight != 0) recorder.videoHeight = (int)self.videoHeight;
    if(self->_videoBitrate != 0) recorder.videoBitrate = (int)self.videoBitrate;
    if(self->_audioSampleRate != 0) recorder.audioSampleRate = (int)self.audioSampleRate;
    if(self->_audioBitrate != 0) recorder.audioBitrate = (int)self.audioBitrate;
    if(self->_additionalThemeParams)
    {
        if(recorder.extraArgsForCreateVideo) {
            NSMutableDictionary* merged = [[NSMutableDictionary alloc] initWithDictionary:recorder.extraArgsForCreateVideo];
            [merged addEntriesFromDictionary:self->_additionalThemeParams];
            recorder.extraArgsForCreateVideo = merged;
        }
        else recorder.extraArgsForCreateVideo = self->_additionalThemeParams;
    }
    recorder.maxRecordedDurationSeconds = self->_maxRecordingDuration;
    if(recorder.extraArgsForCreateVideo && ([@"true" isEqualToString:recorder.extraArgsForCreateVideo[@"hideRecorderControls"]] || [[recorder.extraArgsForCreateVideo valueForKey:@"hideRecorderControls"] boolValue] ))
    {
        recorder.controlsVisible = false;
    }
    */

    m_ziggeo.videos.delegate = context;

    RCTZiggeoCameraView *view = [[RCTZiggeoCameraView alloc] initWithEventDispatcher:self.bridge.eventDispatcher];

    UIView *recorderView = recorder.view;
    recorderView.recorder = recorder;

    [view addSubview:recorderView];

    recorderView.translatesAutoresizingMaskIntoConstraints = false;
    [view.leadingAnchor constraintEqualToAnchor:recorderView.leadingAnchor].isActive = true;
    [view.trailingAnchor constraintEqualToAnchor:recorderView.trailingAnchor].isActive = true;
    [view.topAnchor constraintEqualToAnchor:recorderView.topAnchor].isActive = true;
    [view.bottomAnchor constraintEqualToAnchor:recorderView.bottomAnchor].isActive = true;


    return view;
}

- (NSArray *) customDirectEventTypes {
    return @[
        @"onFrameChange"
    ];
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

@end;
