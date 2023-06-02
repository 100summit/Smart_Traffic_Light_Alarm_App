package com.summit.hackerton.view

import android.annotation.SuppressLint
import android.os.Bundle
import android.provider.Settings
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.databinding.DataBindingUtil
import com.google.gson.Gson
import com.summit.hackerton.R
import com.summit.hackerton.databinding.ActivitySignBinding
import com.summit.hackerton.local.data.UserInfo
import com.summit.hackerton.local.shared_preferences.SharedPreferences

/**
 *
 *
 * @author Brand
 * @created 2023-05-22
 **/
class SignActivity : AppCompatActivity() {

    private lateinit var binding: ActivitySignBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_sign)

        initResource()
    }

    /**
     * 리소스 동작 init
     *
     * @author Brand
     * @since 2023/05/22
     **/
    private fun initResource() {
        binding.authNumberBtn.setOnClickListener {
            Toast.makeText(this, "Verification code sent.", Toast.LENGTH_SHORT).show()
        }

        binding.authNumberConfirmBtn.setOnClickListener {
            Toast.makeText(this, "Confirmed.", Toast.LENGTH_SHORT).show()
        }

        binding.signBtn.setOnClickListener {
            SharedPreferences.setUserUuid(getDeviceUuid()!!)

            val data = UserInfo(
                userName = binding.nicknameEditTextView.text.toString(),
                userUuid = getDeviceUuid()!!,
                userType = "weak",
                phoneNumber = binding.numberEditTextView.text.toString()
            )

            SharedPreferences.setUser(data.userName, Gson().toJson(data))

            Toast.makeText(this, "Sign up is complete.", Toast.LENGTH_SHORT).show()
            finish()
        }

        binding.backBtn.setOnClickListener {
            finish()
        }
    }

    @SuppressLint("HardwareIds")
    fun getDeviceUuid() : String? {
        return Settings.Secure.getString(
            baseContext.contentResolver,
            Settings.Secure.ANDROID_ID
        )
    }
}