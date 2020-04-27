package com.ziggeo.modules;


import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.ziggeo.androidsdk.log.ZLog;
import com.ziggeo.tasks.ApiTask;
import com.ziggeo.tasks.Task;
import com.ziggeo.utils.ConversionUtil;

import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.disposables.Disposable;
import io.reactivex.plugins.RxJavaPlugins;
import io.reactivex.schedulers.Schedulers;

/**
 * Created by alex on 6/25/2017.
 */
public class Videos extends BaseModule {

    private CompositeDisposable compositeDisposable;

    public Videos(final ReactApplicationContext reactContext) {
        super(reactContext);
        RxJavaPlugins.setErrorHandler(ZLog::e);
        compositeDisposable = new CompositeDisposable();
    }

    @Override
    public String getName() {
        return Videos.class.getSimpleName();
    }

    @ReactMethod
    public void index(@Nullable ReadableMap args, @NonNull Promise promise) {
        final Task task = new ApiTask(promise);
        Disposable d = ziggeo.apiRx()
                .videosRaw()
                .index(ConversionUtil.toMap(args))
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(result -> resolve(task, result),
                        throwable -> reject(task, throwable.toString()));
        compositeDisposable.add(d);
    }

    @ReactMethod
    public void getImageUrl(@NonNull String tokenOrKey, @NonNull Promise promise) {
        promise.resolve(ziggeo.videos().getImageUrl(tokenOrKey));
    }

    @ReactMethod
    public void downloadImage(@NonNull String tokenOrKey, @NonNull Promise promise) {
        final Task task = new ApiTask(promise);
        Disposable d = ziggeo.apiRx()
                .videosRaw()
                .downloadImage(tokenOrKey)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(result -> resolve(task, result),
                        throwable -> reject(task, throwable.toString()));
        compositeDisposable.add(d);
    }

    @ReactMethod
    public void destroy(@NonNull String tokenOrKey, @NonNull Promise promise) {
        final Task task = new ApiTask(promise);
        Disposable d = ziggeo.apiRx()
                .videosRaw()
                .destroy(tokenOrKey)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(() -> resolve(task, null),
                        throwable -> reject(task, throwable.toString()));
        compositeDisposable.add(d);
    }

    @ReactMethod
    public void update(@NonNull String token, @NonNull String modelJson, @NonNull Promise promise) {
        final Task task = new ApiTask(promise);
        Disposable d = ziggeo.apiRx()
                .videosRaw()
                .update(token, modelJson)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(upd -> resolve(task, upd),
                        throwable -> reject(task, throwable.toString()));
        compositeDisposable.add(d);
    }

    @Override
    public void onCatalystInstanceDestroy() {
        super.onCatalystInstanceDestroy();
        compositeDisposable.dispose();
    }
}
