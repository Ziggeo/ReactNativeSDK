#import <Foundation/Foundation.h>
#import "RCTVideos.h"
#import <Ziggeo/Ziggeo.h>
#import <React/RCTLog.h>
#import "RotatingImagePickerController.h"

@implementation RCTVideos {
}

RCT_EXPORT_MODULE();

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

RCT_EXPORT_METHOD(destroy:(NSString *)tokenOrKey resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    /*
    val task: Task = SimpleTask(promise)
        val d = ziggeo.apiRx()
                .videosRaw()
                .destroy(tokenOrKey)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({ resolve(task, null) }
                ) { throwable: Throwable -> reject(task, throwable.toString()) }
        compositeDisposable.add(d)
    */
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

