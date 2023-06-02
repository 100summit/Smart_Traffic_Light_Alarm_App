package com.summit.hackerton.local.shared_preferences

import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKeys
import com.summit.hackerton.Application
import timber.log.Timber

/**
 * @author Brand
 * @created 2023-03-20
 **/
class EncryptPreferenceHelper(fileName: String) {
    // Although you can define your own key generation parameter specification, it's
    // recommended that you use the value specified here.
    private val keyGenParameterSpec = MasterKeys.AES256_GCM_SPEC
    private val mainKeyAlias = MasterKeys.getOrCreate(keyGenParameterSpec)

    private val prefs: SharedPreferences = EncryptedSharedPreferences.create(
        fileName,
        mainKeyAlias,
        Application.instance.applicationContext,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )

    @Suppress("UNCHECKED_CAST")
    fun set(key: String, value: Any?) {
        prefs.edit().let {
            when (value) {
                is String? -> it.putString(key, value)
                is Int -> it.putInt(key, value)
                is Boolean -> it.putBoolean(key, value)
                is Float -> it.putFloat(key, value)
                is Double -> putDouble(key, value)
                is Long -> it.putLong(key, value)
                else -> Timber.e("Unknown")
            }
            it.commit()
        }
    }

    private fun putDouble(key: String, value: Double) {
        prefs.edit().apply {
            putLong(key, java.lang.Double.doubleToRawLongBits(value))
            apply()
        }
    }

    fun getDouble(key: String, default: Double) =
        java.lang.Double.longBitsToDouble(
            getLong(
                key,
                java.lang.Double.doubleToRawLongBits(default)
            )
        )

    fun getString(key: String, default: String?): String? {
        return prefs.getString(key, default)
    }

    fun getInt(key: String, default: Int): Int {
        return prefs.getInt(key, default)
    }

    fun getLong(key: String, default: Long): Long {
        return prefs.getLong(key, default)
    }

    fun getBoolean(key: String, default: Boolean): Boolean {
        return prefs.getBoolean(key, default)
    }

    fun getFloat(key: String, default: Float): Float {
        return prefs.getFloat(key, default)
    }

    fun remove(key: String) {
        prefs.edit().let {
            it.remove(key)
            it.commit()
        }
    }
}