#ifndef RCTZiggeoVideoView_h
#define RCTZiggeoVideoView_h


#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <Ziggeo/Ziggeo.h>

typedef void (^ZiggeoPlayerReferenceBlock) (ZiggeoPlayer *player);

@interface RCTZiggeoVideoView : UIView

@property (strong, nonatomic) NSArray *tokens;
@property (strong, nonatomic) NSString *style;
@property (strong, nonatomic) ZiggeoPlayerReferenceBlock ref;

- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher tokens:(NSArray *)tokens NS_DESIGNATED_INITIALIZER;

@end

#endif
