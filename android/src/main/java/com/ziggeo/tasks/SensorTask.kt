package com.ziggeo.tasks

import com.facebook.react.bridge.Promise

class SensorTask(
        promise: Promise,
        var lightSensorLevel: Float = 0f
) : Task(promise)
