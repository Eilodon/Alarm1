package com.pandora.core

import android.app.Application

class PandoraApp : Application() {
    override fun onCreate() {
        super.onCreate()
        // Khởi tạo các thành phần toàn cục nếu cần
        android.util.Log.d("PandoraApp", "PandoraApp started")
    }
}
