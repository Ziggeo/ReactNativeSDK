package com.ziggeo.api

import android.annotation.SuppressLint
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.ziggeo.BaseModule
import com.ziggeo.androidsdk.log.ZLog
import com.ziggeo.tasks.SimpleTask
import com.ziggeo.tasks.Task
import com.ziggeo.utils.ConversionUtil
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.functions.BiConsumer
import io.reactivex.plugins.RxJavaPlugins
import io.reactivex.schedulers.Schedulers
import java.io.InputStream

/**
 * Created by alex on 6/25/2017.
 */
class VideosModule(reactContext: ReactApplicationContext) : BaseModule(reactContext) {
    private val compositeDisposable: CompositeDisposable
    override fun getName() = "Videos"

    init {
        RxJavaPlugins.setErrorHandler { t: Throwable? -> ZLog.e(t) }
        compositeDisposable = CompositeDisposable()
    }

    @ReactMethod
    fun setAppToken(appToken: String) {
        ZLog.d("setAppToken:%s", appToken)
        ziggeo.appToken = appToken
    }

    // we must override this method to make @ReactMethod annotation work
    @ReactMethod
    override fun setClientAuthToken(token: String) {
        super.setClientAuthToken(token)
    }

    // we must override this method to make @ReactMethod annotation work
    @ReactMethod
    override fun setServerAuthToken(token: String) {
        super.setServerAuthToken(token)
    }

    @ReactMethod
    fun index(args: ReadableMap?, promise: Promise) {
        val task: Task = SimpleTask(promise)
        val d = ziggeo.apiRx()
                .videosRaw()
                .index(ConversionUtil.toMap(args))
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({ result: String? -> resolve(task, result) }
                ) { throwable: Throwable -> reject(task, throwable.toString()) }
        compositeDisposable.add(d)
    }

    @SuppressLint("CheckResult")
    @ReactMethod
    fun get(tokenOrKey: String, promise: Promise) {
        ziggeo.apiRx()
                .videos()
                .get(tokenOrKey)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(BiConsumer { url, throwable ->
                    url?.let {
                        promise.resolve(it)
                    }
                    throwable?.let {
                        promise.reject(it)
                    }
                })
    }

    @SuppressLint("CheckResult")
    @ReactMethod
    fun getVideoUrl(tokenOrKey: String, promise: Promise) {
        ziggeo.apiRx()
                .videos()
                .getVideoUrl(tokenOrKey)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(BiConsumer { url, throwable ->
                    url?.let {
                        promise.resolve(it)
                    }
                    throwable?.let {
                        promise.reject(it)
                    }
                })
    }

    @SuppressLint("CheckResult")
    @ReactMethod
    fun getImageUrl(tokenOrKey: String, promise: Promise) {
        ziggeo.apiRx()
                .videos()
                .getImageUrl(tokenOrKey)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(BiConsumer { url, throwable ->
                    url?.let {
                        promise.resolve(it)
                    }
                    throwable?.let {
                        promise.reject(it)
                    }
                })
    }

    @ReactMethod
    fun destroy(tokenOrKey: String, promise: Promise) {
        val task: Task = SimpleTask(promise)
        val d = ziggeo.apiRx()
                .videosRaw()
                .destroy(tokenOrKey)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({ resolve(task, null) }
                ) { throwable: Throwable -> reject(task, throwable.toString()) }
        compositeDisposable.add(d)
    }

    @ReactMethod
    fun update(token: String, modelJson: String, promise: Promise) {
        val task: Task = SimpleTask(promise)
        val d = ziggeo.apiRx()
                .videosRaw()
                .update(token, modelJson)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({ upd: String? -> resolve(task, upd) }
                ) { throwable: Throwable -> reject(task, throwable.toString()) }
        compositeDisposable.add(d)
    }

    override fun onCatalystInstanceDestroy() {
        super.onCatalystInstanceDestroy()
        compositeDisposable.dispose()
    }
}