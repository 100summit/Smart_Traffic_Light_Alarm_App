package com.summit.hackerton.broadcast

import android.annotation.SuppressLint
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.PowerManager
import android.widget.Toast
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofenceStatusCodes
import com.google.android.gms.location.GeofencingEvent
import com.summit.hackerton.define.AppDefine
import com.summit.hackerton.define.AppDefine.me
import com.summit.hackerton.remote.api.MobiusApi
import com.summit.hackerton.remote.common.response.MobiusApiResult
import com.summit.hackerton.service.TrafficService
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
class GeofenceBroadcastReceiver : BroadcastReceiver() {
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
                    // 지오펜싱 진입 Callback
                    Toast.makeText(
                        context,
                        "${triggeringGeofences[0].requestId} - 진입",
                        Toast.LENGTH_LONG
                    ).show()
                    NotificationUtils.sendNotification(context!!, "alert", "Entered a traffic light")

                    // 해당 신호등 구독 연결
                    MqttUtils.communicateMqtt(triggeringGeofences[0].requestId)


                    // 최초 해당 구독 신호등의 정보 가져오기
                    CoroutineScope(Dispatchers.IO).launch {
                        MobiusApi.requestTlState(triggeringGeofences[0].requestId) { result ->
                            when (result) {
                                is MobiusApiResult.Success -> {
                                    MainActivity().setNowTrafficLight(result.data!!, triggeringGeofences[0].requestId)
                                }
                                is MobiusApiResult.Error -> {}
                            }
                        }
                    }

                    //교통 약자 컨트롤
                    if(me.userType != "normal"){
                        MainActivity().fireStoreRequest(triggeringGeofences[0].requestId, true)
                    }

                }
                Geofence.GEOFENCE_TRANSITION_DWELL -> {
                    // 지오펜싱 머물기 Callback
                    Toast.makeText(
                        context,
                        "${triggeringGeofences[0].requestId} - 머물기",
                        Toast.LENGTH_LONG
                    ).show()
                }
                Geofence.GEOFENCE_TRANSITION_EXIT -> {
                    // 지오펜싱 이탈 Callback

                    // 해당 신호등 구독 해지
                    MqttUtils.disconnetMqtt()

                    //교통 약자 컨트롤
                    if(me.userType != "normal"){
                        MainActivity().fireStoreRequest(triggeringGeofences[0].requestId, false)
                    }

                    // 횡단 감지 GeoFence 삭제
                    context?.stopService(Intent(context, TrafficService::class.java))

                    // 횡단보도 횡단 완료 시각 저장
                    AppDefine.exitTime = System.currentTimeMillis()


                    // 횡단보도를 그냥 지나친게 아니라 횡단하였다면,
                    if(AppDefine.enterTime != 0L){
                        val w_kind =  if(AppDefine.nowTargetTlState == "red") "jaywalking" else "normal"
                        val powerManager = context?.getSystemService(Context.POWER_SERVICE) as PowerManager
                        val isScreenOn = powerManager.isInteractive


                        val ais = if(isScreenOn) "smombie" else "normal"
                        MainActivity().requestCi(triggeringGeofences[0].requestId , w_kind, ais)
                    }

                    Toast.makeText(
                        context,
                        "${triggeringGeofences[0].requestId} - 이탈",
                        Toast.LENGTH_LONG
                    ).show()
                }
                else -> {

                }
            }

        } else {
            Toast.makeText(context, "Unknown", Toast.LENGTH_LONG).show()
        }
    }
}