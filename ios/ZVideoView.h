#ifndef ZVideoView_h
#define ZVideoView_h

#import <UIKit/UIKit.h>
#import "RCTEventDispatcher.h"
#import <Ziggeo/Ziggeo.h>

@interface ZVideoView: UIView

@property (nonatomic, assign) NSString *style;

@property (nonatomic, assign) NSString *ref;

@property (nonatomic, assign) ZiggeoRecorder2 *recorder;

- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher NS_DESIGNATED_INITIALIZER;






- (void)retake;
- (void)upload:(NSURL*)fileToUpload;

@property (nonatomic) UIViewController<VideoPreviewProtocol>* videoPreview;
@property (nonatomic) bool coverSelectorEnabled;
@property (nonatomic) bool sendImmediately;
@property (nonatomic) bool cameraFlipButtonVisible;
@property (nonatomic) bool useLiveStreaming;
@property (nonatomic) bool controlsVisible;
@property (nonatomic) bool showFaceOutline;
//@property (nonatomic) bool showLightIndicatorproperty (nonatomic) bool showSoundIndicator;
@property (nonatomic) ZiggeoRecorderInterfaceConfig *interfaceConfig;
@property (nonatomic) UIImagePickerControllerCameraDevice cameraDevice;
@property (nonatomic) id<ZiggeoRecorder2Delegate> recorderDelegate;
@property (nonatomic) NSDictionary* extraArgsForCreateVideo;
@property (nonatomic) double maxRecordedDurationSeconds;
@property (nonatomic) double autostartRecordingAfterSeconds;
@property (nonatomic) double startDelay;
@property (nonatomic) AVLayerVideoGravity videoGravity;
//resolution
@property (nonatomic) int videoWidth;
@property (nonatomic) int videoHeight;
@property (nonatomic) RecordingQuality recordingQuality;
@property (nonatomic) int videoBitrate;
@property (nonatomic) int audioSampleRate;
@property (nonatomic) int audioBitrate;

-(id) initWithZiggeoApplication:(Ziggeo*)ziggeo;
-(id) initWithZiggeoApplication:(Ziggeo*)ziggeo videoToken:(NSString*)videoToken;


@end;

#endif /* ZCameraView_h */
