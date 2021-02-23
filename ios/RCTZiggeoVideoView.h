#ifndef RCTZiggeoVideoView_h
#define RCTZiggeoVideoView_h


#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <Ziggeo/Ziggeo.h>

typedef void (^ZiggeoPlayerReferenceBlock) (ZiggeoPlayer *player);

@interface RCTZiggeoVideoView : NSObject <RCTBridgeModule>

@property (strong, nonatomic) NSArray *tokens;
@property (strong, nonatomic) NSString *style;
@property (strong, nonatomic) ZiggeoPlayerReferenceBlock ref;

@end

#endif
