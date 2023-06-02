package com.summit.hackerton.view

import android.content.Intent
import android.location.LocationManager
import android.os.Bundle
import android.provider.Settings
import android.widget.Toast
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.google.gson.Gson
import com.summit.hackerton.R
import com.summit.hackerton.databinding.ActivityLoginBinding
import com.summit.hackerton.define.AppDefine
import com.summit.hackerton.define.AppDefine.me
import com.summit.hackerton.local.data.UserInfo
import com.summit.hackerton.local.shared_preferences.SharedPreferences
import com.summit.hackerton.utils.PermissionUtils
import timber.log.Timber

/**
 *
 *
 * @author Brand
 * @created 2023-05-22
 **/
class LoginActivity : AppCompatActivity() {

    private lateinit var binding: ActivityLoginBinding

    private var lastBackPressedTime = 0L    // Back Button 누른 시간

    private lateinit var permissionLauncher: ActivityResultLauncher<Array<String>>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_login)

        initResource()

        permissionLauncher = registerForActivityResult(
            ActivityResultContracts.RequestMultiplePermissions(),
            this::onPermissionCallback
        )

        checkPermission()
    }

    /**
     * 권한 체크
     *
     * @author Brand
     * @since 2023/04/03
     **/
    private fun checkPermission() {
        val isPermissionGranted = PermissionUtils.isAllPermissionGranted(
            context = this,
            permissions = AppDefine.NEED_PERMISSIONS
        )

        if (!isPermissionGranted) {
            permissionLauncher.launch(AppDefine.NEED_PERMISSIONS)
        }
    }

    /**
     * 권한 요청 Callback
     *
     * @author Brand
     * @since 2023/04/03
     **/
    private fun onPermissionCallback(result: Map<String, Boolean>) {
        Timber.i("result is $result")

        result.forEach {
            if (!it.value) {
                Toast.makeText(this, "권한을 허용해야 합니다.", Toast.LENGTH_SHORT).show()
                return
            }
        }
    }

    /**
     * 리소스 동작 init
     *
     * @author Brand
     * @since 2023/05/22
     **/
    private fun initResource() {
        binding.loginBtn.setOnClickListener {
            if(SharedPreferences.getUser(binding.nicknameEditTextView.text.toString()).isEmpty()){
                Toast.makeText(this, "가입되지 않은 사용자입니다.", Toast.LENGTH_LONG).show()
                return@setOnClickListener
            }
            me = Gson().fromJson(SharedPreferences.getUser(binding.nicknameEditTextView.text.toString()), UserInfo::class.java)
            moveMain()
            finish()
        }

        binding.signTextView.setOnClickListener {
            moveSign()
        }
    }

    /**
     * 메인 화면으로 이동
     *
     * @author Brand
     * @since 2023/05/22
     **/
    private fun moveMain() {
        startActivity(Intent(this@LoginActivity, MainActivity::class.java))
    }

    /**
     * 회원가입 화면으로 이동
     *
     * @author Brand
     * @since 2023/05/23
     **/
    private fun moveSign() {
        startActivity(Intent(this@LoginActivity, SignActivity::class.java))
    }

    private fun isFinishingApp(): Boolean {
        val now = System.currentTimeMillis()
        val isFinishingApp = now - lastBackPressedTime <= 2000L
        if(!isFinishingApp) {
            lastBackPressedTime = now
        }
        return isFinishingApp
    }

    override fun onBackPressed() {
        if (isFinishingApp()) {
            finishAffinity()
        } else {
            Toast.makeText(this, getString(R.string.quick_tap_twice_back_button), Toast.LENGTH_SHORT).show()
        }
    }
}