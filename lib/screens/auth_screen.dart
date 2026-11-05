import 'package:flutter/material.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class AuthScreen extends StatefulWidget {
 const AuthScreen({super.key,required this.controller});
 final AppController controller;
 @override State<AuthScreen> createState()=>_AuthScreenState();
}
class _AuthScreenState extends State<AuthScreen> {
 final form=GlobalKey<FormState>();
 final name=TextEditingController(),email=TextEditingController(),password=TextEditingController();
 bool register=false,agree=false,busy=false,obscure=true;
 @override void dispose(){name.dispose();email.dispose();password.dispose();super.dispose();}
 Future<void> submit()async{
  if(!form.currentState!.validate())return;
  if(register&&!agree){showFailure(context,'Dichiara di essere maggiorenne e accetta le condizioni della demo.');return;}
  setState(()=>busy=true);
  try{
   if(register){await widget.controller.register(name.text.trim(),email.text.trim(),password.text);}
   else{await widget.controller.login(email.text.trim(),password.text);}
   if(mounted)Navigator.pop(context,true);
  }catch(e){if(mounted)showFailure(context,e);}finally{if(mounted)setState(()=>busy=false);}
 }
 @override Widget build(BuildContext context)=>Scaffold(
  appBar:AppBar(),body:SafeArea(child:Center(child:ConstrainedBox(
   constraints:const BoxConstraints(maxWidth:520),
   child:SingleChildScrollView(padding:const EdgeInsets.fromLTRB(24,5,24,28),
    child:Form(key:form,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     const Brand(),const SizedBox(height:36),
     Text(register?'Benvenuto.\nUnisciti a noi.':'Bentornato.\nFacciamo del bene.',
      style:Theme.of(context).textTheme.headlineLarge),
     const SizedBox(height:12),
     Text(register?'Crea il tuo spazio in SaldoInsieme.':'Accedi per creare richieste e provare il servizio.',
      style:Theme.of(context).textTheme.bodyMedium),
     const SizedBox(height:28),
     if(register)...[
      const Text('Come ti chiami?',style:TextStyle(fontWeight:FontWeight.w700)),
      const SizedBox(height:9),TextFormField(controller:name,
       textCapitalization:TextCapitalization.words,
       decoration:const InputDecoration(hintText:'Nome'),validator:(v)=>register&&(v?.trim().length??0)<2?'Inserisci il nome.':null),
      const SizedBox(height:17),
     ],
     const Text('Indirizzo email',style:TextStyle(fontWeight:FontWeight.w700)),
     const SizedBox(height:9),TextFormField(controller:email,keyboardType:TextInputType.emailAddress,
      autofillHints:const [AutofillHints.email],decoration:const InputDecoration(hintText:'nome@email.it'),
      validator:(v)=>v==null||!v.contains('@')?'Inserisci una email valida.':null),
     const SizedBox(height:17),
     const Text('Password',style:TextStyle(fontWeight:FontWeight.w700)),
     const SizedBox(height:9),
     TextFormField(controller:password,obscureText:obscure,
      autofillHints:[register?AutofillHints.newPassword:AutofillHints.password],
      decoration:InputDecoration(hintText:'La tua password',
       suffixIcon:IconButton(onPressed:()=>setState(()=>obscure=!obscure),
        icon:Icon(obscure?Icons.visibility_outlined:Icons.visibility_off_outlined))),
      validator:(v)=>(v?.isEmpty??true)?'Inserisci la password.':
       register&&(v!.length<10||!RegExp('[A-Z]').hasMatch(v)||!RegExp('[a-z]').hasMatch(v)||!RegExp('[0-9]').hasMatch(v))?
       'Minimo 10 caratteri, maiuscola, minuscola e numero.':null),
     if(register)...[
      const SizedBox(height:16),
      CheckboxListTile(value:agree,contentPadding:EdgeInsets.zero,
       activeColor:SI.emerald,onChanged:(v)=>setState(()=>agree=v??false),
       controlAffinity:ListTileControlAffinity.leading,
       title:const Text('Ho almeno 18 anni e accetto le condizioni della versione dimostrativa.',
        style:TextStyle(fontSize:12,color:SI.ink))),
      TextButton(onPressed:()=>showDialog(context:context,builder:(_)=>AlertDialog(
       title:const Text('Condizioni della demo'),
       content:const Text('SaldoInsieme è una piattaforma in sviluppo. Il sistema non elabora pagamenti reali. Evita di caricare documenti personali reali prima della pubblicazione di una completa informativa privacy del gestore.'),
       actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Chiudi'))])),
       child:const Text('Leggi le condizioni della demo')),
     ],
     const SizedBox(height:18),
     SizedBox(width:double.infinity,child:FilledButton(onPressed:busy?null:submit,
      child:Text(busy?'Accesso...':register?'Crea il mio account':'Accedi'))),
     const SizedBox(height:15),
     Row(mainAxisAlignment:MainAxisAlignment.center,children:[
      Text(register?'Hai già un account?':'Non hai ancora un account?'),
      TextButton(onPressed:()=>setState(()=>register=!register),
       child:Text(register?'Accedi':'Registrati'))
     ]),
    ]))
   )))));
}
