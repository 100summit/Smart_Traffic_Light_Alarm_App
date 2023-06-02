package com.summit.hackerton.local.data

import com.summit.hackerton.remote.mobius.response.tlgroup.TlGroupResponse

/**
 *
 *
 * @author Brand
 * @created 2023-05-24
 **/
data class UserInfo (
    var userName: String = "",
    
    var userUuid: String = "",

    var userType: String = "normal",

    var phoneNumber: String = "false"
)