package com.summit.hackerton.remote

import com.google.gson.GsonBuilder
import com.google.gson.JsonParser
import com.summit.hackerton.BuildConfig
import com.summit.hackerton.base.adapter.LocalDateAdapter
import com.summit.hackerton.base.adapter.LocalDateTimeAdapter
import com.summit.hackerton.base.extension.isJson
import com.summit.hackerton.remote.interceptor.MobiusAuthInterceptor
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import timber.log.Timber
import java.time.LocalDate
import java.time.LocalDateTime
import java.util.concurrent.TimeUnit

/**
 *
 *
 * @author Brand
 * @created 2023-05-22
 **/
object ApiFactory {
    private const val LOG_TAG = "NETWORK"

    private const val READ_TIME_OUT     = 10L
    private const val WRITE_TIME_OUT    = 10L
    private const val CALL_TIME_OUT     = 10L
    private const val CONNECT_TIME_OUT  = 10L

    val client by lazy { createClient() }

    private fun createClient(): Retrofit {
        return Retrofit.Builder()
            .baseUrl(BuildConfig.API_SERVER_BASE_URL)
            .addConverterFactory(
                GsonConverterFactory.create(
                    GsonBuilder()
                        .registerTypeAdapter(LocalDate::class.java, LocalDateAdapter())
                        .registerTypeAdapter(LocalDateTime::class.java, LocalDateTimeAdapter())
                        .create()
                )
            )
            .client(
                OkHttpClient.Builder()
                    .readTimeout(READ_TIME_OUT, TimeUnit.SECONDS)
                    .connectTimeout(CONNECT_TIME_OUT, TimeUnit.SECONDS)
                    .writeTimeout(WRITE_TIME_OUT, TimeUnit.SECONDS)
                    .callTimeout(CALL_TIME_OUT, TimeUnit.SECONDS)
                    .addInterceptor(MobiusAuthInterceptor)
                    .addInterceptor(
                        HttpLoggingInterceptor {
                            try {
                                if (it.isJson()) {
                                    Timber.tag(LOG_TAG).i(
                                        GsonBuilder()
                                            .setPrettyPrinting()
                                            .create()
                                            .toJson(JsonParser.parseString(it))
                                    )
                                } else {
                                    Timber.tag(LOG_TAG).i(it)
                                }
                            } catch (e: Exception) {
                                e.printStackTrace()
                            }
                        }.setLevel(
                            if (BuildConfig.DEBUG)
                                HttpLoggingInterceptor.Level.BODY
                            else
                                HttpLoggingInterceptor.Level.NONE
                        )
                    )
                    .build()
            ).build()
    }
}