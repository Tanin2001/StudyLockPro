package com.example.studylock
import android.app.*
import android.content.*
import android.os.*
import java.text.SimpleDateFormat
import java.util.*

class StudyService: Service(){
 companion object{
  const val P="study"; const val RUN="run"; const val TOTAL="total"; const val LAST="last"; const val TODAY="today"; const val DAY="day"; const val CH="study_lock"
  fun p(c:Context)=c.getSharedPreferences(P,0)
  fun off(c:Context)=!(c.getSystemService(Context.POWER_SERVICE) as PowerManager).isInteractive
  fun running(c:Context)=p(c).getBoolean(RUN,false)
  fun elapsed(c:Context):Long{val x=p(c);var t=x.getLong(TOTAL,0);if(x.getBoolean(RUN,false)&&off(c))t+=System.currentTimeMillis()-x.getLong(LAST,System.currentTimeMillis());return t}
  fun today(c:Context):Long{val x=p(c);val d=SimpleDateFormat("yyyyMMdd",Locale.US).format(Date());return if(x.getString(DAY,"")==d)x.getLong(TODAY,0) else 0}
  fun state(c:Context):Map<String,Any>{return mapOf("elapsed" to elapsed(c),"today" to today(c),"running" to running(c),"screenOff" to off(c))}
 }
 override fun onCreate(){super.onCreate();channel();startForeground(11,note())}
 override fun onStartCommand(i:Intent?,f:Int,id:Int):Int{
  val a=i?.action
  when(a){
   "START"->{p(this).edit().putBoolean(RUN,true).putLong(LAST,System.currentTimeMillis()).apply()}
   "PAUSE"->{checkpoint();p(this).edit().putBoolean(RUN,false).apply()}
   "RESET"->{p(this).edit().putBoolean(RUN,false).putLong(TOTAL,0).putLong(TODAY,0).apply()}
   Intent.ACTION_SCREEN_OFF,Intent.ACTION_SCREEN_ON->if(running(this))checkpoint()
  }
  return START_STICKY
 }
 private fun checkpoint(){val x=p(this);val e=elapsed(this);val d=SimpleDateFormat("yyyyMMdd",Locale.US).format(Date());val old=x.getString(DAY,"");var td=if(old==d)x.getLong(TODAY,0) else 0;if(x.getBoolean(RUN,false)&&off(this)){val add=e-x.getLong(TOTAL,0);if(add>0)td+=add};x.edit().putLong(TOTAL,e).putLong(TODAY,td).putString(DAY,d).putLong(LAST,System.currentTimeMillis()).apply()}
 private fun channel(){if(Build.VERSION.SDK_INT>=26)(getSystemService(NOTIFICATION_SERVICE) as NotificationManager).createNotificationChannel(NotificationChannel(CH,"Study Lock",NotificationManager.IMPORTANCE_LOW))}
 private fun note():Notification{val pi=PendingIntent.getActivity(this,0,Intent(this,MainActivity::class.java),PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT);return Notification.Builder(this,CH).setSmallIcon(android.R.drawable.ic_media_play).setContentTitle("Study Lock Pro").setContentText(if(off(this))"Counting phone-free study time" else "Screen ON — paused").setOngoing(true).setContentIntent(pi).build()}
 override fun onBind(i:Intent?)=null
}
