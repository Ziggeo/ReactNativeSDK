package com.ziggeo.tasks

import com.facebook.react.bridge.Promise

/**
 * Created by Alex Bedulin on 08.02.2018.
 */
class RecordVideoTask(
        promise: Promise,
        var isUploadingStarted: Boolean = false
) : Task(promise)