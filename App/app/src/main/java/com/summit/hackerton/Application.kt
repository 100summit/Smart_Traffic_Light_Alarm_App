package com.summit.hackerton

import android.annotation.SuppressLint
import android.app.Activity
import android.app.Application
import android.os.Bundle
import androidx.appcompat.app.AppCompatDelegate
import com.google.firebase.FirebaseApp
import com.summit.hackerton.utils.TimberLogTree
import timber.log.Timber

/**
 *
 *
 * @author Brand
 * @created 2023-05-22
 **/
class Application : Application() {

    var activeActivity: Activity? = null

    companion object {
        @SuppressLint("StaticFieldLeak")
        lateinit var instance: Application
            private set
    }

    @SuppressLint("BinaryOperationInTimber")
    override fun onCreate() {
        super.onCreate()

        instance = this

        initLogger()
        registerActivityLifecycleCallbacks()

        // 다크모드 비활성화
        AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO)
    }

    /**
     * initialize logger - timber
     *
     * @author Brand
     * @since 2023/03/14
     **/
    private fun initLogger() {
        Timber.plant(TimberLogTree(prefix = this::class.java.simpleName))
    }

    /**
     * registerActivityLifecycleCallbacks
     * 1) monitoring active activity
     *
     * @author Brand
     * @since 2023/03/14
     **/
    private fun registerActivityLifecycleCallbacks() {
        registerActivityLifecycleCallbacks(object : ActivityLifecycleCallbacks {
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}
            override fun onActivityStarted(activity: Activity) {}
            override fun onActivityResumed(activity: Activity) {
                activeActivity = activity
            }

            override fun onActivityPaused(activity: Activity) {
                activeActivity = null
            }

            override fun onActivityStopped(activity: Activity) {}
            override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
            override fun onActivityDestroyed(activity: Activity) {}
        })
    }
}