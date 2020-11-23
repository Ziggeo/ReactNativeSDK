package com.ziggeo.tasks

import com.facebook.react.bridge.Promise
import java.util.concurrent.atomic.AtomicInteger

/**
 * Created by Alex Bedulin on 08.02.2018.
 */
open class Task(promise: Promise) {
    private var id: Int
    private var promise: Promise?
    private var thread: Thread? = null
    fun setRunnable(runnable: Runnable?) {
        thread = Thread(runnable)
    }

    fun execute() {
        thread?.start()
    }

    fun resolve(obj: Any?) {
        promise?.let {
            try {
                it.resolve(obj)
            } finally {
                promise = null
            }
        }
    }

    fun reject(err: String) {
        reject(err, null)
    }

    fun reject(err: String, message: String?) {
        promise?.let {
            try {
                it.reject(err, message)
            } finally {
                promise = null
            }
        }
    }

    companion object {
        val GLOBAL_ID = AtomicInteger()
    }

    init {
        id = GLOBAL_ID.getAndIncrement()
        this.promise = promise
    }
}