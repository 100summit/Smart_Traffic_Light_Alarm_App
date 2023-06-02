package com.summit.hackerton.remote.mobius.response.tlgroup

import com.google.gson.annotations.SerializedName
import com.summit.hackerton.remote.mobius.response.tlgroup.depth.M2mAgr

/**
 *
 *
 * @author Brand
 * @created 2023-05-22
 **/
data class TlGroupResponse(
    @SerializedName("m2m:agr")
    val m2m_agr: M2mAgr
)
