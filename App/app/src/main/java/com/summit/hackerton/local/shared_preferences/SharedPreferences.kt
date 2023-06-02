package com.summit.hackerton.local.shared_preferences

/**
 * @author Brand
 * @created 2023-03-20
 **/
object SharedPreferences {
    private val commonHelper: EncryptPreferenceHelper by lazy {
        EncryptPreferenceHelper(SharedPreferencesDefine.File.COMMON)
    }

    //----------------------------------------------------------------
    // MARK : User
    //----------------------------------------------------------------
    /**
     * 유저 UUID 불러오기
     *
     * @author Brand
     * @since 2023/03/20
     **/
    fun getUserUuid(): String {
        return commonHelper.getString(SharedPreferencesDefine.Data.USER_UUID,"test")!!
    }

    /**
     * 유저 UUID 저장
     *
     * @author Brand
     * @since 2023/03/20
     **/
    fun setUserUuid(enabled: String) {
        commonHelper.set(
            key = SharedPreferencesDefine.Data.USER_UUID,
            value = enabled
        )
    }



    /**
    * 유저정보 가져오기
    *
    * @author Sean
    * @since 2023/06/02
    **/
    fun getUser(key : String): String {
        return commonHelper.getString(key,"")!!
    }

    /**
    * 유저정보 저장
    *
    * @author Sean
    * @since 2023/06/02
    **/
    fun setUser(key : String, enabled: String) {
        commonHelper.set(
            key = key,
            value = enabled
        )
    }
}