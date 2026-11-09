import 'package:flutter/material.dart';
import '../models/aid_case.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';
import 'create_screen.dart';
import 'balance_screen.dart';
import 'account_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
 const ProfileScreen({super.key,required this.controller,required this.onCreate,required this.onLogin});
 final AppController controller;final VoidCallback onCreate,onLogin;
 @override State<ProfileScreen> createState()=>_ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen>{
 String? observedToken;
 Future<List<AidCase>>? requests;
 Future<List<Map<String,dynamic>>>? pledges;
 @override void initState(){super.initState();observedToken=widget.controller.token;
  widget.controller.addListener(onSession);if(widget.controller.isLoggedIn)refresh();}
 @override void dispose(){widget.controller.removeListener(onSession);super.dispose();}
 void onSession(){
  if(observedToken!=widget.controller.token){
   observedToken=widget.controller.token;
   if(mounted)refresh();
  }
 }
 void refresh(){
  setState((){
   if(widget.controller.isLoggedIn){
    requests=widget.controller.myRequests();
    pledges=widget.controller.myPledges();
   }else{requests=null;pledges=null;}
  });
 }
 @override Widget build(BuildContext context)=>AnimatedBuilder(animation:widget.controller,builder:(context,_){
  final controller=widget.controller;
  return ListView(padding:const EdgeInsets.fromLTRB(20,25,20,32),children:[
   Text('Il tuo spazio',style:Theme.of(context).textTheme.headlineLarge),
   const SizedBox(height:7),
   Text('La tua presenza può fare la differenza.',style:Theme.of(context).textTheme.bodyMedium),
   const SizedBox(height:21),
   const DemoBanner(),const SizedBox(height:19),
   if(!controller.isLoggedIn)...[
    Container(padding:const EdgeInsets.all(26),decoration:BoxDecoration(
     color:SI.forest,borderRadius:BorderRadius.circular(24)),child:Column(
     crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Icon(Icons.favorite_rounded,color:SI.mint,size:40),
      const SizedBox(height:19),
      const Text('Unisciti a qualcosa\ndi bello.',style:TextStyle(fontSize:27,
       height:1.13,color:Colors.white,fontWeight:FontWeight.w900)),
      const SizedBox(height:12),
      const Text('Crea un account per pubblicare richieste e provare la piattaforma.',
       style:TextStyle(height:1.5,color:Color(0xFFCEE4D5))),
      const SizedBox(height:19),
      FilledButton(onPressed:widget.onLogin,
       style:FilledButton.styleFrom(backgroundColor:SI.mint,foregroundColor:SI.forest),
       child:const Text('Accedi o registrati')),
     ]))
   ]else...[
    Container(padding:const EdgeInsets.all(20),
     decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(22),
      border:Border.all(color:SI.border)),child:Row(children:[
      CircleAvatar(radius:27,backgroundColor:SI.mint,child:Text(
       (controller.name?.isNotEmpty==true?controller.name![0]:'S').toUpperCase(),
       style:const TextStyle(fontWeight:FontWeight.w900,color:SI.forest,fontSize:23))),
      const SizedBox(width:14),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
       Text(controller.name??'Account',style:Theme.of(context).textTheme.titleMedium),
       Text(controller.email??'',style:const TextStyle(color:SI.muted,fontSize:12))
      ])),
      IconButton(onPressed:refresh,icon:const Icon(Icons.refresh_rounded,color:SI.emerald),tooltip:'Aggiorna')
     ])),
    const SizedBox(height:12),
    if(!controller.emailVerified)Container(
     padding:const EdgeInsets.all(15),
     decoration:BoxDecoration(color:SI.mint.withValues(alpha:0.35),borderRadius:BorderRadius.circular(16)),
     child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('Verifica la tua email',style:TextStyle(fontWeight:FontWeight.w800,color:SI.forest)),
      const SizedBox(height:5),
      const Text('Ti invieremo un link valido 60 minuti. In locale lo trovi nel log Laravel.',style:TextStyle(fontSize:12,color:SI.ink)),
      Wrap(spacing:8,children:[
       TextButton(onPressed:()async{
        try{await controller.requestEmailVerification();if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Link di verifica richiesto. Controlla la posta.')));}
        catch(e){if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}
       },child:const Text('Invia link')),
       TextButton(onPressed:()async{
        try{await controller.refreshVerificationStatus();}
        catch(e){if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}
       },child:const Text('Ho verificato')),
      ])
     ])),
    const SizedBox(height:20),
    Container(decoration:BoxDecoration(color:Colors.white,
     borderRadius:BorderRadius.circular(20),border:Border.all(color:SI.border)),
     child:Column(children:[
      ListTile(
       leading:const Icon(Icons.account_balance_wallet_outlined,color:SI.emerald),
       title:const Text('Saldo e attività',style:TextStyle(fontWeight:FontWeight.w800,color:SI.ink)),
       subtitle:const Text('Riepilogo reale e simulazioni, sempre separati'),
       trailing:const Icon(Icons.chevron_right_rounded),
       onTap:()=>Navigator.push(context,MaterialPageRoute(
        builder:(_)=>BalanceScreen(controller:controller)))),
      const Divider(height:1,color:SI.border,indent:58),
      ListTile(
       leading:const Icon(Icons.manage_accounts_rounded,color:SI.emerald),
       title:const Text('Impostazioni account',style:TextStyle(fontWeight:FontWeight.w800,color:SI.ink)),
       subtitle:const Text('Dati, password e cancellazione'),
       trailing:const Icon(Icons.chevron_right_rounded),
       onTap:()async{
        await Navigator.push(context,MaterialPageRoute(
         builder:(_)=>AccountSettingsScreen(controller:controller)));
        if(mounted)refresh();
       }),
     ])),
    const SizedBox(height:23),
    SectionTitle('Le mie richieste',trailing:'Nuova',onTrailing:widget.onCreate),
    const SizedBox(height:10),
    FutureBuilder<List<AidCase>>(future:requests,builder:(context,snapshot){
     if(snapshot.connectionState==ConnectionState.waiting)return const Center(
      child:Padding(padding:EdgeInsets.all(30),child:CircularProgressIndicator()));
     if(snapshot.hasError)return EmptyPanel(title:'Non disponibile',message:snapshot.error.toString());
     final items=snapshot.data??[];
     if(items.isEmpty)return const EmptyPanel(title:'Ancora nessuna richiesta',
      message:'Quando pubblichi una necessità, potrai seguirne lo stato qui.');
     return Column(children:items.map((c)=>Container(
      margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(15),
      decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(17),
       border:Border.all(color:SI.border)),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
       Row(children:[
        Icon(categoryIcon(c.category),color:SI.emerald),
        const SizedBox(width:9),
        Expanded(child:Text(c.title,style:const TextStyle(color:SI.ink,fontWeight:FontWeight.w800))),
       ]),
       const SizedBox(height:8),
       Text('Obiettivo: '+euro(c.goalCents)+'  ·  '+_status(c.status),
        style:const TextStyle(color:SI.muted,fontSize:12)),
       if(c.status=='draft')Align(alignment:Alignment.centerRight,child:TextButton.icon(
        icon:const Icon(Icons.upload_file_rounded,size:16),label:const Text('Completa'),
        onPressed:()async{
         final ok=await Navigator.push<bool>(context,MaterialPageRoute(builder:(_)=>
          FinishDraftScreen(controller:controller,requestId:c.id)));
         if(ok==true)refresh();
        })),
      ]))
     ).toList());
    }),
    const SizedBox(height:24),
    const SectionTitle('Le mie simulazioni'),
    const SizedBox(height:5),
    const Text('Non sono versamenti: nessun addebito è stato effettuato.',
     style:TextStyle(color:SI.muted,fontSize:12)),
    const SizedBox(height:12),
    FutureBuilder<List<Map<String,dynamic>>>(future:pledges,builder:(context,snapshot){
     if(snapshot.connectionState==ConnectionState.waiting)return const Center(
      child:Padding(padding:EdgeInsets.all(18),child:CircularProgressIndicator()));
     final items=snapshot.data??[];
     if(snapshot.hasError)return EmptyPanel(title:'Storico non disponibile',
      message:snapshot.error.toString());
     if(items.isEmpty)return const EmptyPanel(title:'Nessuna simulazione',
      message:'Esplora le storie e prova il calcolo del contributo con il 5% di servizio.');
     return Column(children:items.map((p)=>Container(
      margin:const EdgeInsets.only(bottom:9),padding:const EdgeInsets.all(15),
      decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14)),
      child:Row(children:[
       const Icon(Icons.receipt_long_outlined,color:SI.emerald),const SizedBox(width:11),
       Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('Simulazione · Nessun pagamento',style:TextStyle(fontWeight:FontWeight.w800,fontSize:13)),
        Text('Contributo '+euro((p['amount_cents'] as num).toInt())+
         ' + servizio '+euro((p['fee_cents'] as num).toInt()),
         style:const TextStyle(fontSize:11,color:SI.muted))
       ])),
       Text(euro((p['total_cents'] as num).toInt()),
        style:const TextStyle(color:SI.ink,fontWeight:FontWeight.w900))
      ]))
     ).toList());
    }),
    const SizedBox(height:23),
    OutlinedButton.icon(onPressed:()async{await controller.logout();},
     icon:const Icon(Icons.logout_rounded),label:const Text('Esci dal tuo account')),
   ],
   const SizedBox(height:27),
   Center(child:Text('SaldoInsieme · Versione 0.1 · Nessun pagamento reale',
    textAlign:TextAlign.center,style:Theme.of(context).textTheme.bodySmall))
  ]);
 });
}
String _status(String key)=>switch(key){
 'draft'=>'Bozza','pending_review'=>'In verifica','published'=>'Pubblicata',
 'declined'=>'Rifiutata','closed'=>'Chiusa',_=>key
};
