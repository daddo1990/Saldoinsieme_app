import 'package:flutter/material.dart';
import '../models/aid_case.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class BalanceScreen extends StatefulWidget {
 const BalanceScreen({super.key,required this.controller});
 final AppController controller;
 @override State<BalanceScreen> createState()=>_BalanceScreenState();
}
class _BalanceScreenState extends State<BalanceScreen>{
 late Future<Map<String,dynamic>> balance;
 @override void initState(){super.initState();load();}
 void load(){balance=widget.controller.accountBalance();}
 @override Widget build(BuildContext context)=>Scaffold(
  appBar:AppBar(title:const Text('Saldo e attività',style:TextStyle(fontWeight:FontWeight.w800,fontSize:17)),
   actions:[IconButton(onPressed:()=>setState(load),icon:const Icon(Icons.refresh_rounded),tooltip:'Aggiorna')]),
  body:SafeArea(child:FutureBuilder<Map<String,dynamic>>(future:balance,builder:(context,snapshot){
   if(snapshot.connectionState==ConnectionState.waiting){
    return const Center(child:CircularProgressIndicator(color:SI.emerald));
   }
   if(snapshot.hasError){
    return Padding(padding:const EdgeInsets.all(22),
     child:EmptyPanel(title:'Saldo non disponibile',message:snapshot.error.toString()));
   }
   final data=snapshot.data??<String,dynamic>{};
   final demo=Map<String,dynamic>.from(data['demo'] as Map? ?? {});
   int amount(String field)=>((data[field] as num?)??0).toInt();
   int simulation(String field)=>((demo[field] as num?)??0).toInt();
   return ListView(padding:const EdgeInsets.fromLTRB(21,13,21,34),children:[
    Container(padding:const EdgeInsets.all(25),decoration:BoxDecoration(
     color:SI.forest,borderRadius:BorderRadius.circular(26)),
     child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Row(children:[
       Icon(Icons.account_balance_wallet_outlined,color:SI.mint,size:22),
       SizedBox(width:10),Text('SALDO DISPONIBILE',style:TextStyle(
        color:SI.mint,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1.2))
      ]),
      const SizedBox(height:14),
      Text(euro(amount('balance_available_cents')),
       style:const TextStyle(fontSize:39,fontWeight:FontWeight.w900,color:Colors.white)),
      const SizedBox(height:7),
      const Text('Portafoglio non attivo. Non è possibile depositare, ricevere o prelevare denaro.',
       style:TextStyle(color:Color(0xFFCEE8D8),fontSize:12,height:1.5)),
     ])),
    const SizedBox(height:17),const DemoBanner(),
    const SizedBox(height:24),
    const SectionTitle('Movimenti reali'),
    const SizedBox(height:10),
    _stat('Aiuti ricevuti e verificati',euro(amount('received_verified_cents')),Icons.south_west_rounded),
    _stat('Aiuti inviati e verificati',euro(amount('sent_verified_cents')),Icons.north_east_rounded),
    _stat('Disponibile per il prelievo',euro(amount('withdrawable_cents')),Icons.account_balance_outlined),
    const SizedBox(height:23),
    const SectionTitle('Simulazioni'),
    const SizedBox(height:8),
    Text('Non sono contributi, debiti, pagamenti o denaro custodito.',
     style:Theme.of(context).textTheme.bodyMedium),
    const SizedBox(height:13),
    _stat('Numero simulazioni',simulation('pledges_count').toString(),Icons.receipt_long_rounded),
    _stat('Importi scelti in demo',euro(simulation('contributions_cents')),Icons.favorite_border),
    _stat('Commissioni demo 5%',euro(simulation('fees_cents')),Icons.percent_rounded),
    _stat('Totale ipotetico',euro(simulation('total_cents')),Icons.calculate_outlined),
    const SizedBox(height:20),
    Container(padding:const EdgeInsets.all(18),
     decoration:BoxDecoration(color:SI.mint,borderRadius:BorderRadius.circular(18)),
     child:const Text('La commissione di servizio è pari al 5% aggiunto all’importo scelto. Senza un provider approvato, nessuna transazione può essere completata.',
      style:TextStyle(fontSize:13,height:1.55,color:SI.forest)))
   ]);
  }))
 );
 Widget _stat(String title,String value,IconData icon)=>Container(
  margin:const EdgeInsets.only(bottom:9),
  padding:const EdgeInsets.symmetric(horizontal:16,vertical:15),
  decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16),
   border:Border.all(color:SI.border)),
  child:Row(children:[
   Container(width:38,height:38,decoration:BoxDecoration(color:SI.mint,
    borderRadius:BorderRadius.circular(11)),
    child:Icon(icon,color:SI.forest,size:20)),
   const SizedBox(width:12),Expanded(child:Text(title,style:const TextStyle(
    color:SI.ink,fontSize:12,fontWeight:FontWeight.w600))),
   Text(value,style:const TextStyle(color:SI.forest,fontWeight:FontWeight.w900))
  ]));
}
