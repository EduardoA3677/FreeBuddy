package com.lastgimbus.the.freebuddy

import android.Manifest
import android.bluetooth.BluetoothClass
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.work.Data
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import dev.fluttercommunity.workmanager.BackgroundWorker

// Ensure FreeBuddyLogger is properly imported or defined
import com.lastgimbus.the.freebuddy.FreeBuddyLogger

/**
 * This reacts to a new bluetooth device being connected (literally any)
 *
 * That's why it then filters out to only AUDIO_VIDEO devices, and (currently):
 * - launches one-off workmanager work to update the widget
 */
class BluetoothDeviceConnectedReceiver : BroadcastReceiver() {
    companion object {
        const val TAG = "BtDevConnReceiver"
        const val TASK_ID_ROUTINE_UPDATE = "freebuddy.routine_update"
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            BluetoothDevice.ACTION_ACL_CONNECTED -> {
                val device = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
                } else {

                    intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                }
                if (device == null) {
                    FreeBuddyLogger.wtf(TAG, "device is null!!")
                    return
                }
                FreeBuddyLogger.d(TAG, "Connected to dev: $device ; Class: ${device.bluetoothClass.majorDeviceClass}")
                if (ActivityCompat.checkSelfPermission(
                        context,
                        Manifest.permission.BLUETOOTH_CONNECT
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    FreeBuddyLogger.i(TAG, "No BLUETOOTH_CONNECT permission granted")
                    return
                }
                if (device.bluetoothClass.majorDeviceClass != BluetoothClass.Device.Major.AUDIO_VIDEO)
                {
                    FreeBuddyLogger.i(TAG, "$device is not AUDIO_VIDEO, skipping...")
                    return
                }
                FreeBuddyLogger.i(TAG, "Scheduling one time work to update widget n stuff...")
                // this is stuff imported from dev.fluttercommunity.workmanager
                val oneOffTaskRequest = OneTimeWorkRequest.Builder(BackgroundWorker::class.java)
                    .setInputData(
                        Data.Builder()
                            .putString(BackgroundWorker.DART_TASK_KEY, TASK_ID_ROUTINE_UPDATE)
                            .putBoolean(BackgroundWorker.IS_IN_DEBUG_MODE_KEY, false)
                            .build()
                    )
                    .build()
                WorkManager.getInstance(context).enqueue(oneOffTaskRequest)
            }
        }
    }
}
