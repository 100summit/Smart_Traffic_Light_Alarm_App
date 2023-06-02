package com.summit.hackerton.utils

import com.google.gson.Gson
import com.summit.hackerton.define.AppDefine.getTime
import com.summit.hackerton.remote.mobius.response.tlstate.depth.TlStateResponse
import com.summit.hackerton.view.MainActivity
import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken
import org.eclipse.paho.client.mqttv3.MqttCallback
import org.eclipse.paho.client.mqttv3.MqttClient
import org.eclipse.paho.client.mqttv3.MqttMessage
import timber.log.Timber
import java.text.SimpleDateFormat

/**
 *
 *
 * @author Brand
 * @created 2023-05-24
 **/
object MqttUtils {
    val ServerIP: String = "tcp://192.168.0.238:1883"
    val RECEIVE_TOPIC: String = "/oneM2M/req/Mobius2/"
    val SEND_TOPIC: String = "/oneM2M/resp/Mobius2/"
    var mqttClient: MqttClient? = null

    /**
     * MQTT 연결
     *
     * @author Brand
     * @since 2023/06/01
     **/
    fun communicateMqtt(requestId: String) {
        mqttClient = MqttClient(ServerIP, MqttClient.generateClientId(), null) // 연결설정
        mqttClient!!.connect()

        mqttClient!!.subscribe("$RECEIVE_TOPIC$requestId/+") //구독 설정
        mqttClient!!.setCallback(object : MqttCallback { // 콜백 설정
            override fun connectionLost(p0: Throwable?) {
                //연결이 끊겼을 경우
                Timber.d("MQTTService Connection Lost")
            }

            override fun messageArrived(p0: String?, p1: MqttMessage?) {
                //메세지가 도착했을 때 여기
                val data = Gson().fromJson(p1.toString(), TlStateResponse::class.java)

                val nowTime = SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(getTime())
                val serverTime = SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(data.m2m_cin.con.time)
                val gap = ((nowTime.time - serverTime.time) / 1000).toInt()

                when(data.m2m_cin.con.state)
                {
                    "green" -> {

                        MainActivity().setGreenLight(data.m2m_cin.con.g_time - gap)
                    }
                    "red" -> {
                        MainActivity().setRedLight(data.m2m_cin.con.r_time - gap)
                    }
                }

                Timber.d("MQTTService Message Arrived ${p1.toString()}") // 메세지 도착
                mqttClient!!.publish("$SEND_TOPIC$requestId/json", MqttMessage("res message".toByteArray()))
            }

            override fun deliveryComplete(p0: IMqttDeliveryToken?) {
                //메세지가 잘 전송되었을때
                Timber.d("MQTTService Delivery Complete")
            }
        })
    }

    /**
     * MQTT 연결 해제
     *
     * @author Brand
     * @since 2023/06/01
     **/
    fun disconnetMqtt() {
        mqttClient?.apply {
            disconnect()
        }
    }
}