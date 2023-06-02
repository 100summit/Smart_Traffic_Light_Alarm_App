package com.summit.hackerton.remote.mobius.request.tlci.depth

data class Con(
    val ais: String,
    val timestamp: String,
    val tl_id: String,
    val user_state: String,
    val uuid: String,
    val w_kind: String,
    val w_time: Int
)