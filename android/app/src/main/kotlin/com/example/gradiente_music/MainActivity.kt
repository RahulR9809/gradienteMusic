package com.gradientemusic.gradiente_music

import android.content.Context;
import com.ryanheise.audioservice.AudioServicePlugin;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine;

//   If Use Stripe :======> FlutterFragmentActivity 
//   If NOT Use Stripe :==> FlutterActivity

class MainActivity: FlutterFragmentActivity() {
    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return AudioServicePlugin.getFlutterEngine(context)
    }
}
