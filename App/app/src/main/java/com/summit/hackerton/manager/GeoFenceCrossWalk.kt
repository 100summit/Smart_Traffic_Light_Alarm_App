package com.summit.hackerton.manager

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.Toast
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofencingClient
import com.google.android.gms.location.GeofencingRequest
import com.google.android.gms.location.LocationServices
import com.summit.hackerton.broadcast.GeofenceBroadcastReceiver
import com.summit.hackerton.local.data.TrafficGeofence
import com.summit.hackerton.service.TrafficService

/**
 *
 *
 * @author Brand
 * @created 2023-05-24
 **/
class GeoFenceCrossWalk {

    private var mContext: Context? = null

    private lateinit var geofenceList: MutableList<Geofence>

    private val geofencingClient: GeofencingClient by lazy {
        LocationServices.getGeofencingClient(mContext!!)
    }

    private val geofencePendingIntent: PendingIntent by lazy {
        val intent = Intent(mContext, GeofenceBroadcastReceiver::class.java)
        PendingIntent.getBroadcast(
            mContext, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or
                    (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0)
        )
    }

    fun init(context: Context, locationList: TrafficGeofence) {
        mContext = context
        geofenceList = mutableListOf()

            geofenceList.add(
                getGeofence(locationList.name, Pair(locationList.lat, locationList.lon))
            )
    }

    /**
     * 지오펜싱 생성
     *
     * @author Brand
     * @since 2023/06/01
     **/
    @SuppressLint("VisibleForTests")
    private fun getGeofence(
        reqId: String,
        geo: Pair<Double, Double>,
        radius: Float = 20f
    ): Geofence {
        return Geofence.Builder()
            .setRequestId(reqId)                                // ID to identify in BroadcastReceiver when event occurs
            .setCircularRegion(geo.first, geo.second, radius)   // Position and radius(m)
            .setExpirationDuration(12 * 60 * 60 * 1000)         // Geofence expiration time
            .setLoiteringDelay(10000)                           // Stay time
            .setTransitionTypes(
                Geofence.GEOFENCE_TRANSITION_ENTER              // Upon entry detection
                        or Geofence.GEOFENCE_TRANSITION_EXIT    // On departure detection
                        or Geofence.GEOFENCE_TRANSITION_DWELL   // When lingering is detected
            )
            .build()
    }

    private fun getGeofencingRequest(list: List<Geofence>): GeofencingRequest {
        return GeofencingRequest.Builder().apply {
            setInitialTrigger(GeofencingRequest.INITIAL_TRIGGER_ENTER)
            addGeofences(list)    // Geofence 리스트 추가
        }.build()
    }

    /**
     * 지오펜싱 등록
     *
     * @author Brand
     * @since 2023/06/01
     **/
    @SuppressLint("MissingPermission")
    fun addGeofences() {
        geofencingClient.addGeofences(getGeofencingRequest(geofenceList), geofencePendingIntent)
    }

    /**
     * 지오펜싱 제거
     *
     * @author Brand
     * @since 2023/06/01
     **/
    fun removeGeofence() {
        geofencingClient.removeGeofences(geofencePendingIntent)
    }
}