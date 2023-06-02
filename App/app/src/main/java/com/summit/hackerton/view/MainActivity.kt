package com.summit.hackerton.view

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.*
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import android.view.View
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.databinding.DataBindingUtil
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase
import com.summit.hackerton.R
import com.summit.hackerton.databinding.ActivityMainBinding
import com.summit.hackerton.define.AppDefine.crossWalkTargetTrafficLight
import com.summit.hackerton.define.AppDefine.enterTime
import com.summit.hackerton.define.AppDefine.exitTime
import com.summit.hackerton.define.AppDefine.getTime
import com.summit.hackerton.define.AppDefine.me
import com.summit.hackerton.define.AppDefine.nowTargetTlState
import com.summit.hackerton.local.data.TrafficLightInfo
import com.summit.hackerton.remote.api.MobiusApi
import com.summit.hackerton.remote.common.response.MobiusApiResult
import com.summit.hackerton.remote.mobius.request.tlci.depth.Con
import com.summit.hackerton.remote.mobius.request.tlci.depth.M2mCin
import com.summit.hackerton.remote.mobius.request.tlci.depth.TlCiRequest
import com.summit.hackerton.remote.mobius.response.tlstate.depth.TlStateResponse
import com.summit.hackerton.service.CrossWalkService
import com.summit.hackerton.service.TrafficService
import com.summit.hackerton.utils.NotificationUtils
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import timber.log.Timber
import java.text.SimpleDateFormat
import java.util.*


private val MY_PERMISSIONS_REQ_ACCESS_FINE_LOCATION = 100
private val MY_PERMISSIONS_REQ_ACCESS_BACKGROUND_LOCATION = 101

class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding

    private var lastBackPressedTime = 0L    // Back Button 누른 시간




    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_main)

        getTlGroup()

        initResource()
    }

    /**
     * 리소스 동작 정의
     *
     * @author Brand
     * @since 2023/05/23
     **/
    private fun initResource() {
        binding.notiSwitch.setOnCheckedChangeListener { _, isChecked ->
            if (isChecked) {
                startService(Intent(this@MainActivity, TrafficService::class.java))
            } else {
                stopService(Intent(this@MainActivity, TrafficService::class.java))
            }
        }
    }

    /**
     * 신호등 그룹 가져오기
     *
     * @author Brand
     * @since 2023/05/22
     **/
    private fun getTlGroup() {
        CoroutineScope(Dispatchers.IO).launch {
            MobiusApi.requestTlGroup { result ->
                when (result) {
                    is MobiusApiResult.Success -> {
                        TrafficLightInfo.trafficLightList = result.data
                    }
                    is MobiusApiResult.Error -> {}
                }
            }
        }
    }

    /**
    * 횡단 정보 전송
    *
    * @author Sean
    * @since 2023/06/02
    **/
    fun requestCi(requestId: String, w_kind: String, ais: String) {
        CoroutineScope(Dispatchers.IO).launch {
            val gap = ((exitTime - enterTime) / 1000).toInt()
            MobiusApi.requestCi(TlCiRequest(m2m_cin = M2mCin(con = Con(
                ais = ais,
                timestamp = getTime(),
                tl_id= requestId,
                user_state=me.userType,
            uuid= me.userUuid,
            w_kind= w_kind,
            w_time= gap
            ))),requestId) { result ->
                when (result) {
                    is MobiusApiResult.Success -> {
                        Log.d("requestCi", "ok")
                    }
                    is MobiusApiResult.Error -> {}
                }
            }
        }
        enterTime = 0L
        exitTime = 0L
    }


    /**
     * firebase database
     *
     * @author Brand
     * @since 2023/05/23
     **/
    fun fireStoreRequest(tl : String, enter : Boolean) {
        val db = Firebase.firestore
        db.collection("STL")
            .get()
            .addOnSuccessListener { result ->
                for (document in result) {
                    Timber.d("FireStore ${document.id} => ${document.data}")
                }
            }
            .addOnFailureListener { exception ->
                Timber.d("FireStore Error getting documents. $exception")
            }

        val stl = hashMapOf(
            "ready" to enter,
            "tl" to tl,
            "userType" to me.userType,
            "uuid" to me.userUuid
        )
        val now = System.currentTimeMillis()
        val date = Date(now)

        val dateFormat = SimpleDateFormat("yyyyMMddHHmmss")
        val getTime = dateFormat.format(date)

        db.collection("STL").document(getTime)
            .set(stl)
            .addOnSuccessListener { Timber.d("FireStore DocumentSnapshot successfully written!") }
            .addOnFailureListener { e -> Timber.d("FireStore Error getting documents. $e") }
    }




    fun setNowTrafficLight(data: TlStateResponse, requestId: String){
        val nowTime = SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(getTime())
        val serverTime = SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(data.m2m_cin.con.time)
        val gap = ((nowTime.time - serverTime.time) / 1000).toInt()

        // 횡단 여부 판단용 GeoFence 등록
        startService(Intent(this@MainActivity, CrossWalkService::class.java))

        // 해당 횡단 보도의 횡단 탐지 영역 등록
        crossWalkTargetTrafficLight = TrafficLightInfo.getGeofenceListTrafficLight()[requestId.removeRange(0,2).toInt()]

        when(data.m2m_cin.con.state)
        {
            "green" -> {
                setGreenLight(data.m2m_cin.con.g_time - gap)
            }
            "red" -> {
                setRedLight(data.m2m_cin.con.r_time - gap)
            }
        }
    }

    /**
     * 빨간불 메소드
     *
     * @author Brand
     * @since 2023/06/01
     **/
    fun setRedLight(timer : Int) {
        nowTargetTlState  = "red"
            runOnUiThread {
                binding.walkAnimation.pauseAnimation()
                binding.redLightAnimation.visibility = View.VISIBLE
                binding.stayTime.visibility = View.VISIBLE

                val countDown = object : CountDownTimer(timer * 1000L, 1000) {
                    override fun onTick(millisUntilFinished: Long) {
                        val seconds = millisUntilFinished / 1000
                        val timeString = String.format("%02d", seconds % 60)
                        binding.stayTime.text = timeString

                    }

                    override fun onFinish() {
                        binding.stayTime.text = "00"
                    }
                }
                countDown.start()
            }
    }

    /**
     * 초록불 메소드
     *
     * @author Brand
     * @since 2023/06/01
     **/
    fun setGreenLight(timer : Int) {
        nowTargetTlState  = "green"
        runOnUiThread {
            binding.walkAnimation.resumeAnimation()
            binding.redLightAnimation.visibility = View.GONE
            binding.greenLightAnimation.visibility = View.VISIBLE
            NotificationUtils.sendNotification(this, "alert", "The green light came on. please cross.")

            val countDown = object : CountDownTimer(timer * 1000L, 1000) {
                override fun onTick(millisUntilFinished: Long) {
                    // Update the TextView with the remaining time
                    val seconds = millisUntilFinished / 1000
                    val timeString = String.format("%02d", seconds % 60)
                    binding.stayTime.text = timeString
                }

                override fun onFinish() {
                    // Timer finished, handle accordingly
                    binding.stayTime.text = "00"
                }
            }
            countDown.start()
        }
    }


    /**
    * 지오펜스 백그라운드 권한 확인
    *
    * @author Sean
    * @since 2023/06/02
    **/
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        when (requestCode) {
            MY_PERMISSIONS_REQ_ACCESS_FINE_LOCATION,
            MY_PERMISSIONS_REQ_ACCESS_BACKGROUND_LOCATION -> {
                grantResults.apply {
                    if (this.isNotEmpty()) {
                        this.forEach {
                            if (it != PackageManager.PERMISSION_GRANTED) {
                                checkPermission()
                                return
                            }
                        }
                    } else {
                        checkPermission()
                    }
                }
            }
        }
    }

    private fun checkPermission() {
        val permissionAccessFineLocationApproved = ActivityCompat
            .checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) ==
                PackageManager.PERMISSION_GRANTED

        if (permissionAccessFineLocationApproved) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val backgroundLocationPermissionApproved = ActivityCompat
                    .checkSelfPermission(this, Manifest.permission.ACCESS_BACKGROUND_LOCATION) ==
                        PackageManager.PERMISSION_GRANTED

                if (!backgroundLocationPermissionApproved) {
                    ActivityCompat.requestPermissions(
                        this,
                        arrayOf(Manifest.permission.ACCESS_BACKGROUND_LOCATION),
                        MY_PERMISSIONS_REQ_ACCESS_BACKGROUND_LOCATION
                    )
                }
            }
        } else {
            ActivityCompat.requestPermissions(this,
                arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
                MY_PERMISSIONS_REQ_ACCESS_FINE_LOCATION
            )
        }
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