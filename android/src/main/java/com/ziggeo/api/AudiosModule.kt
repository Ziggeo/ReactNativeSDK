package com.ziggeo.api

import android.annotation.SuppressLint
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.ziggeo.BaseModule
import com.ziggeo.androidsdk.log.ZLog
import com.ziggeo.androidsdk.net.models.audios.AudioDetails
import com.ziggeo.tasks.SimpleTask
import com.ziggeo.tasks.Task
import com.ziggeo.utils.ConversionUtil
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.functions.BiConsumer
import io.reactivex.plugins.RxJavaPlugins
import io.reactivex.schedulers.Schedulers
import java.io.File

/**
 * Created by alex on 4/22/2021.
 */
class AudiosModule(reactContext: ReactApplicationContext) : BaseModule(reactContext) {
    private val compositeDisposable: CompositeDisposable
    override fun getName() = "Audios"

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
            .audiosRaw()
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
            .audiosRaw()
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
            .audios()
            .get(tokenOrKey)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe { url, throwable ->
                url?.let {
                    promise.resolve(it)
                }
                throwable?.let {
                    promise.reject(it)
                }
            }
    }

    @ReactMethod
    fun create(file: File, args: ReadableMap?, promise: Promise) {
        val task: Task = SimpleTask(promise)
        val d = ziggeo.apiRx()
            .audiosRaw()
            .create(file, ConversionUtil.toMap(args))
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe({ upd: String? -> resolve(task, upd) }
            ) { throwable: Throwable -> reject(task, throwable.toString()) }
        compositeDisposable.add(d)
    }

    @ReactMethod
    fun update(modelJson: String, promise: Promise) {
        val task: Task = SimpleTask(promise)
        val d = ziggeo.apiRx()
            .audiosRaw()
            .update(AudioDetails.fromJson(modelJson))
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe({ upd: String? -> resolve(task, upd) }
            ) { throwable: Throwable -> reject(task, throwable.toString()) }
        compositeDisposable.add(d)
    }

    @SuppressLint("CheckResult")
    @ReactMethod
    fun source(tokenOrKey: String, promise: Promise) {
        ziggeo.apiRx()
            .audios()
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
            .audios()
            .getAudioUrl(tokenOrKey)
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

    override fun onCatalystInstanceDestroy() {
        super.onCatalystInstanceDestroy()
        compositeDisposable.dispose()
    }
}