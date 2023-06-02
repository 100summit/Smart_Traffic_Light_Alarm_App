package com.summit.hackerton.remote.common.response

import retrofit2.Call
import retrofit2.Callback
import retrofit2.HttpException
import retrofit2.Response

/**
 *
 *
 * @author Brand
 * @created 2023-05-22
 **/
typealias MobiusApiCallback<T> = (MobiusApiResult<T>) -> Unit

sealed class MobiusApiResult<T> {
    data class Success<T>(val data: T?) : MobiusApiResult<T>()
    data class Error<T>(val exception: Throwable) : MobiusApiResult<T>()
}

class MobiusApiCallbackHandler<T : Any>(
    private val callback: MobiusApiCallback<T>?
) : Callback<T> {
    /* Network Success */
    override fun onResponse(call: Call<T>, response: Response<T>) {
        val errorBody = response.errorBody()?.string()
        var result: MobiusApiResult<T>? = null
        when {
            // http status code 200 ~ 299
            response.isSuccessful -> result = MobiusApiResult.Success(data = response.body())
            // fail with server error code
            !errorBody.isNullOrEmpty() -> result =
                MobiusApiResult.Error(exception = HttpException(response))
        }

        result?.let { apiResult ->
            callback?.invoke(apiResult)
        } ?: run {
            callback?.invoke(MobiusApiResult.Error(exception = HttpException(response)))
        }
    }

    /* Network Fail */
    override fun onFailure(call: Call<T>, throwable: Throwable) {
        throwable.printStackTrace()
        callback?.invoke(MobiusApiResult.Error(exception = throwable))
    }
}