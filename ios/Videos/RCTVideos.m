#import <Foundation/Foundation.h>
#import "RCTVideos.h"
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>
#import "RotatingImagePickerController.h"


@interface VideosContext: NSObject<ZiggeoUploadDelegate>

@property (strong, nonatomic) RCTPromiseResolveBlock resolveBlock;
@property (strong, nonatomic) RCTPromiseRejectBlock rejectBlock;
@property (strong, nonatomic) RCTVideos* videos;

@end;



@implementation VideosContext

- (void)resolve:(NSString*)token {
    if(_resolveBlock) _resolveBlock(token);
    _resolveBlock = nil;
    _rejectBlock = nil;
    self.videos = nil;
}

- (void)reject:(NSString*)code message:(NSString*)message {
    if(_rejectBlock) _rejectBlock(code, message, [NSError errorWithDomain:@"recorder" code:0 userInfo:@{code:message}]);
    _resolveBlock = nil;
    _rejectBlock = nil;
    self.videos = nil;
}

- (void)preparingToUploadWithPath:(NSString *)sourcePath {
    
}

- (void)preparingToUploadWithPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken {
    
}

- (void)failedToUploadWithPath:(NSString *)sourcePath {
    
}

- (void)uploadStartedWithPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken backgroundTask:(NSURLSessionTask *)uploadingTask {
    
}

- (void)uploadProgressForPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken totalBytesSent:(int)bytesSent totalBytesExpectedToSend:(int)totalBytes {
}

- (void)uploadCompletedForPath:(NSString *)sourcePath token:(NSString *)token streamToken:(NSString *)streamToken withResponse:(NSURLResponse *)response error:(NSError *)error json:(NSDictionary *)json {
}

- (void)deleteWithToken:(NSString *)token streamToken:(NSString *)streamToken withResponse:(NSURLResponse *)response error:(NSError *)error json:(NSDictionary *)json {
    
}

@end;


@implementation RCTVideos {
}

static NSString *__appToken;
static NSString *__serverAuthToken;
static NSString *__clientAuthToken;


+ (NSString *) _appToken { return __appToken; }
+ (NSString *) _serverAuthToken { return __serverAuthToken; }
+ (NSString *) _clientAuthToken { return __clientAuthToken; }


RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents
{
    return @[
    ];
}

RCT_EXPORT_METHOD(setAppToken:(NSString *)token)
{
    RCTLogInfo(@"application token set: %@", token);
    __appToken = token;
}

RCT_EXPORT_METHOD(setServerAuthToken:(NSString *)token)
{
    RCTLogInfo(@"server auth token set: %@", token);
    __serverAuthToken = token;
}

RCT_EXPORT_METHOD(setClientAuthToken:(NSString *)token)
{
    RCTLogInfo(@"server auth token set: %@", token);
    __clientAuthToken = token;
}


RCT_EXPORT_METHOD(index:(NSDictionary *)map resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    /*
    val task: Task = SimpleTask(promise)
    val d = ziggeo.apiRx()
            .videosRaw()
            .index(ConversionUtil.toMap(args))
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe({ result: String? -> resolve(task, result) }
            ) { throwable: Throwable -> reject(task, throwable.toString()) }
    compositeDisposable.add(d)
    */
}

RCT_EXPORT_METHOD(getImageUrl:(NSString *)tokenOrKey resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    /*
    promise.resolve(ziggeo.videos().getImageUrl(tokenOrKey))
    */
}

RCT_EXPORT_METHOD(downloadImage:(NSString *)tokenOrKey resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    /*
    val task: Task = SimpleTask(promise)
        val d = ziggeo.apiRx()
                .videosRaw()
                .downloadImage(tokenOrKey)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({ result: InputStream? -> resolve(task, result) }
                ) { throwable: Throwable -> reject(task, throwable.toString()) }
        compositeDisposable.add(d)
    */
}

RCT_EXPORT_METHOD(destroy:(NSString *)token resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        VideosContext* context = [[VideosContext alloc] init];
        context.resolveBlock = resolve;
        context.rejectBlock = reject;
        context.videos = self;

        Ziggeo* ziggeo = [[Ziggeo alloc] initWithToken:[RCTVideos _appToken]];
        ziggeo.connect.serverAuthToken = [RCTVideos _serverAuthToken];
        ziggeo.connect.clientAuthToken = [RCTVideos _clientAuthToken];
        ziggeo.videos.uploadDelegate = context;
        [ziggeo.videos deleteVideoByToken:token StreamToken:@"" Callback:^(NSDictionary *jsonObject, NSURLResponse *response, NSError *error) {
            if (error == nil) {
                resolve(nil);
            } else {
                reject(nil, nil, error);
            }
        }];
    });
}

RCT_EXPORT_METHOD(update:(NSString *)tokenOrKey modelJson:(NSString *)modelJson resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    /*
    val task: Task = SimpleTask(promise)
        val d = ziggeo.apiRx()
                .videosRaw()
                .update(token, modelJson)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({ upd: String? -> resolve(task, upd) }
                ) { throwable: Throwable -> reject(task, throwable.toString()) }
        compositeDisposable.add(d)
    */
}

@end

