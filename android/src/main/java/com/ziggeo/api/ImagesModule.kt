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
import java.io.File

/**
 * Created by alex on 4/22/2021.
 */
class ImagesModule(reactContext: ReactApplicationContext) : BaseModule(reactContext) {
    private val compositeDisposable: CompositeDisposable
    override fun getName() = "Images"

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
                .imagesRaw()
                .index(ConversionUtil.toMap(args))
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({ result: String? -> resolve(task, result) }
                ) { throwable: Throwable -> reject(task, throwable.toString()) }
        compositeDisposable.add(d)
    }

    @ReactMethod
    fun destroy(tokenOrKey: String, promise: Promise) {
        val task: Task = SimpleTask(promise)
        val d = ziggeo.apiRx()
                .imagesRaw()
                .destroy(tokenOrKey)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({ resolve(task, null) }
                ) { throwable: Throwable -> reject(task, throwable.toString()) }
        compositeDisposable.add(d)
    }

    @SuppressLint("CheckResult")
    @ReactMethod
    fun get(tokenOrKey: String, promise: Promise) {
        ziggeo.apiRx()
                .images()
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

    @ReactMethod
    fun create(file: File, args: ReadableMap?, promise: Promise) {
        val task: Task = SimpleTask(promise)
        val d = ziggeo.apiRx()
                .imagesRaw()
                .create(file, ConversionUtil.toMap(args))
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({ upd: String? -> resolve(task, upd) }
                ) { throwable: Throwable -> reject(task, throwable.toString()) }
        compositeDisposable.add(d)
    }

    @ReactMethod
    fun update(modelJson: String, promise: Promise) {
        //todo add update with String arg instead AudiosModel

//        val task: Task = SimpleTask(promise)
//        val d = ziggeo.apiRx()
//                .audiosRaw()
//                .update(modelJson)
//                .subscribeOn(Schedulers.io())
//                .observeOn(AndroidSchedulers.mainThread())
//                .subscribe({ upd: String? -> resolve(task, upd) }
//                ) { throwable: Throwable -> reject(task, throwable.toString()) }
//        compositeDisposable.add(d)
    }

    @SuppressLint("CheckResult")
    @ReactMethod
    fun source(tokenOrKey: String, promise: Promise) {
        ziggeo.apiRx()
                .images()
                .source(tokenOrKey)
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
    fun getAudioUrl(tokenOrKey: String, promise: Promise) {
        ziggeo.apiRx()
                .images()
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
    fun startImageRecorder() {
        ziggeo.startImageRecorder()
    }

    @ReactMethod
    fun startAudioRecorder() {
        ziggeo.startAudioRecorder()
    }

    @ReactMethod
    fun startAudioPlayer(token: String) {
        ziggeo.startAudioPlayer(null, token)
    }

    @ReactMethod
    fun showImage(token: String) {
        ziggeo.showImage(token)
    }

    override fun onCatalystInstanceDestroy() {
        super.onCatalystInstanceDestroy()
        compositeDisposable.dispose()
    }
}