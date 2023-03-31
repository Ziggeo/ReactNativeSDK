#import "ZiggeoConstants.h"
#import "ZiggeoRecorderContext.h"


@implementation ZiggeoConstants

+ (NSString *)getEventString:(ZIGGEO_EVENTS)event {
    NSArray *typeArray = [[NSArray alloc] initWithObjects:kZiggeoEventsArray];
    return [typeArray objectAtIndex:event];
}

+ (NSString *)getKeyString:(Ziggeo_Key_Type)key {
    NSArray *typeArray = [[NSArray alloc] initWithObjects:kZiggeoKeysArray];
    return [typeArray objectAtIndex:key];
}

static Ziggeo *m_ziggeo = NULL;
static NSString *m_appToken = NULL;
static ZiggeoRecorderContext *m_context = NULL;

+ (void)setAppToken:(NSString *)appToken {
    m_appToken = appToken;
    
    @synchronized(self) {
        if (m_ziggeo == NULL) {
            m_ziggeo = [[Ziggeo alloc] initWithToken:m_appToken];
        }
    }
}

+ (ZiggeoRecorderContext *)sharedZiggeoRecorderContextInstance {
    @synchronized(self) {
        if (m_context == NULL) {
            m_context = [[ZiggeoRecorderContext alloc] init];
        }
    }
    return m_context;
}

+ (Ziggeo *)sharedZiggeoInstance {
    return m_ziggeo;
}


@end
