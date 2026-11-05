import 'package:flutter/material.dart';
import '../models/aid_case.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';
import 'auth_screen.dart';

class DetailScreen extends StatelessWidget {
 const DetailScreen({super.key,required this.controller,required this.item});
 final AppController controller;final AidCase item;
 @override Widget build(BuildContext context)=>Scaffold(
  appBar:AppBar(title:const Text('La storia',style:TextStyle(fontWeight:FontWeight.w800,fontSize:18)),
   actions:[IconButton(icon:const Icon(Icons.info_outline_rounded),onPressed:(){
    showDialog(context:context,builder:(_)=>AlertDialog(title:const Text('Come funziona'),
     content:const Text('Ogni richiesta reale viene inviata a verifica manuale. La versione attuale non accetta pagamenti; gli importi raccolti mostrano solo versamenti effettivamente verificati, non intenzioni o simulazioni.'),
     actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Ho capito'))]));
   })]),
  body:ListView(padding:const EdgeInsets.fromLTRB(20,10,20,30),children:[
   CaseArt(category:item.category,height:220),
   const SizedBox(height:19),
   Row(children:[Icon(item.isDemo?Icons.science_outlined:Icons.verified_user_outlined,
     color:SI.emerald,size:18),const SizedBox(width:7),
    Text(item.isDemo?'STORIA DIMOSTRATIVA':item.verified?'DOCUMENTI VERIFICATI':'RICHIESTA PUBBLICATA',
     style:const TextStyle(color:SI.emerald,fontWeight:FontWeight.w800,fontSize:11,letterSpacing:1.1))]),
   const SizedBox(height:12),
   Text(item.title,style:Theme.of(context).textTheme.headlineMedium),
   const SizedBox(height:13),
   Row(children:[Icon(categoryIcon(item.category),size:17,color:SI.muted),
    const SizedBox(width:6),Text(categoryLabel(item.category),
     style:const TextStyle(color:SI.muted,fontWeight:FontWeight.w700))]),
   const SizedBox(height:22),
   Container(padding:const EdgeInsets.all(20),
    decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(22),
     border:Border.all(color:SI.border)),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Text('Obiettivo',style:Theme.of(context).textTheme.bodyMedium),
     const SizedBox(height:3),
     Text(euro(item.goalCents),style:const TextStyle(fontSize:32,fontWeight:FontWeight.w900,
      color:SI.forest,letterSpacing:-.9)),
     const SizedBox(height:12),
     ClipRRect(borderRadius:BorderRadius.circular(9),child:LinearProgressIndicator(value:item.progress,
      minHeight:9,backgroundColor:SI.border,
      valueColor:const AlwaysStoppedAnimation<Color>(SI.emerald))),
     const SizedBox(height:11),
     Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
      Text('Contributi verificati',style:Theme.of(context).textTheme.bodyMedium),
      Text(euro(item.fundedCents),style:const TextStyle(color:SI.ink,fontWeight:FontWeight.w800))
     ])
    ])),
   const SizedBox(height:27),
   Text('Dietro questa richiesta',style:Theme.of(context).textTheme.titleLarge),
   const SizedBox(height:11),
   Text(item.story,style:const TextStyle(color:SI.ink,fontSize:15,height:1.72)),
   const SizedBox(height:24),
   Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(
    color:SI.mint,borderRadius:BorderRadius.circular(19)),
    child:const Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Icon(Icons.shield_outlined,color:SI.forest),SizedBox(width:12),
     Expanded(child:Text('Per proteggere le persone, i documenti completi non sono pubblici. Solo lo staff autorizzato può consultarli. Nessun pagamento è possibile nella versione demo.',
      style:TextStyle(color:SI.forest,height:1.5,fontWeight:FontWeight.w500,fontSize:13)))
    ])),
   const SizedBox(height:21),const DemoBanner(),
   const SizedBox(height:24),
  ]),
  bottomNavigationBar:SafeArea(top:false,child:Container(
   color:Colors.white,padding:const EdgeInsets.fromLTRB(20,12,20,12),
   child:FilledButton.icon(icon:const Icon(Icons.favorite_rounded),
    label:const Text('Scegli un contributo · Demo'),
    onPressed:()=>showModalBottomSheet(context:context,isScrollControlled:true,
     backgroundColor:SI.cream,showDragHandle:true,
     shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(30))),
     builder:(_)=>SupportSheet(controller:controller,item:item)))
  ))
 );
}

class SupportSheet extends StatefulWidget {
 const SupportSheet({super.key,required this.controller,required this.item});
 final AppController controller;final AidCase item;
 @override State<SupportSheet> createState()=>_SupportSheetState();
}
class _SupportSheetState extends State<SupportSheet> {
 int amount=5000;bool sending=false;
 final other=TextEditingController();
 @override void dispose(){other.dispose();super.dispose();}
 void selectAmount(int cents){setState(()=>amount=cents);other.clear();}
 void custom(String value){
  final num=int.tryParse(value.trim());if(num!=null&&num>0&&num<=5000)setState(()=>amount=num*100);
 }
 Future<void> simulate()async{
  if(amount<100||amount>500000){showFailure(context,'Inserisci da 1 a 5.000 euro.');return;}
  if(!widget.controller.offline&&!widget.item.isDemo&&!widget.controller.isLoggedIn){
   final logged=await Navigator.push<bool>(context,
    MaterialPageRoute(builder:(_)=>AuthScreen(controller:widget.controller)));
   if(!mounted||logged!=true)return;
  }
  setState(()=>sending=true);
  try{
   await widget.controller.simulate(widget.item.id,amount,
    'demo-'+DateTime.now().microsecondsSinceEpoch.toString());
   if(!mounted)return;
   Navigator.pop(context);
   showDialog(context:context,builder:(d)=>AlertDialog(
    title:const Text('Simulazione completata'),
    content:Text('Hai simulato un sostegno di '+euro(amount)+
     ' con una commissione di servizio del 5% ('+euro(serviceFeeCents(amount))+'). '+
     'Totale ipotetico: '+euro(totalCents(amount))+
     '. Nessun denaro è stato addebitato, trasferito o raccolto.'),
    actions:[FilledButton(onPressed:()=>Navigator.pop(d),child:const Text('Perfetto'))]));
  }catch(e){if(mounted)showFailure(context,e);}finally{if(mounted)setState(()=>sending=false);}
 }
 @override Widget build(BuildContext context)=>Padding(
  padding:EdgeInsets.fromLTRB(22,8,22,24+MediaQuery.viewInsetsOf(context).bottom),
  child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,
   crossAxisAlignment:CrossAxisAlignment.start,children:[
   Text('Un gesto concreto.',style:Theme.of(context).textTheme.headlineMedium),
   const SizedBox(height:6),
   Text('Scegli quanto vorresti destinare a questa richiesta.',
    style:Theme.of(context).textTheme.bodyMedium),
   const SizedBox(height:22),
   Wrap(spacing:8,runSpacing:9,children:[2500,5000,10000,25000,50000].map((v){
    final active=amount==v;
    return ChoiceChip(label:Text(euro(v)),selected:active,showCheckmark:false,
     selectedColor:SI.forest,backgroundColor:Colors.white,
     side:BorderSide(color:active?SI.forest:SI.border),
     labelStyle:TextStyle(color:active?Colors.white:SI.ink,fontWeight:FontWeight.w800),
     onSelected:(_)=>selectAmount(v));
   }).toList()),
   const SizedBox(height:15),
   TextField(controller:other,keyboardType:TextInputType.number,
    decoration:const InputDecoration(labelText:'Oppure scegli un importo in euro',hintText:'Es. 75'),
    onChanged:custom),
   const SizedBox(height:20),
   Container(padding:const EdgeInsets.all(19),decoration:BoxDecoration(color:Colors.white,
    borderRadius:BorderRadius.circular(18),border:Border.all(color:SI.border)),
    child:Column(children:[
     _row('A favore della richiesta',euro(amount)),
     const SizedBox(height:11),_row('Commissione servizio (5%)',euro(serviceFeeCents(amount))),
     const Divider(height:26,color:SI.border),
     _row('Totale ipotetico',euro(totalCents(amount)),bold:true)
    ])),
   const SizedBox(height:16),const DemoBanner(),
   const SizedBox(height:17),
   SizedBox(width:double.infinity,child:FilledButton(
    onPressed:sending?null:simulate,
    child:Text(sending?'Registrazione in corso...':'Conferma la simulazione'))),
   const SizedBox(height:7),
   const Center(child:Text('Nessuna carta richiesta · Nessun addebito',
    style:TextStyle(color:SI.muted,fontSize:11)))
  ])));
 Widget _row(String title,String value,{bool bold=false})=>Row(children:[
  Expanded(child:Text(title,style:TextStyle(color:bold?SI.ink:SI.muted,
   fontWeight:bold?FontWeight.w800:FontWeight.w500))),
  Text(value,style:TextStyle(fontWeight:FontWeight.w900,fontSize:bold?18:14,color:SI.ink))
 ]);
}
