package com.summit.hackerton.remote.mobius.request.tlci.depth

import com.google.gson.annotations.SerializedName

data class TlCiRequest(
    @SerializedName("m2m:agr")
    val m2m_cin: M2mCin
)