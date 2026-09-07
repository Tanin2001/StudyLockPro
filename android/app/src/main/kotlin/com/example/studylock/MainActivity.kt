package com.example.studylock
import android.content.*
import android.os.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
 private val channel="study_lock/native"
 override fun configureFlutterEngine(engine: FlutterEngine) {
  super.configureFlutterEngine(engine)
  MethodChannel(engine.dartExecutor.binaryMessenger,channel).setMethodCallHandler { call,result ->
   val i=Intent(this,StudyService::class.java)
   when(call.method){
    "start"->{i.action="START";startServiceCompat(i);result.success(null)}
    "pause"->{i.action="PAUSE";startServiceCompat(i);result.success(null)}
    "reset"->{i.action="RESET";startServiceCompat(i);result.success(null)}
    "state"->{result.success(StudyService.state(this))}
    else->result.notImplemented()
   }
  }
 }
 private fun startServiceCompat(i:Intent){if(Build.VERSION.SDK_INT>=26)startForegroundService(i) else startService(i)}
}
