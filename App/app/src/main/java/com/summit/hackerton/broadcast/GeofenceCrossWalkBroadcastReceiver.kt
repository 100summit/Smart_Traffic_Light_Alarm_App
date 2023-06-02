package com.summit.hackerton.broadcast

import android.annotation.SuppressLint
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.widget.Toast
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofenceStatusCodes
import com.google.android.gms.location.GeofencingEvent
import com.summit.hackerton.define.AppDefine
import com.summit.hackerton.define.AppDefine.enterTime
import com.summit.hackerton.define.AppDefine.me
import com.summit.hackerton.local.data.TrafficLightInfo
import com.summit.hackerton.remote.api.MobiusApi
import com.summit.hackerton.remote.common.response.MobiusApiResult
import com.summit.hackerton.utils.MqttUtils
import com.summit.hackerton.utils.NotificationUtils
import com.summit.hackerton.view.MainActivity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import timber.log.Timber

/**
 *
 *
 * @author Brand
 * @created 2023-05-24
 **/
class GeofenceCrossWalkBroadcastReceiver : BroadcastReceiver() {
    @SuppressLint("VisibleForTests")
    override fun onReceive(context: Context?, intent: Intent?) {
        val geofencingEvent = GeofencingEvent.fromIntent(intent)
        if (geofencingEvent.hasError()) {
            val errorMessage = GeofenceStatusCodes.getStatusCodeString(geofencingEvent.errorCode)
            Timber.d("GeofenceBR $errorMessage")
            return
        }

        // Get the transition type.
        val geofenceTransition = geofencingEvent.geofenceTransition    // 발생 이벤트 타입

        // Test that the reported transition was of interest.
        if (geofenceTransition == Geofence.GEOFENCE_TRANSITION_ENTER ||
            geofenceTransition == Geofence.GEOFENCE_TRANSITION_DWELL ||
            geofenceTransition == Geofence.GEOFENCE_TRANSITION_EXIT
        ) {

            val triggeringGeofences = geofencingEvent.triggeringGeofences

            when (geofenceTransition) {
                Geofence.GEOFENCE_TRANSITION_ENTER -> {
                    // 횡단보도 진입 Callback

                    // 횡단보도 진입 시각 저장
                    enterTime = System.currentTimeMillis()

                    // 빨간불 진입 시 경고 알림
                    if(AppDefine.nowTargetTlState == "red") {
                        NotificationUtils.sendNotification(context!!, "alert", "danger!!! danger!!! danger!!!")
                    }

                }
                Geofence.GEOFENCE_TRANSITION_DWELL -> {
                    // 횡단보도 머물기 Callback
                }
                Geofence.GEOFENCE_TRANSITION_EXIT -> {
                    // 횡단보도 통과 Callback

                }
                else -> {

                }
            }

        } else {
            Toast.makeText(context, "Unknown", Toast.LENGTH_LONG).show()
        }
    }
}