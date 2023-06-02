package com.summit.hackerton.local.data

import com.summit.hackerton.remote.mobius.response.tlgroup.TlGroupResponse

/**
 * 신호등 관련 info
 *
 * @author Brand
 * @created 2023-05-24
 **/
object TrafficLightInfo {

    //신호등 리스트
    var trafficLightList: TlGroupResponse? = null

    fun getGeofenceListTrafficLight(): MutableList<TrafficGeofence> {
        val output: MutableList<TrafficGeofence> = mutableListOf()

        // 실제 신호등 그룹을 가져오는 코드
        trafficLightList?.m2m_agr?.m2m_rsp?.forEach { m2mRsp ->
            output.add(
                TrafficGeofence(
                    m2mRsp.pc.m2m_cin.con.id,
                    m2mRsp.pc.m2m_cin.con.lat,
                    m2mRsp.pc.m2m_cin.con.lang
                )
            )
        }


        return output
    }
}