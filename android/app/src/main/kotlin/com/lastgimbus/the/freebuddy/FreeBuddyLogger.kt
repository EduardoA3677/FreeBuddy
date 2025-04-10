package com.lastgimbus.the.freebuddy

import android.util.Log

object FreeBuddyLogger {
    private const val TAG_PREFIX = "FREEBUDDY_"

    fun d(tag: String, message: String) {
        Log.d(TAG_PREFIX + tag, message)
    }

    fun i(tag: String, message: String) {
        // Use WARN level for info to increase visibility in logcat
        Log.w(TAG_PREFIX + tag, message)
    }

    fun w(tag: String, message: String) {
        Log.w(TAG_PREFIX + tag, message)
    }

    fun e(tag: String, message: String, throwable: Throwable? = null) {
        Log.e(TAG_PREFIX + tag, message, throwable)
    }

    fun wtf(tag: String, message: String) {
        Log.wtf(TAG_PREFIX + tag, message)
    }
}
