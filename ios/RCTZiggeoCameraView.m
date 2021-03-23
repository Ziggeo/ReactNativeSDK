#import <Foundation/Foundation.h>
#import <Ziggeo/Ziggeo.h>

#import "RCTBridgeModule.h"
#import "RCTEventDispatcher.h"
#import "UIView+React.h"


@implementation RCTZiggeoCameraView : UIView {
    RCTEventDispatcher *_eventDispatcher;

    dispatch_block_t cleanup;
    NSString *m_videoToken;
    NSTimer *durationUpdateTimer;
    bool _showLightIndicator, _showFaceOutline, _showAudioIndicator;
    AVLayerVideoGravity _videoGravity;
    int delayCountdownCounter;
}

- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher {
    if ((self = [super init])) {
        _eventDispatcher = eventDispatcher;
    }

    return self;
}


- (void)setupMetadataOutput {
    self.metadataOutput = [AVCaptureMetadataOutput new];
    if (![self.session canAddOutput:self.metadataOutput]) {
        return;
    }

    [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [self.session addOutput:self.metadataOutput];

    if (![self.metadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeFace]) {
        return;
    }

    self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
}

- (void)setupLiveStreaming {
    self.audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    self.audioDataQueue = dispatch_queue_create("audio queue", DISPATCH_QUEUE_SERIAL);
    [self.audioDataOutput setSampleBufferDelegate:self queue:_audioDataQueue];
    [self.session addOutput:self.audioDataOutput];
    [self.ziggeo log:@"live audio capture output added"];

    self.videoDataQueue = dispatch_queue_create("video queue", DISPATCH_QUEUE_SERIAL);
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.videoDataOutput.alwaysDiscardsLateVideoFrames = true;
    [self.videoDataOutput setSampleBufferDelegate:self queue:_videoDataQueue];
    [self.session addOutput:self.videoDataOutput];
    AVCaptureConnection *connection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection.isVideoStabilizationSupported) {
        connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
    [self.ziggeo log:@"live video capture output added"];

    [self createVideoEncoder];
    [self createAudioEncoder];
}

- (int)videoWidth {
    switch (self.currentOrientation) {
        case AVCaptureVideoOrientationLandscapeLeft:
        case AVCaptureVideoOrientationLandscapeRight:
            return _videoWidth;
        case AVCaptureVideoOrientationPortrait:
        case AVCaptureVideoOrientationPortraitUpsideDown:
            return _videoHeight;
    }
}

- (int)videoHeight {
    switch (self.currentOrientation) {
        case AVCaptureVideoOrientationLandscapeLeft:
        case AVCaptureVideoOrientationLandscapeRight:
            return _videoHeight;
        case AVCaptureVideoOrientationPortrait:
        case AVCaptureVideoOrientationPortraitUpsideDown:
            return _videoWidth;
    }
}

- (void)setRecordingQuality:(RecordingQuality)recordingQuality {
    _recordingQuality = recordingQuality;
    switch (recordingQuality) {
        case LowQuality:
            self.videoBitrate = 1500 * 1024;
            self.videoWidth = 1024;
            self.videoHeight = 576;
            break;
        case MediumQuality:
            self.videoBitrate = 2500 * 1024;
            self.videoWidth = 1280;
            self.videoHeight = 720;
            break;
        case HighestQuality:
            self.videoBitrate = 5000 * 1024;
            self.videoWidth = 1920;
            self.videoHeight = 1080;
            break;
    }
}

- (void)setupDataOutputs {
    self.audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    [self.audioDataOutput setSampleBufferDelegate:self queue:_sessionQueue];
    [self.session addOutput:self.audioDataOutput];
    [self.ziggeo log:@"asset audio capture output added"];

    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.videoDataOutput.alwaysDiscardsLateVideoFrames = true;
    [self.videoDataOutput setSampleBufferDelegate:self queue:_sessionQueue];
    [self.session addOutput:self.videoDataOutput];
    AVCaptureConnection *connection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection != nil) {
        if (connection.isVideoStabilizationSupported) {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
        connection.videoMirrored = (self.cameraDevice == UIImagePickerControllerCameraDeviceFront);
    }

    [self.ziggeo log:@"asset video capture output added"];
}

- (NSString *)setupAssetWriter {
    [self resetVideoOrientation];
    NSString *outputFileName = [NSProcessInfo processInfo].globallyUniqueString;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *outputFilePath = [documentsDirectory stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"mp4"]];
    NSLog(@"recording started with path: %@", outputFilePath);
    NSError *error = nil;
    _movieAssetWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:outputFilePath] fileType:AVFileTypeMPEG4 error:&error];
    if (error != nil) {
        NSLog(@"asset writer error: %@", error);
    }

    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
            [NSNumber numberWithFloat:self.audioSampleRate], AVSampleRateKey,
            [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
            [NSNumber numberWithInt:self.audioBitrate], AVEncoderBitRateKey,
            [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
                    nil];
    _movieAssetWriterAudioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio
                                                                 outputSettings:outputSettings];
    [_movieAssetWriterAudioInput setExpectsMediaDataInRealTime:YES];
    [_movieAssetWriter addInput:_movieAssetWriterAudioInput];


    NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithDouble:self.videoBitrate], AVVideoAverageBitRateKey,
                    nil];

    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
            AVVideoCodecH264, AVVideoCodecKey,
            [NSNumber numberWithInt:self.videoWidth], AVVideoWidthKey,
            [NSNumber numberWithInt:self.videoHeight], AVVideoHeightKey,
            videoCompressionProps, AVVideoCompressionPropertiesKey,
                    nil];


    _movieAssetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    [_movieAssetWriterVideoInput setExpectsMediaDataInRealTime:YES];
    if ([_movieAssetWriter canAddInput:_movieAssetWriterVideoInput]) {
        [_movieAssetWriter addInput:_movieAssetWriterVideoInput];
        NSLog(@"video input successfully added");
    } else {
        NSLog(@"video input can't be added");
    }

//    AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;

    return outputFilePath;
}

- (void)setControlsVisible:(bool)controlsVisible {
    _controlsVisible = controlsVisible;
    if (self.controlsView != nil) self.controlsView.hidden = !controlsVisible;
    if (!controlsVisible) {
        self.sendImmediately = true;
        if (self.autostartRecordingAfterSeconds <= 0) {
            self.autostartRecordingAfterSeconds = 0.5;
        }
        if (self.maxRecordedDurationSeconds <= 0) {
            self.maxRecordedDurationSeconds = 30;
        }
    }
}

- (void)createVideoEncoder {
    self.videoEncoder = [[H264Encoder alloc] initWithWidth:self.videoWidth height:self.videoHeight bitrate:self.videoBitrate framerate:30];
    if (self.videoEncoder != nil) {
        self.videoEncoder.delegate = self;
        [self.ziggeo log:@"video encoder configured"];
    }
}

- (void)createAudioEncoder {
    self.audioEncoder = [[AACEncoder alloc] initWithSampleRate:22050 channels:2 bitrate:64000];
    if (self.audioEncoder != nil) {
        self.audioEncoder.delegate = self;
        [self.ziggeo log:@"audio encoder configure"];
    }
}

- (void)stopStreaming {
    _streamingNow = false;
    if (self.liveStreamer != nil) {
        [self.liveStreamer stop];
        self.liveStreamer = nil;

        if (_videoToken && _streamToken) {
            [self.ziggeo.videos recorderSubmitWithVideoToken:_videoToken streamToken:_streamToken data:nil callback:^(NSDictionary *jsonObject, NSURLResponse *response, NSError *error) {
                if (self.ziggeo.videos.delegate != nil) {
                    [self.ziggeo.videos.delegate videoUploadCompleteForPath:@"live" token:_videoToken withResponse:response error:error json:jsonObject];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
            _videoToken = nil;
            _streamToken = nil;
        }
    }
}

- (void)startStreaming {
    if (!_streamingNow) {
        [self.ziggeo.videos createLiveVideoWithData:self.extraArgsForCreateVideo callback:^(NSDictionary *jsonObject, NSURLResponse *response, NSError *error) {
            [self.ziggeo log:[NSString stringWithFormat:@"video created with error = %@, response = %@", error, jsonObject]];
            if (!error) {
                NSDictionary *videoObj = [jsonObject objectForKey:@"video"];
                if (videoObj) _videoToken = [videoObj objectForKey:@"token"];
                NSDictionary *streamObj = [jsonObject objectForKey:@"stream"];
                if (streamObj) _streamToken = [streamObj objectForKey:@"token"];
                if (_videoToken && _streamToken) {
                    _streamingNow = true;
                    NSString *targetAddress = [NSString stringWithFormat:@"%@/", self.ziggeo.config.wowza_url];
                    NSString *streamAddress = [NSString stringWithFormat:@"applications/%@/videos/%@/streams/%@/video.mp4", self.ziggeo.token, _videoToken, _streamToken];
                    //NSString* targetAddress = [NSString stringWithFormat:@"%@/applications/%@/videos/%@/streams/%@/", self.ziggeo.config.wowza_url, self.ziggeo.token, _videoToken, _streamToken];
                    //NSString* streamAddress = @"video.mp4";
                    if (targetAddress == nil || [targetAddress isEqual:@""]) {
                        _streamingNow = false;
                        [self onError:@"no target address specified for the live streaming"];
                    } else {
                        self.liveStreamer = [[LiveStreamer alloc] initWithTargetAddress:targetAddress streamName:streamAddress];
                        if (self.liveStreamer != nil) {
                            self.liveStreamer.delegate = self;
                        } else {
                            _streamingNow = false;
                            [self onError:@"failed to start streaming"];
                        }
                    }
                }
            } else [self onError:error.description];
        }];
    }
}

- (void)toggleStreaming {
    [self updateUIRecordingStreamingStartingStopping];
    if (!_streamingNow) {
        self.firstSampleRendered = false;
        [self resetVideoOrientation];
        [self startStreaming];
    } else [self stopStreaming];
}

- (void)onPublishStart {
    [self.ziggeo log:@"live streaming successfully started"];
    [self updateUIRecordingStreamingStarted];
}

- (void)onPublishStop {
    [self.ziggeo log:@"live streamer stopped"];
    self.liveStreamer = nil;
    [self updateUIRecordingStreamingComplete];
}

- (void)onError:(NSString *)description {
    [self.ziggeo logError:[NSString stringWithFormat:@"Live streamer error: %@", description]];
    if (self.liveStreamer != nil) {
        [self stopStreaming];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:description preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Alert OK button") style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    });
    [self updateUIRecordingStreamingComplete];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onCloseButtonTap:(id)sender {
    [self.ziggeo log:@"closing recorder"];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.ziggeo log:@"calling recorder callback"];
        if (self.recorderDelegate) {
            if ([self.recorderDelegate respondsToSelector:@selector(ziggeoRecorderDidCancel)]) {
                [self.recorderDelegate ziggeoRecorderDidCancel];
                [self.ziggeo log:@"recorder callback called"];
            } else [self.ziggeo log:@"recorder delegate is not responding to recorder did cancel selector"];
        } else [self.ziggeo log:@"recorder delegate is null"];
    }];
}

- (BOOL)shouldAutorotate {
    // Disable autorotation of the interface when recording is in progress.
    return !(self.movieAssetWriter != nil && self.movieAssetWriter.status == AVAssetWriterStatusWriting);
    //return ! self.movieFileOutput.isRecording;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    // Note that the app delegate controls the device orientation notifications required to use the device orientation.
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsPortrait(deviceOrientation) || UIDeviceOrientationIsLandscape(deviceOrientation)) {
        self.currentOrientation = (AVCaptureVideoOrientation) deviceOrientation;
        [self resetVideoOrientation];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    dispatch_async(dispatch_get_main_queue(), ^{
        self.previewView.layer.opacity = 0.0;
        self.recordingDurationLabel.text = @"00:00";
        self.controlsView.hidden = !self.controlsVisible;
    });

    dispatch_async(self.sessionQueue, ^{
        switch (self.setupResult) {
            case AVCamSetupResultSuccess: {
                // Only setup observers and start the session running if setup succeeded.
                [self addObservers];
                [self.session startRunning];
                self.sessionRunning = self.session.isRunning;
                if (self.autostartRecordingAfterSeconds > 0) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (_autostartRecordingAfterSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (self.autostartEnabled) {
                            [self toggleMovieRecording:nil];
                        }
                    });
                }
                break;
            }
            case AVCamSetupResultCameraNotAuthorized: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *message = NSLocalizedString(@"Ziggeo recorder doesn't have permission to use the camera, please change privacy settings", @"Alert message when the user has denied access to the camera");
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Ziggeo" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Alert OK button") style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    // Provide quick access to Settings.
                    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", @"Alert button to open Settings") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }];
                    [alertController addAction:settingsAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                });
                break;
            }
            case AVCamSetupResultSessionConfigurationFailed: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *message = NSLocalizedString(@"Unable to capture media", @"Alert message when something goes wrong during capture session configuration");
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Ziggeo" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Alert OK button") style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                });
                break;
            }
        }
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self resetVideoOrientation];
}

- (void)updateDuration {
    dispatch_async(dispatch_get_main_queue(), ^{
        double durationSeconds = self.duration;
        if (self.recorderDelegate != nil && [self.recorderDelegate respondsToSelector:@selector(ziggeoRecorderCurrentRecordedDurationSeconds:)]) {
            [self.recorderDelegate ziggeoRecorderCurrentRecordedDurationSeconds:durationSeconds];
        }
        int minutes = (int) durationSeconds / 60;
        int seconds = ((int) (durationSeconds + 0.4)) % 60;

        NSString *currentDurationSeconds = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
        if (self.maxRecordedDurationSeconds > 0) {
            double remainingDuration = self.maxRecordedDurationSeconds - durationSeconds;
            if (remainingDuration < 0) remainingDuration = 0;
            int minutesMax = (int) (remainingDuration) / 60;
            int secondsMax = (int) (remainingDuration + 0.4) % 60;
            NSString *maxDurationStr = [NSString stringWithFormat:@"%02d:%02d", minutesMax, secondsMax];
            currentDurationSeconds = maxDurationStr;
        }
        self.recordingDurationLabel.text = currentDurationSeconds;
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    _autostartEnabled = false;
    dispatch_async(self.sessionQueue, ^{
        if (self.setupResult == AVCamSetupResultSuccess) {
            [self.session stopRunning];
            [self removeObservers];
        }
    });

    [super viewDidDisappear:animated];
}

- (void)addObservers {
    [self.session addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:SessionRunningContext];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.videoDeviceInput.device];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:self.session];
    // A session can only run when the app is full screen. It will be interrupted in a multi-app layout, introduced in iOS 9,
    // see also the documentation of AVCaptureSessionInterruptionReason. Add observers to handle these session interruptions
    // and show a preview is paused message. See the documentation of AVCaptureSessionWasInterruptedNotification for other
    // interruption reasons.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:self.session];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInterruptionEnded:) name:AVCaptureSessionInterruptionEndedNotification object:self.session];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self.session removeObserver:self forKeyPath:@"running" context:SessionRunningContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == CapturingStillImageContext) {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];

        if (isCapturingStillImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.previewView.layer.opacity = 0.0;
                [UIView animateWithDuration:0.25 animations:^{
                    self.previewView.layer.opacity = 1.0;
                }];
            });
        }
    } else if (context == SessionRunningContext) {
        BOOL isSessionRunning = [change[NSKeyValueChangeNewKey] boolValue];

        dispatch_async(dispatch_get_main_queue(), ^{
            // Only enable the ability to change camera if the device has more than one camera.
            self.cameraButton.enabled = isSessionRunning && ([AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count > 1);
            self.recordButton.enabled = isSessionRunning;

            dispatch_async(dispatch_get_main_queue(), ^{
                self.previewView.layer.opacity = 0.0;
                if (isSessionRunning) {
                    [UIView animateWithDuration:0.25 animations:^{
                        self.previewView.layer.opacity = 1.0;
                    }];
                }
            });
        });
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (IBAction)changeCamera:(id)sender {
    self.cameraButton.enabled = NO;
    self.recordButton.enabled = NO;

    dispatch_async(self.sessionQueue, ^{
        AVCaptureDevice *currentVideoDevice = self.videoDeviceInput.device;
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = currentVideoDevice.position;
        switch (currentPosition) {
            case AVCaptureDevicePositionUnspecified:
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
        }

        AVCaptureDevice *videoDevice = [ZiggeoRecorder2 deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];

        [self.session beginConfiguration];

        // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
        [self.session removeInput:self.videoDeviceInput];

        if ([self.session canAddInput:videoDeviceInput]) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];

            [ZiggeoRecorder2 setFlashMode:AVCaptureFlashModeAuto forDevice:videoDevice];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];

            [self.session addInput:videoDeviceInput];
            self.videoDeviceInput = videoDeviceInput;
        } else {
            [self.session addInput:self.videoDeviceInput];
        }

        AVCaptureConnection *connection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
        if (connection.isVideoStabilizationSupported) {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }

        connection.videoMirrored = (preferredPosition == AVCaptureDevicePositionFront);

        [self.session commitConfiguration];

        dispatch_async(dispatch_get_main_queue(), ^{
            self.cameraButton.enabled = YES;
            self.recordButton.enabled = YES;
        });
    });
}

- (void)compressedVideoDataReceived:(CMSampleBufferRef)sampleBuffer {
    if (self.liveStreamer != nil && _streamingNow) {
        [self.liveStreamer putVideoSample:sampleBuffer];
    }
}

- (void)compressedAudioDataReceived:(NSData *)data asc:(NSData *)asc pts:(CMTime)pts {
    if (self.liveStreamer != nil && _streamingNow) {
        [self.liveStreamer putAudioSample:data asc:asc pts:pts];
    }
}

- (void)audioMeter:(CMSampleBufferRef)sampleBuffer {
    AudioBufferList audioBufferList;
    CMBlockBufferRef blockBuffer;

    CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
            sampleBuffer,
            NULL,
            &audioBufferList,
            sizeof(audioBufferList),
            NULL,
            NULL,
            0,
            &blockBuffer);
    double sum = 0;
    int count = 0;
    for (int i = 0; i < audioBufferList.mNumberBuffers; i++) {
        AudioBuffer buffer = audioBufferList.mBuffers[i];
        for (size_t j = 0; j < buffer.mDataByteSize / 2; j++) {
            sum += abs(((short *) buffer.mData)[j]);
            count++;
        }
    }
    if (count > 0) sum /= count;
    double audioLevel = sum / 10000;
    if (audioLevel > 1) audioLevel = 1;
    CFRelease(blockBuffer);
    self.audioLevelView.currentLevel = audioLevel;
    if (self.recorderDelegate) {
        if ([self.recorderDelegate respondsToSelector:@selector(audioMeter:)]) {
            [self.recorderDelegate audioMeter:audioLevel];
        }
    }
}

- (void)luxMeter:(CMSampleBufferRef)sampleBuffer {

    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,
            sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc]
            initWithDictionary:(__bridge NSDictionary *) metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata
            objectForKey:(NSString *) kCGImagePropertyExifDictionary] mutableCopy];
    double brightness = [[exifMetadata
            objectForKey:(NSString *) kCGImagePropertyExifBrightnessValue] floatValue];
    self.luxMeterView.currentLuminousity = brightness;
    if (self.recorderDelegate) {
        if ([self.recorderDelegate respondsToSelector:@selector(luxMeter:)]) {
            [self.recorderDelegate luxMeter:brightness];
        }
    }
}

- (void)drawFaces {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.faceOutlineView.isHidden) {
            [self.faceOutlineView setNeedsDisplay];
        }
    });
}

- (void)setShowFaceOutline:(bool)showFaceOutline {
    _showFaceOutline = showFaceOutline;
    if (self.faceOutlineView != nil) self.faceOutlineView.hidden = !showFaceOutline;
}

- (void)setShowLightIndicator:(bool)showLightIndicator {
    _showLightIndicator = showLightIndicator;
    if (self.luxMeterView != nil) self.luxMeterView.hidden = !showLightIndicator;
}

- (void)setShowSoundIndicator:(bool)showSoundIndicator {
    _showAudioIndicator = showSoundIndicator;
    if (self.audioLevelView != nil) self.audioLevelView.hidden = !showSoundIndicator;
}

- (bool)showSoundIndicator {
    return _showAudioIndicator;
}

- (bool)showLightIndicator {
    return _showLightIndicator;
}

- (bool)showFaceOutline {
    return _showFaceOutline;
}

- (AVLayerVideoGravity)videoGravity {
    return _videoGravity;
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    _videoGravity = videoGravity;
    if (self.previewView != nil && self.previewView.layer != nil) {
        AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *) self.previewView.layer;
        previewLayer.videoGravity = _videoGravity;
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    if (captureOutput == _videoDataOutput) {
        [self luxMeter:sampleBuffer];
        [self drawFaces];
        double currentTimestamp = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer));
        if (_useLiveStreaming) {
            CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            if (pixelBuffer != nil && _videoEncoder != nil) {
                [self.videoEncoder putCVPixelBuffer:pixelBuffer withTimestamp:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
            }
            if (!self.firstSampleRendered) {
                self.firstSampleTimestamp = currentTimestamp;
                self.firstSampleRendered = true;
            }
            self.duration = (currentTimestamp - self.firstSampleTimestamp);
        } else {
            if (!self.durationExceeded) {

                if (_movieAssetWriter != nil) {
                    if (_movieAssetWriter.status == AVAssetWriterStatusUnknown) {
                        [_movieAssetWriter startWriting];
                        [_movieAssetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
                        NSLog(@"session started with time: %f", currentTimestamp);
                        self.firstSampleTimestamp = currentTimestamp;
                    }

                    if (_movieAssetWriter.status == AVAssetWriterStatusFailed) {
                        NSLog(@"movie asset writer failed");
                    } else {
                        if (_movieAssetWriterVideoInput != nil && _movieAssetWriterVideoInput.isReadyForMoreMediaData) {
                            if (![_movieAssetWriterVideoInput appendSampleBuffer:sampleBuffer]) {
                                NSLog(@"video sample buffer writing error");
                            } else {
                                //NSLog(@"video sample appended with time %f", CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)));

                                self.firstSampleRendered = true;
                            }
                            if (self.maxRecordedDurationSeconds > 0 && fabs(currentTimestamp - self.firstSampleTimestamp) >= self.maxRecordedDurationSeconds) {
                                self.durationExceeded = true;
                                [self toggleMovieRecording:nil];
                            }
                        }
                    }
                }
                self.duration = (currentTimestamp - self.firstSampleTimestamp);
            }
        }
    } else if (captureOutput == _audioDataOutput) {
        [self audioMeter:sampleBuffer];
        if (_useLiveStreaming) {
            if (_audioEncoder != nil) {
                [self.audioEncoder putCMSampleBuffer:sampleBuffer];
            }
        } else {
            if (self.firstSampleRendered && _movieAssetWriterAudioInput != nil && _movieAssetWriterAudioInput.isReadyForMoreMediaData) {
                if (![_movieAssetWriterAudioInput appendSampleBuffer:sampleBuffer]) {
                    NSLog(@"audio sample buffer writing error");
                }
                //else NSLog(@"audio sample appended");
            }
        }
    }
}

- (void)   captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
          fromConnection:(AVCaptureConnection *)c {
    AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *) self.previewView.layer;
    for (AVMetadataObject *object in metadataObjects) {
        if ([[object type] isEqual:AVMetadataObjectTypeFace]) {
            AVMetadataFaceObject * face = (AVMetadataFaceObject * )
            [previewLayer transformedMetadataObjectForMetadataObject:object];//(AVMetadataFaceObject*)object;
            CGRect faceRectangle = [face bounds];
            NSInteger faceID = [face faceID];

            if (self.recorderDelegate) {
                if ([self.recorderDelegate respondsToSelector:@selector(faceDetected:rect:)]) {
                    [self.recorderDelegate faceDetected:(int) faceID rect:faceRectangle];
                }
            }
            [self.faceOutlineView addFace:(int) faceID rect:faceRectangle];
        }
    }
}


- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *) self.previewView.layer captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (void)subjectAreaDidChange:(NSNotification *)notification {
    CGPoint devicePoint = CGPointMake(0.5, 0.5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

- (void)sessionRuntimeError:(NSNotification *)notification {
    NSError *error = notification.userInfo[AVCaptureSessionErrorKey];
    [self.ziggeo logError:[NSString stringWithFormat:@"Capture session runtime error: %@", error]];

    // Automatically try to restart the session running if media services were reset and the last start running succeeded.
    // Otherwise, enable the user to try to resume the session running.
    if (error.code == AVErrorMediaServicesWereReset) {
        dispatch_async(self.sessionQueue, ^{
            if (self.isSessionRunning) {
                [self.session startRunning];
                self.sessionRunning = self.session.isRunning;
            } else {
//                dispatch_async( dispatch_get_main_queue(), ^{
//                    self.resumeButton.hidden = NO;
//                } );
            }
        });
    }
//    else {
//        self.resumeButton.hidden = NO;
//    }
}

- (void)sessionWasInterrupted:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.previewView.layer.opacity = 0.0;
    });

    // In some scenarios we want to enable the user to resume the session running.
    // For example, if music playback is initiated via control center while using AVCam,
    // then the user can let AVCam resume the session running, which will stop music playback.
    // Note that stopping music playback in control center will not automatically resume the session running.
    // Also note that it is not always possible to resume, see -[resumeInterruptedSession:].
    BOOL showResumeButton = NO;

    // In iOS 9 and later, the userInfo dictionary contains information on why the session was interrupted.
    if (&AVCaptureSessionInterruptionReasonKey) {
        AVCaptureSessionInterruptionReason reason = [notification.userInfo[AVCaptureSessionInterruptionReasonKey] integerValue];
        [self.ziggeo log:[NSString stringWithFormat:@"Capture session was interrupted with reason %ld", (long) reason]];

        if (reason == AVCaptureSessionInterruptionReasonAudioDeviceInUseByAnotherClient ||
                reason == AVCaptureSessionInterruptionReasonVideoDeviceInUseByAnotherClient) {
            showResumeButton = YES;
        } else if (reason == AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableWithMultipleForegroundApps) {
            // Simply fade-in a label to inform the user that the camera is unavailable.
            self.cameraUnavailableLabel.hidden = NO;
            self.cameraUnavailableLabel.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^{
                self.cameraUnavailableLabel.alpha = 1.0;
            }];
        }
    } else {
        [self.ziggeo log:@"Capture session was interrupted"];
        showResumeButton = ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive);
    }

    if (showResumeButton) {
        // Simply fade-in a button to enable the user to try to resume the session running.
//        self.resumeButton.hidden = NO;
//        self.resumeButton.alpha = 0.0;
//        [UIView animateWithDuration:0.25 animations:^{
//            self.resumeButton.alpha = 1.0;
//        }];
    }
}

- (void)sessionInterruptionEnded:(NSNotification *)notification {
    [UIView animateWithDuration:0.25 animations:^{
        self.previewView.layer.opacity = 1.0;
    }];

    [self.ziggeo log:@"Capture session interruption ended"];

//    if ( ! self.resumeButton.hidden ) {
//        [UIView animateWithDuration:0.25 animations:^{
//            self.resumeButton.alpha = 0.0;
//        } completion:^( BOOL finished ) {
//            self.resumeButton.hidden = YES;
//        }];
//    }
    if (!self.cameraUnavailableLabel.hidden) {
        [UIView animateWithDuration:0.25 animations:^{
            self.cameraUnavailableLabel.alpha = 0.0;
        }                completion:^(BOOL finished) {
            self.cameraUnavailableLabel.hidden = YES;
        }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)updateUIRecordingStreamingStartingStopping {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.cameraButton.enabled = NO;
        self.recordButton.enabled = NO;
    });
}

- (void)updateUIRecordingStreamingStarted {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.recordButton.enabled = YES;
        //[self.recordButton setTitle:NSLocalizedString( @"Stop", @"Recording button stop title") forState:UIControlStateNormal];
        self.recordButton.imageView.image = [self getImageFromResource:@"Stop-100"];
        if (durationUpdateTimer != nil) [durationUpdateTimer invalidate];
        durationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateDuration) userInfo:nil repeats:true];
    });
}

- (void)updateUIRecordingStreamingComplete {
    // Enable the Camera and Record buttons to let the user switch camera and start another recording.
    dispatch_async(dispatch_get_main_queue(), ^{
        // Only enable the ability to change camera if the device has more than one camera.
        self.cameraButton.enabled = ([AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count > 1);
        self.recordButton.enabled = YES;
        //        [self.recordButton setTitle:NSLocalizedString( @"Record", @"Recording button record title" ) forState:UIControlStateNormal];
        self.recordButton.imageView.image = [self getImageFromResource:@"Record-100"];
        if (durationUpdateTimer != nil) [durationUpdateTimer invalidate];
        [self updateDuration];
    });
}

- (IBAction)toggleMovieRecording:(id)sender {
    _autostartEnabled = false;

    double epsilon = 0.001; // small number used to compare floating point numbers
    BOOL noStartDelay = self.startDelay <= epsilon;
    BOOL recordingNow = _movieAssetWriter != nil;

    if (noStartDelay || recordingNow || _streamingNow) {
        [self internalToggleMovieRecording];
    } else {
        delayCountdownCounter = (int) ceil(self.startDelay);
        [self doRecordingCountdown];
    }
}

- (void)doRecordingCountdown {
    self.countdownLabel.hidden = NO;
    self.countdownLabel.text = [[NSString alloc] initWithFormat:@"%i", delayCountdownCounter];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        delayCountdownCounter--;

        if (delayCountdownCounter <= 0) {
            self.countdownLabel.hidden = YES;
            [self internalToggleMovieRecording];
        } else {
            [self doRecordingCountdown];
        }
    });
}

- (void)internalToggleMovieRecording {
    _autostartEnabled = false;
    // Disable the Camera button until recording finishes, and disable the Record button until recording starts or finishes. See the
    // AVCaptureFileOutputRecordingDelegate methods.
    if (_useLiveStreaming) [self toggleStreaming];
    else {
        //[self resetVideoOrientation];
        [self updateUIRecordingStreamingStartingStopping];
        dispatch_async(self.sessionQueue, ^{
            /*if ( ! self.movieFileOutput.isRecording ) {
                if ( [UIDevice currentDevice].isMultitaskingSupported ) {
                    // Setup background task. This is needed because the -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:]
                    // callback is not received until AVCam returns to the foreground unless you request background execution time.
                    // This also ensures that there will be time to write the file to the photo library when AVCam is backgrounded.
                    // To conclude this background execution, -endBackgroundTask is called in
                    // -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:] after the recorded file has been saved.
                    self.backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                }

                // Update the orientation on the movie file output video connection before starting recording.
                AVCaptureConnection *connection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
                AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
                connection.videoOrientation = previewLayer.connection.videoOrientation;

                // Turn OFF flash for video recording.
                [ZiggeoRecorder2 setFlashMode:AVCaptureFlashModeOff forDevice:self.videoDeviceInput.device];

                // Start recording to a temporary file.
                NSString *outputFileName = [NSProcessInfo processInfo].globallyUniqueString;
                NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"mov"]];
                [self.movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
            }
            else {
                [self.movieFileOutput stopRecording];
            }*/
            if (_movieAssetWriter == nil) {
                if ([UIDevice currentDevice].isMultitaskingSupported) {
                    // Setup background task. This is needed because the -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:]
                    // callback is not received until AVCam returns to the foreground unless you request background execution time.
                    // This also ensures that there will be time to write the file to the photo library when AVCam is backgrounded.
                    // To conclude this background execution, -endBackgroundTask is called in
                    // -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:] after the recorded file has been saved.
                    self.backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                }

                self.firstSampleRendered = false;

//                AVCaptureConnection* connection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
//                AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
//                connection.videoOrientation = previewLayer.connection.videoOrientation;

                // Turn OFF flash for video recording.
                [ZiggeoRecorder2 setFlashMode:AVCaptureFlashModeOff forDevice:self.videoDeviceInput.device];

                self.duration = 0;
                self.durationExceeded = false;
                [self setupAssetWriter];

                //[_movieAssetWriter startSessionAtSourceTime:kCMTimeZero];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateUIRecordingStreamingStarted];
                });
            } else {
                NSURL *outputURL = _movieAssetWriter.outputURL;
                [_movieAssetWriter finishWritingWithCompletionHandler:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"recording finished to %@", outputURL.absoluteString);

                        if (self.recorderDelegate) {
                            if ([self.recorderDelegate respondsToSelector:@selector(ziggeoRecorderDidStop)]) {
                                [self.recorderDelegate ziggeoRecorderDidStop];
                                [self.ziggeo log:@"ziggeoRecorderDidStop called"];
                            } else {
                                [self.ziggeo log:@"recorder delegate is not responding to ziggeoRecorderDidStop"];
                            }
                        }

                        [self processRecordedVideoAtURL:outputURL error:nil];
                    });
                }];
                _movieAssetWriter = nil;
                _movieAssetWriterVideoInput = nil;
                _movieAssetWriterAudioInput = nil;
            }
        });
    }
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    // Enable the Record button to let the user stop the recording.
    [self updateUIRecordingStreamingStarted];
}


- (void)processRecordedVideoAtURL:(NSURL *)outputFileURL error:(NSError *)error {
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:outputFileURL.absoluteString error:nil] fileSize];
    NSLog(@"recorded file size: %i bytes", fileSize);


    UIBackgroundTaskIdentifier currentBackgroundRecordingID = self.backgroundRecordingID;
    self.backgroundRecordingID = UIBackgroundTaskInvalid;

    cleanup = ^{
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        if (currentBackgroundRecordingID != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:currentBackgroundRecordingID];
        }
    };

    BOOL success = YES;

    if (error) {
        [self.ziggeo logError:[NSString stringWithFormat:@"Movie file finishing error: %@", error]];
        success = [error.userInfo[AVErrorRecordingSuccessfullyFinishedKey] boolValue];
    }
    if (success) {
        //NSString *moviePath = (NSString*)[outputFileURL path];
        if (self.videoPreview && !_sendImmediately) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.videoPreview.videoURL = outputFileURL;
                self.videoPreview.videoGravity = self.videoGravity;
                [self presentViewController:self.videoPreview animated:NO completion:nil];
            });
        } else {
            [self coverSelectedForPath:outputFileURL.path image:nil];
        }
    } else {
        cleanup();
    }

    [self updateUIRecordingStreamingComplete];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    // Note that currentBackgroundRecordingID is used to end the background task associated with this recording.
    // This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's isRecording property
    // is back to NO — which happens sometime after this method returns.
    // Note: Since we use a unique file path for each recording, a new recording will not overwrite a recording currently being saved.
    [self processRecordedVideoAtURL:outputFileURL error:error];
}


- (UIImage *)getImageFromResource:(NSString *)resourceName {
    return [UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:[ZiggeoRecorder2 class]] pathForResource:resourceName ofType:@"png"]];
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    dispatch_async(self.sessionQueue, ^{
        AVCaptureDevice *device = self.videoDeviceInput.device;
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            // Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
            // Call -set(Focus/Exposure)Mode: to apply the new point of interest.
            if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:focusMode]) {
                device.focusPointOfInterest = point;
                device.focusMode = focusMode;
            }

            if (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode]) {
                device.exposurePointOfInterest = point;
                device.exposureMode = exposureMode;
            }

            device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange;
            [device unlockForConfiguration];
        } else {
            [self.ziggeo log:[NSString stringWithFormat:@"Could not lock device for configuration: %@", error]];
        }
    });
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device {
    if (device.hasFlash && [device isFlashModeSupported:flashMode]) {
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        } else {
            NSLog(@"Could not lock device for configuration: %@", error);
        }
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = devices.firstObject;

    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            captureDevice = device;
            break;
        }
    }

    return captureDevice;
}


- (void)retake {
    if (cleanup) cleanup();
}

- (void)coverSelectedForPath:(NSString *)videoPath image:(UIImage *)image {
    [self.ziggeo log:[NSString stringWithFormat:@"cover selected for video %@", videoPath]];
    if (image == nil) {
        [CoverSelectorController getDefaultCoverForPath:videoPath handler:^(UIImage *cover) {
            [[_ziggeo videos] createVideoWithData:self.extraArgsForCreateVideo file:videoPath cover:cover callback:^(NSDictionary *jsonObject, NSURLResponse *response, NSError *error) {
                if (error != nil) {
                    [self.ziggeo logError:[NSString stringWithFormat:@"upload video error: %@", error]];
                }
            }                            Progress:nil];
        }];
    } else {
        [[_ziggeo videos] createVideoWithData:self.extraArgsForCreateVideo file:videoPath cover:image callback:^(NSDictionary *jsonObject, NSURLResponse *response, NSError *error) {
            if (error != nil) {
                [self.ziggeo logError:[NSString stringWithFormat:@"upload video error: %@", error]];
            }
        }                            Progress:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)upload:(NSURL *)fileToUpload {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.ziggeo log:[NSString stringWithFormat:@"file %@ captured", [fileToUpload path]]];
        if (!m_videoToken) {
            if (self.coverSelectorEnabled) {
                CoverSelectorController *coverSelector = [[CoverSelectorController alloc] initWithSourceVideoPath:fileToUpload.path];
                coverSelector.delegate = self;
                [self presentViewController:coverSelector animated:YES completion:nil];
            } else {
                /*[[_ziggeo videos] createVideoWithData:self.extraArgsForCreateVideo file:fileToUpload.path cover:nil callback:nil Progress:nil];*/
                [self coverSelectedForPath:fileToUpload.path image:nil];
            }
        } else {
            [self.ziggeo log:[NSString stringWithFormat:@"going to rerecord video2 %@", m_videoToken]];
            [[_ziggeo videos] rerecordVideoWithToken:m_videoToken file:fileToUpload.path data:self.extraArgsForCreateVideo callback:nil Progress:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    });
    //if(cleanup) cleanup();
}

- (void)setupRecorderInterface {
    NSString *path;

    // record/stop button
    path = self.interfaceConfig.recordButton.imagePath;
    if (path) {
        UIImage *recordImage = [[UIImage alloc] initWithContentsOfFile:path];
        if (recordImage) {
            [self.recordButton setImage:recordImage forState:UIControlStateNormal];
        }
    }

    path = self.interfaceConfig.recordButton.selectedImagePath;
    if (path) {
        UIImage *stopImage = [[UIImage alloc] initWithContentsOfFile:path];
        if (stopImage) {
            [self.recordButton setImage:stopImage forState:UIControlStateSelected];
        }
    }

    self.recordButtonWidthConstraint.scale = self.interfaceConfig.recordButton.scale;
    self.recordButtonWidthConstraint.basicConstant = self.interfaceConfig.recordButton.width ? *self.interfaceConfig.recordButton.width : self.recordButtonWidthConstraint.basicConstant;
    self.recordButtonHeightConstraint.scale = self.interfaceConfig.recordButton.scale;
    self.recordButtonHeightConstraint.basicConstant = self.interfaceConfig.recordButton.height ? *self.interfaceConfig.recordButton.height : self.recordButtonHeightConstraint.basicConstant;

    // camera flip  button
    path = self.interfaceConfig.cameraFlipButton.imagePath;
    if (path) {
        UIImage *cameraFlipImage = [[UIImage alloc] initWithContentsOfFile:path];
        if (cameraFlipImage) {
            [self.cameraButton setImage:cameraFlipImage forState:UIControlStateNormal];
        }
    }

    self.cameraButtonWidthConstraint.scale = self.interfaceConfig.cameraFlipButton.scale;
    self.cameraButtonWidthConstraint.basicConstant = self.interfaceConfig.cameraFlipButton.width ? *self.interfaceConfig.cameraFlipButton.width : self.cameraButtonWidthConstraint.basicConstant;
    self.cameraButtonHeightConstraint.scale = self.interfaceConfig.cameraFlipButton.scale;
    self.cameraButtonHeightConstraint.basicConstant = self.interfaceConfig.cameraFlipButton.height ? *self.interfaceConfig.cameraFlipButton.height : self.cameraButtonHeightConstraint.basicConstant;

    // close recorder button
    path = self.interfaceConfig.closeButton.imagePath;
    if (path) {
        UIImage *closeImage = [[UIImage alloc] initWithContentsOfFile:path];
        if (closeImage) {
            [self.closeButton setImage:closeImage forState:UIControlStateNormal];
        }
    }
    self.closeButtonWidthConstraint.scale = self.interfaceConfig.closeButton.scale;
    self.closeButtonWidthConstraint.basicConstant = self.interfaceConfig.closeButton.width ? *self.interfaceConfig.closeButton.width : self.closeButtonWidthConstraint.basicConstant;
    self.closeButtonHeightConstraint.scale = self.interfaceConfig.closeButton.scale;
    self.closeButtonHeightConstraint.basicConstant = self.interfaceConfig.closeButton.height ? *self.interfaceConfig.closeButton.height : self.closeButtonHeightConstraint.basicConstant;
}

@end;
