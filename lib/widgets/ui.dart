import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/aid_case.dart';
import '../theme/app_theme.dart';

class Brand extends StatelessWidget {
 const Brand({super.key});
 @override Widget build(BuildContext context)=>Row(mainAxisSize:MainAxisSize.min,children:[
  Container(width:38,height:38,decoration:BoxDecoration(color:SI.forest,borderRadius:BorderRadius.circular(12)),
   child:const Icon(Icons.favorite_rounded,color:SI.mint,size:23)),
  const SizedBox(width:9),
  RichText(text:TextSpan(style:GoogleFonts.dmSans(fontSize:24,fontWeight:FontWeight.w900,color:SI.ink,letterSpacing:-1.2),
   children:const [TextSpan(text:'saldo'),TextSpan(text:'insieme',style:TextStyle(fontWeight:FontWeight.w400,color:SI.emerald))]))
 ]);
}
class DemoBanner extends StatelessWidget {
 const DemoBanner({super.key});
 @override Widget build(BuildContext context)=>Container(
  padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:const Color(0xFFFFF1D9),borderRadius:BorderRadius.circular(14)),
  child:const Row(children:[Icon(Icons.info_outline,color:Color(0xFF98651B),size:19),SizedBox(width:10),
   Expanded(child:Text('Anteprima · Nessun pagamento reale è attivo.',style:TextStyle(fontSize:12,fontWeight:FontWeight.w700,color:Color(0xFF825815))))]));
}
class SectionTitle extends StatelessWidget {
 const SectionTitle(this.text,{super.key,this.trailing,this.onTrailing});
 final String text;final String? trailing;final VoidCallback? onTrailing;
 @override Widget build(BuildContext context)=>Row(children:[
  Expanded(child:Text(text,style:Theme.of(context).textTheme.titleLarge)),
  if(trailing!=null)TextButton(onPressed:onTrailing,child:Text(trailing!,style:const TextStyle(color:SI.emerald,fontWeight:FontWeight.w800)))
 ]);
}
IconData categoryIcon(String c)=>switch(c){
 'bollette'=>Icons.bolt_rounded,'affitto'=>Icons.home_rounded,'debiti'=>Icons.receipt_long_rounded,
 'scuola'=>Icons.school_rounded,'salute'=>Icons.favorite_rounded,'emergenze'=>Icons.health_and_safety_rounded,
 _=>Icons.volunteer_activism_rounded
};
Color categoryColor(String c)=>switch(c){
 'bollette'=>const Color(0xFFF4D7A6),'affitto'=>const Color(0xFFBDDAED),
 'debiti'=>const Color(0xFFDEC6EA),'scuola'=>const Color(0xFFD0DDAA),
 'salute'=>const Color(0xFFF0BFB7),_=>const Color(0xFFB7DDD0)
};
class CaseArt extends StatelessWidget {
 const CaseArt({super.key,required this.category,this.height=142});
 final String category;final double height;
 @override Widget build(BuildContext context)=>ClipRRect(borderRadius:BorderRadius.circular(18),
  child:SizedBox(height:height,child:Stack(children:[
   Positioned.fill(child:ColoredBox(color:categoryColor(category))),
   Positioned(top:-67,right:-40,child:Container(width:195,height:195,decoration:BoxDecoration(
    shape:BoxShape.circle,border:Border.all(width:28,color:Colors.white.withValues(alpha:.33))))),
   Positioned(bottom:-95,right:55,child:Container(width:185,height:185,decoration:BoxDecoration(
    color:Colors.white.withValues(alpha:.22),shape:BoxShape.circle))),
   Center(child:Icon(categoryIcon(category),color:SI.forest.withValues(alpha:.86),size:height*.52)),
   Positioned(top:17,left:17,child:Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:7),
    decoration:BoxDecoration(color:Colors.white.withValues(alpha:.78),borderRadius:BorderRadius.circular(25)),
    child:Text(categoryLabel(category).toUpperCase(),style:const TextStyle(
     fontSize:10,fontWeight:FontWeight.w900,color:SI.forest,letterSpacing:1))))
  ])));
}
class CaseTile extends StatelessWidget {
 const CaseTile({super.key,required this.item,required this.onTap,this.compact=false});
 final AidCase item;final VoidCallback onTap;final bool compact;
 @override Widget build(BuildContext context)=>Material(color:Colors.white,borderRadius:BorderRadius.circular(23),
  child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(23),child:Container(
   decoration:BoxDecoration(borderRadius:BorderRadius.circular(23),border:Border.all(color:SI.border)),
   padding:const EdgeInsets.all(13),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    CaseArt(category:item.category,height:compact?108:146),
    const SizedBox(height:13),
    Row(children:[Icon(item.isDemo?Icons.science_outlined:Icons.verified_outlined,size:16,color:SI.emerald),
     const SizedBox(width:6),Text(item.isDemo?'Esempio fittizio':item.verified?'Documenti verificati':'Richiesta pubblicata',
      style:const TextStyle(color:SI.emerald,fontWeight:FontWeight.w700,fontSize:11))]),
    const SizedBox(height:8),
    Text(item.title,maxLines:2,overflow:TextOverflow.ellipsis,style:GoogleFonts.dmSans(
     color:SI.ink,fontSize:18,fontWeight:FontWeight.w800,height:1.19)),
    const SizedBox(height:14),
    ClipRRect(borderRadius:BorderRadius.circular(10),child:LinearProgressIndicator(
     value:item.progress,minHeight:6,backgroundColor:SI.border,
     valueColor:const AlwaysStoppedAnimation<Color>(SI.emerald))),
    const SizedBox(height:9),
    Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
     Text('Verificati '+euro(item.fundedCents),style:const TextStyle(fontSize:12,color:SI.muted)),
     Text('di '+euro(item.goalCents),style:const TextStyle(fontSize:12,color:SI.ink,fontWeight:FontWeight.w800))
    ])
   ]))));
}
class EmptyPanel extends StatelessWidget {
 const EmptyPanel({super.key,required this.title,required this.message});
 final String title,message;
 @override Widget build(BuildContext context)=>Container(
  padding:const EdgeInsets.all(27),width:double.infinity,
  decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20)),
  child:Column(children:[const Icon(Icons.favorite_border_rounded,color:SI.emerald,size:36),
   const SizedBox(height:12),Text(title,style:Theme.of(context).textTheme.titleMedium),
   const SizedBox(height:7),Text(message,textAlign:TextAlign.center,style:Theme.of(context).textTheme.bodyMedium)]));
}
void showFailure(BuildContext context,Object e){
 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString()),backgroundColor:SI.forest,
  behavior:SnackBarBehavior.floating));
}
