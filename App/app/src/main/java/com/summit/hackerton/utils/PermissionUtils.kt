package com.summit.hackerton.utils

import android.content.Context
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat

/**
 * @author Brand
 * @created 2023-04-03
 **/
object PermissionUtils {

    /**
     * check permission is granted
     *
     * @author Brand
     * @since 2023/04/03
     **/
    fun isPermissionGranted(
        context: Context,
        permission: String
    ): Boolean {
        return (ContextCompat.checkSelfPermission(context, permission)
                == PackageManager.PERMISSION_GRANTED)
    }

    fun isAllPermissionGranted(
        context: Context,
        permissions: Array<String>
    ): Boolean {
        var isGranted = true

        for (permission in permissions) {
            if (!isPermissionGranted(context, permission)) {
                isGranted = false
                break
            }
        }

        return isGranted
    }
}