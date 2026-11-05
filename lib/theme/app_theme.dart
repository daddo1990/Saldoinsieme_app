import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class SI {
 static const forest=Color(0xFF163E35),emerald=Color(0xFF116C52),mint=Color(0xFFDDF4E4),
 cream=Color(0xFFFAF9F4),ink=Color(0xFF18372E),muted=Color(0xFF7B8C83),
 apricot=Color(0xFFF2B38A),border=Color(0xFFE4EAE4);
 static ThemeData light(){
  final base=ThemeData(useMaterial3:true,scaffoldBackgroundColor:cream,
   colorScheme:ColorScheme.fromSeed(seedColor:emerald,primary:emerald,surface:cream),
   textTheme:GoogleFonts.dmSansTextTheme());
  return base.copyWith(
   appBarTheme:const AppBarTheme(backgroundColor:cream,centerTitle:false,surfaceTintColor:Colors.transparent),
   textTheme:base.textTheme.copyWith(
    headlineLarge:GoogleFonts.dmSans(fontWeight:FontWeight.w800,fontSize:35,height:1.09,letterSpacing:-1.1,color:ink),
    headlineMedium:GoogleFonts.dmSans(fontWeight:FontWeight.w800,fontSize:27,letterSpacing:-.8,color:ink),
    titleLarge:GoogleFonts.dmSans(fontWeight:FontWeight.w800,fontSize:21,letterSpacing:-.5,color:ink),
    titleMedium:GoogleFonts.dmSans(fontWeight:FontWeight.w700,fontSize:16,color:ink),
    bodyLarge:GoogleFonts.dmSans(fontSize:15,height:1.5,color:ink),
    bodyMedium:GoogleFonts.dmSans(fontSize:14,height:1.5,color:muted)),
   filledButtonTheme:FilledButtonThemeData(style:FilledButton.styleFrom(
    backgroundColor:forest,foregroundColor:Colors.white,minimumSize:const Size(0,54),
    padding:const EdgeInsets.symmetric(horizontal:22,vertical:16),
    shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(17)),
    textStyle:GoogleFonts.dmSans(fontWeight:FontWeight.w800,fontSize:15))),
   inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:Colors.white,
    contentPadding:const EdgeInsets.all(16),
    border:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:const BorderSide(color:border)),
    enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:const BorderSide(color:border)),
    focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:const BorderSide(color:emerald,width:1.6))),
  );
 }
}
