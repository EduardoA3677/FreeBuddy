package com.lastgimbus.the.freebuddy

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.work.Data
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import dev.fluttercommunity.workmanager.BackgroundWorker
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

class BatteryUpdateService : Service() {
    companion object {
        private const val NOTIFICATION_ID = 101
        private const val CHANNEL_ID = "battery_update_channel"
        private const val TASK_ID_ROUTINE_UPDATE = "freebuddy.routine_update"
        private const val UPDATE_INTERVAL_MINUTES = 15L
    }

    private lateinit var executor: ScheduledExecutorService

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())

        executor = Executors.newSingleThreadScheduledExecutor()
        executor.scheduleAtFixedRate(
            { scheduleWidgetUpdate() },
            0,
            UPDATE_INTERVAL_MINUTES,
            TimeUnit.MINUTES
        )
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // If service is killed, restart it
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        executor.shutdown()
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Battery Updates"
            val descriptionText = "Channel for battery update service"
            val importance = NotificationManager.IMPORTANCE_LOW
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
            }
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("FreeBuddy")
            .setContentText("Monitoring earbuds battery status")
            .setSmallIcon(R.drawable.earbuds)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun scheduleWidgetUpdate() {
        // Use the WorkManager to trigger widget update
        val oneOffTaskRequest = OneTimeWorkRequest.Builder(BackgroundWorker::class.java)
            .setInputData(
                Data.Builder()
                    .putString(BackgroundWorker.DART_TASK_KEY, TASK_ID_ROUTINE_UPDATE)
                    .putBoolean(BackgroundWorker.IS_IN_DEBUG_MODE_KEY, false)
                    .build()
            )
            .build()
        WorkManager.getInstance(this).enqueue(oneOffTaskRequest)
    }
}
