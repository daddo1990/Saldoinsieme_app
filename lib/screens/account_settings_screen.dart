import 'package:flutter/material.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class AccountSettingsScreen extends StatefulWidget {
 const AccountSettingsScreen({super.key,required this.controller});
 final AppController controller;
 @override State<AccountSettingsScreen> createState()=>_AccountSettingsScreenState();
}
class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
 late final TextEditingController fullName,email;
 final oldPassword=TextEditingController(),newPassword=TextEditingController();
 bool saving=false,changing=false,deleting=false;
 @override void initState(){super.initState();
  fullName=TextEditingController(text:widget.controller.name??'');
  email=TextEditingController(text:widget.controller.email??'');
 }
 @override void dispose(){
  fullName.dispose();email.dispose();oldPassword.dispose();newPassword.dispose();super.dispose();
 }
 Future<void> saveProfile()async{
  if(fullName.text.trim().length<2){showFailure(context,'Inserisci un nome valido.');return;}
  if(!email.text.contains('@')){showFailure(context,'Inserisci una email valida.');return;}
  final newEmail=email.text.trim();
  final changed=newEmail.toLowerCase()!=widget.controller.email?.toLowerCase();
  String? password;
  if(changed){
   password=await _askPassword(
    'Conferma il cambio email',
    'Per proteggere l’account, inserisci la password attuale. Sarà necessario effettuare nuovamente il login.');
   if(password==null||!mounted)return;
  }
  setState(()=>saving=true);
  try{
   await widget.controller.updateProfile(newName:fullName.text,
    newEmail:newEmail,currentPassword:password);
   if(!mounted)return;
   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Profilo aggiornato.')));
   if(changed)Navigator.pop(context);
  }catch(e){if(mounted)showFailure(context,e);}
  finally{if(mounted)setState(()=>saving=false);}
 }
 Future<void> savePassword()async{
  if(newPassword.text.length<10||
     !RegExp('[A-Z]').hasMatch(newPassword.text)||
     !RegExp('[a-z]').hasMatch(newPassword.text)||
     !RegExp('[0-9]').hasMatch(newPassword.text)){
   showFailure(context,'Usa almeno 10 caratteri, maiuscola, minuscola e numero.');return;
  }
  if(oldPassword.text.isEmpty){showFailure(context,'Inserisci la password attuale.');return;}
  setState(()=>changing=true);
  try {
   await widget.controller.changePassword(oldPassword.text,newPassword.text);
   if(!mounted)return;
   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content:Text('Password modificata. Accedi nuovamente.')));
   Navigator.pop(context);
  }catch(e){if(mounted)showFailure(context,e);}
  finally{if(mounted)setState(()=>changing=false);}
 }
 Future<String?> _askPassword(String title,String description)async{
  final input=TextEditingController();
  final result=await showDialog<String>(context:context,builder:(dialogContext)=>AlertDialog(
   title:Text(title),content:Column(mainAxisSize:MainAxisSize.min,
    crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text(description,style:const TextStyle(fontSize:13)),
    const SizedBox(height:12),
    TextField(controller:input,obscureText:true,autofillHints:const [AutofillHints.password],
     decoration:const InputDecoration(labelText:'Password attuale')),
   ]),actions:[
    TextButton(onPressed:()=>Navigator.pop(dialogContext),child:const Text('Annulla')),
    FilledButton(onPressed:()=>Navigator.pop(dialogContext,input.text),
     child:const Text('Conferma')),
   ]));
  input.dispose();
  return result;
 }
 Future<void> deleteAccount()async{
  final result=await _askPassword('Eliminazione definitiva',
   'L’account, le richieste e i documenti associati verranno eliminati. Le transazioni reali, quando esisteranno, richiederanno una procedura dedicata. Conferma con la tua password.');
  if(result==null||result.isEmpty||!mounted)return;
  final yes=await showDialog<bool>(context:context,builder:(dialogContext)=>AlertDialog(
   title:const Text('Eliminare davvero l’account?'),
   content:const Text('Questa operazione non può essere annullata. Nella versione attuale saranno eliminate anche tutte le simulazioni.'),
   actions:[
    TextButton(onPressed:()=>Navigator.pop(dialogContext,false),child:const Text('Mantieni account')),
    TextButton(onPressed:()=>Navigator.pop(dialogContext,true),
     child:const Text('Elimina definitivamente',style:TextStyle(color:Colors.red))),
   ]));
  if(yes!=true||!mounted)return;
  setState(()=>deleting=true);
  try {
   await widget.controller.deleteAccount(result);
   if(mounted)Navigator.pop(context);
  }catch(e){if(mounted)showFailure(context,e);}
  finally{if(mounted)setState(()=>deleting=false);}
 }
 @override Widget build(BuildContext context)=>Scaffold(
  appBar:AppBar(title:const Text('Impostazioni account',
   style:TextStyle(fontWeight:FontWeight.w800,fontSize:17))),
  body:SafeArea(child:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:660),
   child:ListView(padding:const EdgeInsets.fromLTRB(22,8,22,33),children:[
    const DemoBanner(),const SizedBox(height:26),
    const SectionTitle('I tuoi dati'),
    const SizedBox(height:11),
    _panel(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     const Text('Nome',style:TextStyle(fontWeight:FontWeight.w800,color:SI.ink)),
     const SizedBox(height:8),
     TextField(controller:fullName,textCapitalization:TextCapitalization.words,
      decoration:const InputDecoration(hintText:'Nome e cognome')),
     const SizedBox(height:16),
     const Text('Email',style:TextStyle(fontWeight:FontWeight.w800,color:SI.ink)),
     const SizedBox(height:8),
     TextField(controller:email,keyboardType:TextInputType.emailAddress,
      decoration:const InputDecoration(hintText:'nome@email.it')),
     const SizedBox(height:12),
     Text('Modificare l’email richiede la password e un nuovo accesso.',
      style:Theme.of(context).textTheme.bodySmall),
     const SizedBox(height:18),
     SizedBox(width:double.infinity,child:FilledButton(
      onPressed:saving?null:saveProfile,child:Text(saving?'Salvataggio...':'Salva modifiche'))),
    ])),
    const SizedBox(height:24),
    const SectionTitle('Sicurezza'),
    const SizedBox(height:11),
    _panel(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     const Text('Password attuale',style:TextStyle(fontWeight:FontWeight.w800,color:SI.ink)),
     const SizedBox(height:8),
     TextField(controller:oldPassword,obscureText:true,autofillHints:const [AutofillHints.password],
      decoration:const InputDecoration(hintText:'La password attuale')),
     const SizedBox(height:16),
     const Text('Nuova password',style:TextStyle(fontWeight:FontWeight.w800,color:SI.ink)),
     const SizedBox(height:8),
     TextField(controller:newPassword,obscureText:true,autofillHints:const [AutofillHints.newPassword],
      decoration:const InputDecoration(hintText:'Almeno 10 caratteri e un numero')),
     const SizedBox(height:16),
     SizedBox(width:double.infinity,child:FilledButton(
      onPressed:changing?null:savePassword,
      child:Text(changing?'Modifica...':'Aggiorna password'))),
    ])),
    const SizedBox(height:24),
    const Text('ZONA RISERVATA',style:TextStyle(color:Colors.redAccent,
     fontWeight:FontWeight.w900,letterSpacing:1.3,fontSize:11)),
    const SizedBox(height:8),
    _panel(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     const Text('Elimina il mio account',
      style:TextStyle(color:SI.ink,fontWeight:FontWeight.w800,fontSize:17)),
     const SizedBox(height:7),
     const Text('Rimuove i dati dell’account e le richieste della versione demo. Richiede due conferme.',
      style:TextStyle(height:1.5,color:SI.muted,fontSize:13)),
     const SizedBox(height:13),
     OutlinedButton.icon(onPressed:deleting?null:deleteAccount,
      icon:const Icon(Icons.delete_forever_outlined,color:Colors.red),
      label:Text(deleting?'Eliminazione...':'Elimina account',
       style:const TextStyle(color:Colors.red))),
    ])),
   ]))))
 );
 Widget _panel(Widget content)=>Container(padding:const EdgeInsets.all(19),
  decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(22),
   border:Border.all(color:SI.border)),child:content);
}
