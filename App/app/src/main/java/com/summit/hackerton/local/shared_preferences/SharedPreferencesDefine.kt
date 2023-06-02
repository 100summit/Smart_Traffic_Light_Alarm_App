package com.summit.hackerton.local.shared_preferences

/**
 * @author Brand
 * @created 2023-03-20
 **/
interface SharedPreferencesDefine {
    interface File {
        companion object {
            const val COMMON = "common"
        }
    }

    interface Data {
        companion object {
            const val USER_UUID = "user_uud"
        }
    }
}