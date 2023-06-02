package com.summit.hackerton.remote.api

import com.summit.hackerton.remote.mobius.request.tlci.depth.TlCiRequest
import com.summit.hackerton.remote.mobius.response.tlci.depth.TlCiResponse
import com.summit.hackerton.remote.mobius.response.tlgroup.TlGroupResponse
import com.summit.hackerton.remote.mobius.response.tlstate.depth.TlStateResponse
import retrofit2.Call
import retrofit2.http.*

/**
 *
 *
 * @author Brand
 * @created 2023-05-22
 **/
interface MobiusApiService {

    companion object {
        // 신호등 그룹 조회
        private const val TL_GROUP = "/Mobius/grp_tl_info/fopt"
    }

    /**
     * 신호등 그룹 조회
     *
     * @author Brand
     * @since 2023/05/22
     **/
    @GET(TL_GROUP)
    fun requestTlGroup(): Call<TlGroupResponse>


    @GET
    fun requestTlState(@Url url : String): Call<TlStateResponse>


    @Headers("Accept : application/json" , "X-M2M-Origin : Summit", "X-M2M-RI : 1234")
    @POST
    fun requestTlCi(@Url url : String, @Body data : TlCiRequest): Call<TlCiResponse>
}