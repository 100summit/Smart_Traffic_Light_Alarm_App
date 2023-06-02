package com.summit.hackerton.remote.api

import com.summit.hackerton.remote.ApiFactory
import com.summit.hackerton.remote.common.response.MobiusApiCallback
import com.summit.hackerton.remote.common.response.MobiusApiCallbackHandler
import com.summit.hackerton.remote.mobius.request.tlci.depth.TlCiRequest
import com.summit.hackerton.remote.mobius.response.tlci.depth.TlCiResponse
import com.summit.hackerton.remote.mobius.response.tlgroup.TlGroupResponse
import com.summit.hackerton.remote.mobius.response.tlstate.depth.TlStateResponse

/**
 *
 *
 * @author Brand
 * @created 2023-05-22
 **/
object MobiusApi {
    private val mobiusService: MobiusApiService =
        ApiFactory.client.create(MobiusApiService::class.java)

    /**
     * 신호등 그룹 조회
     *
     * @author Brand
     * @since 2023/05/22
     **/
    fun requestTlGroup(
        callback: MobiusApiCallback<TlGroupResponse>
    ) {
        mobiusService.requestTlGroup().enqueue(MobiusApiCallbackHandler(callback = callback))
    }


    /**
    * 신호등 단일 상태 조회
    *
    * @author Sean
    * @since 2023/06/02
    **/
    fun requestTlState(
        target : String,
        callback: MobiusApiCallback<TlStateResponse>
    ) {
        mobiusService.requestTlState("/Mobius/$target/state/la").enqueue(MobiusApiCallbackHandler(callback = callback))
    }


    /**
     * 횡단 정보 저장
     *
     * @author Sean
     * @since 2023/06/02
     **/
    fun requestCi(
        data : TlCiRequest,
        target : String,
        callback: MobiusApiCallback<TlCiResponse>
    ) {
        mobiusService.requestTlCi("/Mobius/$target/ci", data).enqueue(MobiusApiCallbackHandler(callback = callback))
    }
}