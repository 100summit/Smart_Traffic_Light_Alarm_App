package com.summit.hackerton.service

import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.IBinder
import android.util.Log
import android.widget.Toast
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofenceStatusCodes
import com.google.android.gms.location.GeofencingEvent
import com.summit.hackerton.define.AppDefine
import com.summit.hackerton.local.data.TrafficLightInfo
import com.summit.hackerton.manager.GeoFenceCrossWalk
import com.summit.hackerton.manager.GeoFenceManager
import com.summit.hackerton.utils.MqttUtils
import com.summit.hackerton.utils.NotificationUtils
import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken
import org.eclipse.paho.client.mqttv3.MqttCallback
import org.eclipse.paho.client.mqttv3.MqttClient
import org.eclipse.paho.client.mqttv3.MqttMessage

/**
 *
 *
 * @author Brand
 * @created 2023-05-23
 **/
class CrossWalkService : Service() {
    private val mGeoFenceCrossWalk: GeoFenceCrossWalk by lazy {
        GeoFenceCrossWalk()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(AppDefine.FOREGROUND_NOTIFICATION_CHANNEL_ID_NUMBER, NotificationUtils.showForegroundNotification(this))

        mGeoFenceCrossWalk.init(this, AppDefine.crossWalkTargetTrafficLight)
        mGeoFenceCrossWalk.addGeofences()

        return START_NOT_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()

        mGeoFenceCrossWalk.removeGeofence()
        MqttUtils.disconnetMqtt()
    }
}