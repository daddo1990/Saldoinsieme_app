import 'package:flutter/material.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class ForgotPasswordScreen extends StatefulWidget {
 const ForgotPasswordScreen({super.key,required this.controller});
 final AppController controller;
 @override State<ForgotPasswordScreen> createState()=>_ForgotPasswordScreenState();
}
class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>{
 final email=TextEditingController();
 final form=GlobalKey<FormState>();
 bool loading=false,success=false;
 @override void dispose(){email.dispose();super.dispose();}
 Future<void> send()async {
  if(!form.currentState!.validate())return;
  setState(()=>loading=true);
  try {
   await widget.controller.requestPasswordRecovery(email.text);
   if(mounted)setState(()=>success=true);
  }catch(e){if(mounted)showFailure(context,e);}
  finally{if(mounted)setState(()=>loading=false);}
 }
 @override Widget build(BuildContext context)=>Scaffold(
  appBar:AppBar(title:const Text('Recupero password',style:TextStyle(fontSize:17,fontWeight:FontWeight.w800))),
  body:SafeArea(child:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:560),
   child:SingleChildScrollView(padding:const EdgeInsets.fromLTRB(24,26,24,34),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Container(width:64,height:64,decoration:BoxDecoration(color:SI.mint,borderRadius:BorderRadius.circular(22)),
      child:Icon(success?Icons.mark_email_read_rounded:Icons.lock_reset_rounded,color:SI.forest,size:33)),
     const SizedBox(height:23),
     Text(success?'Controlla la tua email.':'Ritrova il tuo account.',
      style:Theme.of(context).textTheme.headlineLarge),
     const SizedBox(height:12),
     Text(success
      ?'Se l’indirizzo è associato a un account, riceverai un link temporaneo per impostare una nuova password. Controlla anche lo spam.'
      :'Inserisci la tua email. Se esiste un account, riceverai un collegamento temporaneo per reimpostare la password.',
      style:Theme.of(context).textTheme.bodyLarge),
     const SizedBox(height:26),
     if(!success)Form(key:form,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('Indirizzo email',style:TextStyle(color:SI.ink,fontWeight:FontWeight.w800)),
      const SizedBox(height:9),
      TextFormField(controller:email,autofillHints:const [AutofillHints.email],
       keyboardType:TextInputType.emailAddress,
       decoration:const InputDecoration(hintText:'nome@email.it',prefixIcon:Icon(Icons.alternate_email_rounded)),
       validator:(v)=>v==null||!v.contains('@')?'Inserisci una email valida.':null),
      const SizedBox(height:22),
      SizedBox(width:double.infinity,child:FilledButton.icon(
       onPressed:loading?null:send,icon:const Icon(Icons.mark_email_unread_outlined),
       label:Text(loading?'Invio in corso...':'Invia istruzioni'))),
     ]))
     else SizedBox(width:double.infinity,child:FilledButton(
      onPressed:()=>Navigator.pop(context),child:const Text('Torna al login'))),
     const SizedBox(height:20),const DemoBanner(),
    ]))))));
}
