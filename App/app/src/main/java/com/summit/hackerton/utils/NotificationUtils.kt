package com.summit.hackerton.utils

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Context.NOTIFICATION_SERVICE
import androidx.core.app.NotificationCompat
import com.summit.hackerton.R
import com.summit.hackerton.define.AppDefine

/**
 *
 *
 * @author Brand
 * @created 2023-05-23
 **/
object NotificationUtils {

    /**
     * 포그라운드 Notification 설정
     *
     * @author Brand
     * @since 2023/04/04
     **/
    fun showForegroundNotification(context: Context) : Notification {
        val builder = NotificationCompat.Builder(context, "default")
        builder.setSmallIcon(R.mipmap.ic_main)
        builder.setContentTitle("Checking traffic light information")
        builder.setOngoing(true)
        builder.setChannelId(AppDefine.FOREGROUND_NOTIFICATION_CHANNEL_ID)

        // 알림 표시
        val notificationManager = context.getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.createNotificationChannel(
            NotificationChannel(
                AppDefine.FOREGROUND_NOTIFICATION_CHANNEL_ID,
                AppDefine.FOREGROUND_NOTIFICATION_CHANNEL_NAME,
                NotificationManager.IMPORTANCE_DEFAULT
            )
        )

        notificationManager.notify(AppDefine.FOREGROUND_NOTIFICATION_CHANNEL_ID_NUMBER, builder.build()) // id : 정의해야하는 각 알림의 고유한 int값
        return builder.build()
    }

    /**
     * 로컬 푸시 전송
     *
     * @author Brand
     * @since 2023/06/01
     **/
    fun sendNotification(context: Context, title: String, message: String) {
        getNotificationManager(context).notify(
            AppDefine.NOTIFICATION_CHANNEL_ID_NUMBER,
            getNotification(context, title, message).build()
        )
    }

    private fun getNotification(context: Context, title: String, message: String): NotificationCompat.Builder {
        createNotificationChannel(
            context,
            AppDefine.NOTIFICATION_CHANNEL_ID,
            AppDefine.NOTIFICATION_CHANNEL_NAME,
            NotificationManager.IMPORTANCE_HIGH
        )

        return NotificationCompat.Builder(
            context,
            AppDefine.NOTIFICATION_CHANNEL_ID
        )
            .run {
                setContentTitle(title)
                setContentText(message)
                setWhen(System.currentTimeMillis())
                setSmallIcon(R.mipmap.ic_main)
                setAutoCancel(true)
            }
    }

    private fun createNotificationChannel(
        context: Context,
        id: String,
        name: CharSequence,
        importance: Int
    ) {
        val channel = NotificationChannel(id, name, importance)
        getNotificationManager(context).createNotificationChannel(channel)
    }

    private fun getNotificationManager(context: Context): NotificationManager {
        return context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }
}