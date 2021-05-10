#ifndef RCTZiggeoVideoView_h
#define RCTZiggeoVideoView_h
#import <React/RCTEventEmitter.h>
#import <Ziggeo/Ziggeo.h>
#import <AVKit/AVKit.h>

typedef void (^ZiggeoPlayerReferenceBlock) (ZiggeoPlayer *player);

@interface RCTZiggeoVideoView : UIView

@property (strong, nonatomic) NSString *style;
@property (strong, nonatomic) ZiggeoPlayerReferenceBlock ref;
@property (strong, nonatomic) AVPlayerViewController *playerController;
@property (strong, nonatomic) Ziggeo *m_ziggeo;

- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher NS_DESIGNATED_INITIALIZER;

- (void)setVideoToken:(NSString *)token;

@end

#endif
