package com.summit.hackerton.remote.mobius.response.tlgroup.depth

import com.google.gson.annotations.SerializedName

data class M2mAgr(
    @SerializedName("m2m:rsp")
    val m2m_rsp: List<M2mRsp>
)