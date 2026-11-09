import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/aid_case.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

Future<bool> uploadAndSubmit(BuildContext context,AppController controller,int requestId)async{
 try{
  final picked=await FilePicker.platform.pickFiles(
   type:FileType.custom,allowedExtensions:['pdf','jpg','jpeg','png'],withData:true);
  if(picked==null)return false;
  final item=picked.files.single;
  if(item.size>5*1024*1024)throw const FormatException('Il documento supera 5 MB.');
  if(item.bytes==null)throw const FormatException('Impossibile leggere il documento.');
  await controller.uploadDocument(requestId,item.bytes!,item.name);
  await controller.submitCase(requestId);
  return true;
 }catch(e){if(context.mounted)showFailure(context,e);return false;}
}

class CreateScreen extends StatefulWidget {
 const CreateScreen({super.key,required this.controller});
 final AppController controller;
 @override State<CreateScreen> createState()=>_CreateScreenState();
}
class _CreateScreenState extends State<CreateScreen>{
 final form=GlobalKey<FormState>();
 final title=TextEditingController(),story=TextEditingController(),goal=TextEditingController();
 String category='bollette';bool busy=false;int? savedId;
 @override void dispose(){title.dispose();story.dispose();goal.dispose();super.dispose();}
 Future<void> save()async{
  if(!form.currentState!.validate())return;
  setState(()=>busy=true);
  try{
   savedId??=await widget.controller.createCase(category:category,
    title:title.text.trim(),story:story.text.trim(),
    goalCents:int.parse(goal.text.trim())*100);
   if(!mounted)return;
   final submitted=await uploadAndSubmit(context,widget.controller,savedId!);
   if(!mounted)return;
   await showDialog(context:context,builder:(dialog)=>AlertDialog(
    title:Text(submitted?'Richiesta inviata':'Bozza salvata'),
    content:Text(submitted?
     'Il tuo documento è stato caricato in area privata. Lo staff esaminerà la richiesta prima di pubblicarla.':
     'La bozza resta nel tuo profilo. Puoi aggiungere il documento e inviarla più tardi.'),
    actions:[FilledButton(onPressed:()=>Navigator.pop(dialog),child:const Text('Ho capito'))]));
   if(mounted)Navigator.pop(context);
  }catch(e){if(mounted)showFailure(context,e);}
  finally{if(mounted)setState(()=>busy=false);}
 }
 @override Widget build(BuildContext context)=>Scaffold(
  appBar:AppBar(title:const Text('Nuova richiesta',style:TextStyle(fontWeight:FontWeight.w800,fontSize:17))),
  body:SafeArea(child:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:650),
   child:Form(key:form,child:ListView(padding:const EdgeInsets.fromLTRB(22,8,22,28),children:[
    Container(width:56,height:56,alignment:Alignment.center,decoration:BoxDecoration(color:SI.mint,
     borderRadius:BorderRadius.circular(18)),
     child:const Icon(Icons.volunteer_activism_rounded,color:SI.forest,size:29)),
    const SizedBox(height:17),
    Text('Non devi affrontare\ntutto da solo.',style:Theme.of(context).textTheme.headlineLarge),
    const SizedBox(height:8),
    Text('Raccontaci la tua necessità. La richiesta sarà pubblicata solo dopo la verifica dello staff.',
     style:Theme.of(context).textTheme.bodyMedium),
    const SizedBox(height:16),const DemoBanner(),const SizedBox(height:23),
    const Text('Di quale spesa si tratta?',style:TextStyle(fontWeight:FontWeight.w800,color:SI.ink)),
    const SizedBox(height:9),
    DropdownButtonFormField<String>(initialValue:category,
     decoration:const InputDecoration(prefixIcon:Icon(Icons.category_outlined)),
     items:categoryLabels.entries.where((v)=>v.key!='all').map((v)=>
      DropdownMenuItem(value:v.key,child:Text(v.value))).toList(),
     onChanged:(v){if(v!=null)setState(()=>category=v);}),
    const SizedBox(height:20),
    const Text('Titolo della richiesta',style:TextStyle(fontWeight:FontWeight.w800,color:SI.ink)),
    const SizedBox(height:9),
    TextFormField(controller:title,maxLength:120,
     decoration:const InputDecoration(hintText:'Es. Un aiuto per la prossima bolletta'),
     validator:(v)=>(v?.trim().length??0)<12?'Scrivi almeno 12 caratteri.':null),
    const SizedBox(height:6),
    const Text('Racconta la situazione',style:TextStyle(fontWeight:FontWeight.w800,color:SI.ink)),
    const SizedBox(height:9),
    TextFormField(controller:story,minLines:5,maxLines:8,maxLength:3000,
     decoration:const InputDecoration(hintText:'Spiega in modo chiaro quale spesa devi sostenere e perché.'),
     validator:(v)=>(v?.trim().length??0)<60?'Servono almeno 60 caratteri.':null),
    const SizedBox(height:6),
    const Text('Importo della spesa',style:TextStyle(fontWeight:FontWeight.w800,color:SI.ink)),
    const SizedBox(height:9),
    TextFormField(controller:goal,keyboardType:TextInputType.number,
     decoration:const InputDecoration(prefixText:'€  ',hintText:'Es. 250',
      helperText:'Da 20 a 15.000 euro, solo importi interi nella demo.'),
     validator:(v){
      final n=int.tryParse(v?.trim()??'');
      return n==null||n<20||n>15000?'Inserisci un importo tra 20 e 15.000 euro.':null;
     }),
    const SizedBox(height:24),
    Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(
     color:Colors.white,borderRadius:BorderRadius.circular(17),
     border:Border.all(color:SI.border)),
     child:const Row(children:[
      Icon(Icons.lock_outline_rounded,color:SI.emerald,size:25),SizedBox(width:12),
      Expanded(child:Text('Nella fase successiva ti chiederemo un documento PDF o immagine, visibile solo agli operatori autorizzati.',
       style:TextStyle(fontSize:12,height:1.45,color:SI.ink)))
     ])),
    const SizedBox(height:22),
    FilledButton.icon(onPressed:busy?null:save,icon:const Icon(Icons.arrow_forward_rounded),
     label:Text(busy?'Salvataggio...':'Salva e aggiungi documento')),
    const SizedBox(height:12),
    const Text('Prima del lancio non usare documenti personali autentici senza una informativa privacy completa.',
     style:TextStyle(fontSize:11,color:SI.muted),textAlign:TextAlign.center)
   ])))))
 );
}

class FinishDraftScreen extends StatefulWidget {
 const FinishDraftScreen({super.key,required this.controller,required this.requestId});
 final AppController controller;final int requestId;
 @override State<FinishDraftScreen> createState()=>_FinishDraftScreenState();
}
class _FinishDraftScreenState extends State<FinishDraftScreen>{
 bool busy=false;
 Future<void> finish()async{
  setState(()=>busy=true);
  final success=await uploadAndSubmit(context,widget.controller,widget.requestId);
  if(mounted){setState(()=>busy=false);
   if(success){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content:Text('Richiesta inviata alla verifica manuale.')));
    Navigator.pop(context,true);}
  }
 }
 @override Widget build(BuildContext context)=>Scaffold(
  appBar:AppBar(title:const Text('Completa la bozza')),
  body:Padding(padding:const EdgeInsets.all(24),child:Column(
   crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Icon(Icons.file_upload_outlined,color:SI.emerald,size:46),
    const SizedBox(height:20),
    Text('Manca solo la documentazione.',style:Theme.of(context).textTheme.headlineMedium),
    const SizedBox(height:15),
    const Text('Scegli un PDF, JPG o PNG (max 5 MB) per la verifica privata. Non sarà visibile pubblicamente.'),
    const SizedBox(height:25),
    SizedBox(width:double.infinity,child:FilledButton(
     onPressed:busy?null:finish,child:Text(busy?'Caricamento...':'Carica e invia richiesta'))),
    const SizedBox(height:15),const DemoBanner()
   ]))
 );
}
