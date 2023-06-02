package com.summit.hackerton.remote.interceptor

import okhttp3.Interceptor
import okhttp3.Response

/**
 *
 *
 * @author Brand
 * @created 2023-05-22
 **/
object MobiusAuthInterceptor : Interceptor {
    private const val ACCEPT = "Accept"
    private const val X_M2M_RI = "X-M2M-RI"
    private const val X_M2M_Origin = "X-M2M-Origin"

    override fun intercept(chain: Interceptor.Chain): Response {
        val origin = chain.request()
        val request = origin.newBuilder()
            .addHeader(ACCEPT, "application/json")
            .addHeader(X_M2M_RI, "12345")
            .addHeader(X_M2M_Origin, "Summit")
        return chain.proceed(request = request.build())
    }
}