import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class QuoteExportDialog extends StatefulWidget {
  final String text,date,monthlyAsset;
  final bool mm;
  const QuoteExportDialog({super.key,required this.text,required this.date,required this.mm,required this.monthlyAsset});
  @override State<QuoteExportDialog> createState()=>_QuoteExportDialogState();
}
class _QuoteExportDialogState extends State<QuoteExportDialog> {
  final cardKey=GlobalKey();
  bool skyline=false,busy=false;
  bool monthly=true;
  String status='';
  String t(String my,String en)=>widget.mm?my:en;
  Future<void> export(bool share) async {
    setState(()=>busy=true);
    try {
      if(monthly) await precacheImage(AssetImage(widget.monthlyAsset),context);
      await WidgetsBinding.instance.endOfFrame;
      final boundary=cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image=await boundary.toImage(pixelRatio:1080/boundary.size.width);
      final bytes=await image.toByteData(format:ui.ImageByteFormat.png);
      image.dispose();
      if(bytes==null)throw StateError('Image unavailable');
      await const MethodChannel('org.minsithu.nayyet/export').invokeMethod('saveQuote',{'bytes':bytes.buffer.asUint8List(),'share':share});
      if(mounted)setState(()=>status=t('ပုံကို Pictures/NayYet တွင် သိမ်းပြီးပါပြီ။','Saved to Pictures/NayYet.'));
    } catch (_) {if(mounted)setState(()=>status=t('ပုံသိမ်းမရပါ။ ပြန်စမ်းပါ။','Could not save the image. Please try again.'));}
    finally {if(mounted)setState(()=>busy=false);}
  }
  @override Widget build(BuildContext context)=>Dialog(child:SingleChildScrollView(child:Padding(padding:const EdgeInsets.all(16),child:Column(mainAxisSize:MainAxisSize.min,children:[
    SwitchListTile(title:Text(t('လအလိုက် နောက်ခံ','Monthly theme')),value:monthly,onChanged:busy?null:(v)=>setState(()=>monthly=v)),
    if(!monthly)SwitchListTile(title:Text(skyline?'Skyline':'Universe'),value:skyline,onChanged:busy?null:(v)=>setState(()=>skyline=v)),
    RepaintBoundary(key:cardKey,child:AspectRatio(aspectRatio:4/5,child:DecoratedBox(decoration:BoxDecoration(image:monthly?DecorationImage(image:AssetImage(widget.monthlyAsset),fit:BoxFit.cover,colorFilter:const ColorFilter.mode(Colors.black38,BlendMode.darken)):null),child:LayoutBuilder(builder:(context,box)=>CustomPaint(painter:monthly?null:QuoteBackdrop(skyline),child:Padding(padding:EdgeInsets.all(box.maxWidth*.08),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('NAYYET / A MOMENT FOR YOU',style:TextStyle(fontFamily:'Outfit',fontSize:box.maxWidth*.027,color:Colors.white70)),const Spacer(flex:2),Text(widget.text,style:TextStyle(fontFamily:widget.mm?'Pyidaungsu':'Outfit',fontSize:box.maxWidth*.052,height:1.85,color:Colors.white)),const Spacer(flex:2),Text(widget.date,style:TextStyle(fontFamily:widget.mm?'Pyidaungsu':'Outfit',fontSize:box.maxWidth*.025,color:Colors.white70)),SizedBox(height:box.maxWidth*.025),Text('နေ့ရက် — NayYet · minsithu.org',style:TextStyle(fontFamily:'Pyidaungsu',fontSize:box.maxWidth*.024,color:Colors.white)),const Spacer()]))))))),
    const SizedBox(height:14),Wrap(spacing:8,children:[TextButton(onPressed:busy?null:()=>export(false),child:Text(t('PNG သိမ်းရန်','Save PNG'))),FilledButton(onPressed:busy?null:()=>export(true),child:Text(t('မျှဝေရန်','Share')))]),if(busy)const LinearProgressIndicator(),Text(status),TextButton(onPressed:()=>Navigator.pop(context),child:Text(t('ပိတ်ရန်','Close')))
  ]))));
}
class QuoteBackdrop extends CustomPainter {
  final bool skyline;
  QuoteBackdrop(this.skyline);
  @override void paint(Canvas canvas,Size size){
    final rect=Offset.zero&size;
    canvas.drawRect(rect,Paint()..shader=LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:skyline?const[Color(0xff242745),Color(0xffb76782),Color(0xfff2b995)]:const[Color(0xff080e2e),Color(0xff382763),Color(0xff946383)]).createShader(rect));
    for(var i=0;i<95;i++){canvas.drawCircle(Offset(((i*173+41)%1080)/1080*size.width,((i*277+29)%1100)/1350*size.height),size.width*(.001+i%3*.0007),Paint()..color=Colors.white.withOpacity(.2+(i%6)*.12));}
    canvas.drawCircle(Offset(size.width*.77,size.height*.18),size.width*.07,Paint()..color=const Color(0xfff8dfbd));
    if(skyline){for(var i=0;i<16;i++){final h=(.1+(i*79%230)/1350)*size.height;canvas.drawRect(Rect.fromLTWH(i*size.width/15,size.height-h,size.width/15-2,h),Paint()..color=const Color(0xff131b32));}}
    else {canvas.drawOval(Rect.fromCenter(center:Offset(size.width*.77,size.height*.18),width:size.width*.28,height:size.height*.08),Paint()..color=Colors.white24..style=PaintingStyle.stroke..strokeWidth=1);}
  }
  @override bool shouldRepaint(QuoteBackdrop old)=>old.skyline!=skyline;
}
