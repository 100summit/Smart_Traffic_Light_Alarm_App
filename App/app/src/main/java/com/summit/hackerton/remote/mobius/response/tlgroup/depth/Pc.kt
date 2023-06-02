package com.summit.hackerton.remote.mobius.response.tlgroup.depth

import com.google.gson.annotations.SerializedName

data class Pc(
    @SerializedName("m2m:cin")
    val m2m_cin: M2mCin
)