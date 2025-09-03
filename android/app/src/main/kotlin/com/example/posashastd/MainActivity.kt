package com.example.posashastd

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.provider.Settings
import android.content.Context
import java.net.NetworkInterface
import java.util.*

class MainActivity : FlutterActivity() {
    private val CHANNEL = "device_info"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAndroidId" -> {
                    val androidId = getAndroidId()
                    if (androidId != null) {
                        result.success(androidId)
                    } else {
                        result.error("UNAVAILABLE", "Android ID not available.", null)
                    }
                }
                "getMacAddress" -> {
                    val macAddress = getMacAddress()
                    if (macAddress != null) {
                        result.success(macAddress)
                    } else {
                        result.error("UNAVAILABLE", "MAC Address not available.", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getAndroidId(): String? {
        return try {
            Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
        } catch (e: Exception) {
            null
        }
    }

    private fun getMacAddress(): String? {
        return try {
            val networkInterfaces = Collections.list(NetworkInterface.getNetworkInterfaces())

            // ลองหา wlan0 ก่อน
            for (networkInterface in networkInterfaces) {
                if (networkInterface.name.equals("wlan0", ignoreCase = true)) {
                    val macBytes = networkInterface.hardwareAddress
                    if (macBytes != null) {
                        val macAddress = StringBuilder()
                        for (b in macBytes) {
                            macAddress.append(String.format("%02X:", b))
                        }
                        if (macAddress.isNotEmpty()) {
                            macAddress.deleteCharAt(macAddress.length - 1) // ลบ : ตัวสุดท้าย
                        }
                        return macAddress.toString()
                    }
                }
            }

            // ถ้าไม่เจอ wlan0 ให้ลองหา network interface อื่นๆ
            for (networkInterface in networkInterfaces) {
                if (!networkInterface.name.startsWith("lo") && // ไม่ใช่ loopback
                    networkInterface.isUp && // interface ทำงานอยู่
                    !networkInterface.isLoopback) { // ไม่ใช่ loopback

                    val macBytes = networkInterface.hardwareAddress
                    if (macBytes != null && macBytes.isNotEmpty()) {
                        val macAddress = StringBuilder()
                        for (b in macBytes) {
                            macAddress.append(String.format("%02X:", b))
                        }
                        if (macAddress.isNotEmpty()) {
                            macAddress.deleteCharAt(macAddress.length - 1) // ลบ : ตัวสุดท้าย
                        }
                        return macAddress.toString()
                    }
                }
            }

            // ถ้ายังไม่เจอ ให้ใช้ Android ID แทน
            val androidId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
            if (androidId != null && androidId.isNotEmpty()) {
                // แปลง Android ID เป็นรูปแบบ MAC Address
                val cleanId = androidId.take(12) // เอา 12 ตัวแรก
                val macLike = StringBuilder()
                for (i in cleanId.indices step 2) {
                    if (i + 1 < cleanId.length) {
                        macLike.append(cleanId.substring(i, i + 2))
                        if (i + 2 < cleanId.length) {
                            macLike.append(":")
                        }
                    }
                }
                return macLike.toString().uppercase()
            }

            null
        } catch (e: Exception) {
            // ถ้าเกิดข้อผิดพลาด ให้ใช้ timestamp แทน
            val timestamp = System.currentTimeMillis().toString()
            val macLike = StringBuilder()
            val cleanTimestamp = timestamp.takeLast(12) // เอา 12 ตัวท้าย
            for (i in cleanTimestamp.indices step 2) {
                if (i + 1 < cleanTimestamp.length) {
                    macLike.append(cleanTimestamp.substring(i, i + 2))
                    if (i + 2 < cleanTimestamp.length) {
                        macLike.append(":")
                    }
                }
            }
            return macLike.toString().uppercase()
        }
    }
}
