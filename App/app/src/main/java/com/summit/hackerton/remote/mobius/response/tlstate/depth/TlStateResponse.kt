package com.summit.hackerton.remote.mobius.response.tlstate.depth

import com.google.gson.annotations.SerializedName

data class TlStateResponse(
    @SerializedName("m2m:cin")
    val m2m_cin: M2mCin
)