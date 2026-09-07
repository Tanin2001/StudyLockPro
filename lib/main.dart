import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() => runApp(const StudyLockApp());

class NativeBridge {
  static const ch = MethodChannel('study_lock/native');
  static Future<void> start() => ch.invokeMethod('start');
  static Future<void> pause() => ch.invokeMethod('pause');
  static Future<void> reset() => ch.invokeMethod('reset');
  static Future<Map<dynamic,dynamic>> state() async => (await ch.invokeMethod('state')).cast<dynamic,dynamic>();
}

class StudyLockApp extends StatelessWidget {
  const StudyLockApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner:false, title:'Study Lock Pro',
    theme: ThemeData(brightness:Brightness.dark, scaffoldBackgroundColor:const Color(0xFF090A12),
      colorScheme: ColorScheme.fromSeed(seedColor:const Color(0xFF8B7CFF),brightness:Brightness.dark),
      useMaterial3:true),
    home: const Home(),
  );
}

class Home extends StatefulWidget { const Home({super.key}); @override State<Home> createState()=>_HomeState(); }
class _HomeState extends State<Home> {
  Timer? timer; Duration elapsed=Duration.zero, today=Duration.zero; bool running=false, screenOff=false;
  @override void initState(){super.initState(); refresh(); timer=Timer.periodic(const Duration(milliseconds:500),(_)=>refresh());}
  @override void dispose(){timer?.cancel();super.dispose();}
  Future<void> refresh() async { try { final s=await NativeBridge.state(); if(!mounted)return; setState((){
    elapsed=Duration(milliseconds:(s['elapsed']??0) as int); today=Duration(milliseconds:(s['today']??0) as int);
    running=(s['running']??false) as bool; screenOff=(s['screenOff']??false) as bool;
  });} catch(_){ } }
  String fmt(Duration d)=>'${d.inHours.toString().padLeft(2,'0')}:${(d.inMinutes%60).toString().padLeft(2,'0')}:${(d.inSeconds%60).toString().padLeft(2,'0')}';
  String short(Duration d)=>d.inHours>0?'${d.inHours}h ${(d.inMinutes%60)}m':'${d.inMinutes}m';
  Future<void> act(Future<void> Function() f) async {await f();await refresh();}
  @override Widget build(BuildContext c)=>Scaffold(
    body: SafeArea(child: ListView(padding:const EdgeInsets.all(22),children:[
      const Text('STUDY LOCK PRO',style:TextStyle(fontSize:25,fontWeight:FontWeight.w800,letterSpacing:.5)),
      const SizedBox(height:4),const Text('Your phone-free study companion',style:TextStyle(color:Color(0xFF8F92A6))),
      const SizedBox(height:24),
      Container(padding:const EdgeInsets.all(24),height:270,decoration:BoxDecoration(
        gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF191A2B),Color(0xFF10111D)]),
        borderRadius:BorderRadius.circular(28),border:Border.all(color:Color(0xFF292B40))),
        child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
          Text(!running?'READY':screenOff?'●  SCREEN OFF — COUNTING':'○  SCREEN ON — PAUSED',
            style:TextStyle(color:screenOff&&running?const Color(0xFF9CFFBF):const Color(0xFFA9A0FF),fontWeight:FontWeight.bold)),
          const SizedBox(height:18),FittedBox(child:Text(fmt(elapsed),style:const TextStyle(fontSize:50,fontWeight:FontWeight.w800,fontFamily:'monospace'))),
          const SizedBox(height:10),const Text('Only screen-OFF time counts',style:TextStyle(color:Color(0xFF85889B))),
        ])),
      const SizedBox(height:18),
      SizedBox(height:58,child:FilledButton(
        onPressed:()=>act(running?NativeBridge.pause:NativeBridge.start),
        child:Text(running?'PAUSE STUDY':'START STUDY',style:const TextStyle(fontWeight:FontWeight.bold)))),
      const SizedBox(height:10),
      SizedBox(height:54,child:OutlinedButton(onPressed:()=>act(NativeBridge.reset),child:const Text('RESET SESSION'))),
      const SizedBox(height:18),
      Row(children:[Expanded(child:Stat(title:'TODAY',value:short(today))),const SizedBox(width:12),Expanded(child:Stat(title:'ALL TIME',value:short(elapsed)))]),
      const SizedBox(height:18),
      OutlinedButton.icon(onPressed:()=>showDialog(context:c,builder:(_)=>AlertDialog(
        title:const Text('Settings'),content:const Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,
        children:[Text('Theme: Dark'),SizedBox(height:12),Text('Notifications: Enabled'),SizedBox(height:12),Text('Screen OFF is the only counted time.'),SizedBox(height:12),Text('Study Lock Pro 1.0.0')]),
        actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('DONE'))])),icon:const Icon(Icons.settings),label:const Text('SETTINGS')),
    ])));
}
class Stat extends StatelessWidget { final String title,value; const Stat({super.key,required this.title,required this.value});
@override Widget build(BuildContext c)=>Container(height:112,padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:const Color(0xFF171827),borderRadius:BorderRadius.circular(22),border:Border.all(color:const Color(0xFF282A40))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(color:Color(0xFF8F92A6),fontSize:12)),const SizedBox(height:8),Text(value,style:const TextStyle(fontSize:25,fontWeight:FontWeight.bold))]);}
