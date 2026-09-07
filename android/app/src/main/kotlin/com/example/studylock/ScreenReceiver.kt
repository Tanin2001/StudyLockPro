package com.example.studylock
import android.content.*
class ScreenReceiver:BroadcastReceiver(){
 override fun onReceive(c:Context,i:Intent){if(!StudyService.running(c))return;val x=Intent(c,StudyService::class.java);x.action=i.action;if(android.os.Build.VERSION.SDK_INT>=26)c.startForegroundService(x)else c.startService(x)}
}
