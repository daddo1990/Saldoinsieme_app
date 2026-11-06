import 'package:flutter/material.dart';
import 'models/aid_case.dart';
import 'state/app_controller.dart';
import 'theme/app_theme.dart';
import 'widgets/ui.dart';
import 'screens/auth_screen.dart';
import 'screens/create_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/profile_screen.dart';

void main()=>runApp(const SaldoInsiemeApp());
class SaldoInsiemeApp extends StatefulWidget {
 const SaldoInsiemeApp({super.key});
 @override State<SaldoInsiemeApp> createState()=>_SaldoInsiemeAppState();
}
class _SaldoInsiemeAppState extends State<SaldoInsiemeApp> {
 late final AppController controller;
 @override void initState(){super.initState();controller=AppController()..start();}
 @override void dispose(){controller.dispose();super.dispose();}
 @override Widget build(BuildContext context)=>MaterialApp(
  debugShowCheckedModeBanner:false,title:'SaldoInsieme',theme:SI.light(),home:Shell(controller:controller));
}
class Shell extends StatefulWidget {
 const Shell({super.key,required this.controller});
 final AppController controller;
 @override State<Shell> createState()=>_ShellState();
}
class _ShellState extends State<Shell> {
 int tab=0;
 void open(AidCase c)=>Navigator.push(context,MaterialPageRoute(
  builder:(_)=>DetailScreen(controller:widget.controller,item:c)));
 Future<void> create()async{
  if(!widget.controller.isLoggedIn){
   final ok=await Navigator.push<bool>(context,MaterialPageRoute(
    builder:(_)=>AuthScreen(controller:widget.controller)));
   if(!mounted||ok!=true)return;
  }
  if(!mounted)return;
  await Navigator.push(context,MaterialPageRoute(
   builder:(_)=>CreateScreen(controller:widget.controller)));
  if(mounted)await widget.controller.refresh();
 }
 void changeTab(int next){if(next==2){create();return;}setState(()=>tab=next);}
 Widget nav(int index,IconData icon,String label)=>Expanded(child:InkWell(
  onTap:()=>changeTab(index),child:Padding(padding:const EdgeInsets.symmetric(vertical:5),
   child:Column(mainAxisSize:MainAxisSize.min,children:[
    Icon(icon,color:tab==index?SI.emerald:SI.muted,size:25),
    const SizedBox(height:5),
    Text(label,style:TextStyle(fontSize:11,fontWeight:tab==index?FontWeight.w800:FontWeight.w500,
     color:tab==index?SI.forest:SI.muted))
   ]))));
 @override Widget build(BuildContext context)=>Scaffold(
  body:SafeArea(bottom:false,child:IndexedStack(index:tab,children:[
   HomeScreen(controller:widget.controller,onOpen:open,onExplore:()=>changeTab(1),onCreate:create),
   DiscoverScreen(controller:widget.controller,onOpen:open),
   const SizedBox.shrink(),
   ProfileScreen(controller:widget.controller,onCreate:create,onLogin:()async{
    await Navigator.push(context,MaterialPageRoute(builder:(_)=>AuthScreen(controller:widget.controller)));
   })
  ])),
  bottomNavigationBar:SafeArea(top:false,child:Container(
   color:Colors.white,padding:const EdgeInsets.symmetric(horizontal:10,vertical:7),
   child:Row(children:[
    nav(0,Icons.home_rounded,'Esplora'),nav(1,Icons.search_rounded,'Cerca'),
    Expanded(child:InkWell(onTap:create,child:Column(mainAxisSize:MainAxisSize.min,children:[
     Container(width:43,height:43,decoration:BoxDecoration(color:SI.forest,borderRadius:BorderRadius.circular(14)),
      child:const Icon(Icons.add_rounded,color:Colors.white,size:28)),
     const SizedBox(height:3),const Text('Pubblica',style:TextStyle(fontSize:10,fontWeight:FontWeight.w800,color:SI.ink))
    ]))),
    nav(3,Icons.person_outline_rounded,'Profilo')
   ])
  ))
 );
}

class HomeScreen extends StatefulWidget {
 const HomeScreen({super.key,required this.controller,required this.onOpen,required this.onExplore,required this.onCreate});
 final AppController controller;final ValueChanged<AidCase> onOpen;
 final VoidCallback onExplore,onCreate;
 @override State<HomeScreen> createState()=>_HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen>{
 String filter='all';
 @override Widget build(BuildContext context)=>AnimatedBuilder(animation:widget.controller,builder:(context,_){
  final items=widget.controller.cases.where((c)=>filter=='all'||c.category==filter).toList();
  return RefreshIndicator(onRefresh:widget.controller.refresh,color:SI.emerald,
   child:ListView(padding:const EdgeInsets.fromLTRB(20,22,20,30),children:[
    Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
     const Brand(),IconButton(onPressed:widget.onCreate,icon:const Icon(Icons.add_circle_outline_rounded,color:SI.forest,size:29))
    ]),
    const SizedBox(height:25),
    Text('Ciao, facciamo qualcosa di bello.',style:Theme.of(context).textTheme.bodyMedium),
    const SizedBox(height:5),
    RichText(text:TextSpan(style:Theme.of(context).textTheme.headlineLarge,children:const [
     TextSpan(text:'Ci sono gesti che\n'),TextSpan(text:'fanno spazio.',style:TextStyle(color:SI.emerald))
    ])),
    const SizedBox(height:20),
    Container(height:244,clipBehavior:Clip.antiAlias,
     decoration:BoxDecoration(color:SI.forest,borderRadius:BorderRadius.circular(28)),
     child:Stack(children:[
      Positioned(right:-80,top:-105,child:Container(width:300,height:300,decoration:BoxDecoration(
       shape:BoxShape.circle,border:Border.all(color:const Color(0xFF3C886C),width:45)))),
      Positioned(right:18,top:25,child:Icon(Icons.favorite_rounded,size:110,color:SI.mint.withValues(alpha:.22))),
      Padding(padding:const EdgeInsets.all(23),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
       const Text('INSIEME VALE DI PIÙ',style:TextStyle(fontSize:11,fontWeight:FontWeight.w800,
        color:SI.mint,letterSpacing:1.5)),
       const SizedBox(height:18),
       const Text('Il tuo gesto.\nLa loro possibilità.',style:TextStyle(color:Colors.white,fontSize:27,
        fontWeight:FontWeight.w800,height:1.14,letterSpacing:-.7)),
       const Spacer(),
       FilledButton.icon(onPressed:widget.onExplore,icon:const Icon(Icons.arrow_outward_rounded,size:17),
        label:const Text('Scopri le storie'),
        style:FilledButton.styleFrom(backgroundColor:SI.mint,foregroundColor:SI.forest,minimumSize:const Size(0,47)))
      ]))
     ])),
    const SizedBox(height:15),const DemoBanner(),
    const SizedBox(height:25),const SectionTitle('Scegli cosa sostenere'),
    const SizedBox(height:10),
    SizedBox(height:45,child:ListView(scrollDirection:Axis.horizontal,
     children:['all','bollette','affitto','debiti','scuola','salute','altro'].map((c){
      final active=filter==c;
      return Padding(padding:const EdgeInsets.only(right:8),child:ChoiceChip(
       label:Text(categoryLabel(c)),showCheckmark:false,selected:active,
       selectedColor:SI.forest,backgroundColor:Colors.white,
       side:BorderSide(color:active?SI.forest:SI.border),
       labelStyle:TextStyle(color:active?Colors.white:SI.ink,fontSize:12,fontWeight:FontWeight.w700),
       onSelected:(_)=>setState(()=>filter=c)));
     }).toList())),
    const SizedBox(height:23),
    SectionTitle('Storie da conoscere',trailing:'Vedi tutte',onTrailing:widget.onExplore),
    const SizedBox(height:9),
    if(items.isEmpty)const EmptyPanel(title:'Nessuna storia',message:'Scegli un’altra categoria.')
    else ...items.map((c)=>Padding(padding:const EdgeInsets.only(bottom:15),
     child:CaseTile(item:c,onTap:()=>widget.onOpen(c)))),
    const SizedBox(height:9),
    Container(padding:const EdgeInsets.all(23),
     decoration:BoxDecoration(color:SI.mint,borderRadius:BorderRadius.circular(22)),
     child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Icon(Icons.shield_outlined,size:32,color:SI.forest),
      const SizedBox(height:12),Text('La fiducia prima di tutto.',style:Theme.of(context).textTheme.titleLarge),
      const SizedBox(height:6),const Text('Documenti privati, verifica umana e importi reali separati dalle simulazioni. Solo richieste approvate sono pubblicate.',
       style:TextStyle(height:1.55,color:SI.forest))
     ]))
   ]));
 });
}
class DiscoverScreen extends StatefulWidget {
 const DiscoverScreen({super.key,required this.controller,required this.onOpen});
 final AppController controller;final ValueChanged<AidCase> onOpen;
 @override State<DiscoverScreen> createState()=>_DiscoverScreenState();
}
class _DiscoverScreenState extends State<DiscoverScreen>{
 final field=TextEditingController();String filter='all';
 @override void dispose(){field.dispose();super.dispose();}
 @override Widget build(BuildContext context)=>AnimatedBuilder(animation:widget.controller,builder:(context,_){
  final q=field.text.toLowerCase().trim();
  final cases=widget.controller.cases.where((c)=>(filter=='all'||filter==c.category)&&
   (q.isEmpty||c.title.toLowerCase().contains(q)||c.story.toLowerCase().contains(q))).toList();
  return ListView(padding:const EdgeInsets.fromLTRB(20,27,20,30),children:[
   Text('Esplora',style:Theme.of(context).textTheme.headlineLarge),
   Text('Trova una storia che ti sta a cuore.',style:Theme.of(context).textTheme.bodyMedium),
   const SizedBox(height:20),
   TextField(controller:field,onChanged:(_)=>setState((){}),
    decoration:const InputDecoration(hintText:'Cerca una richiesta...',prefixIcon:Icon(Icons.search_rounded))),
   const SizedBox(height:17),
   Wrap(spacing:7,runSpacing:7,children:categoryLabels.entries.map((e){
    final active=e.key==filter;
    return ChoiceChip(label:Text(e.value),selected:active,showCheckmark:false,
     selectedColor:SI.forest,backgroundColor:Colors.white,
     side:BorderSide(color:active?SI.forest:SI.border),
     labelStyle:TextStyle(fontSize:12,fontWeight:FontWeight.w700,color:active?Colors.white:SI.ink),
     onSelected:(_)=>setState(()=>filter=e.key));
   }).toList()),
   const SizedBox(height:21),
   Text('RISULTATI  ·  '+cases.length.toString(),style:const TextStyle(
    fontSize:11,letterSpacing:1.4,color:SI.muted,fontWeight:FontWeight.w900)),
   const SizedBox(height:13),
   if(cases.isEmpty)const EmptyPanel(title:'Nessun risultato',message:'Prova una nuova ricerca.')
   else ...cases.map((c)=>Padding(padding:const EdgeInsets.only(bottom:14),
    child:CaseTile(item:c,compact:true,onTap:()=>widget.onOpen(c))))
  ]);
 });
}
