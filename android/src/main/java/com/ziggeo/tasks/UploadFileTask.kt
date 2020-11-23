package com.ziggeo.tasks

import com.facebook.react.bridge.Promise
import java.util.*

/**
 * Created by Alex Bedulin on 06.02.2018.
 */
class UploadFileTask(
        promise: Promise,
        var extraArgs: HashMap<String, String?>? = null
) : Task(promise)