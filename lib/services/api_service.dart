import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
class ApiException implements Exception {
 const ApiException(this.message,[this.statusCode]);
 final String message;final int? statusCode;
 @override String toString()=>message;
}
class ApiService {
 ApiService(this.baseUrl,{http.Client? client}):_client=client??http.Client();
 final String baseUrl;final http.Client _client;
 String? token;
 Uri url(String path)=>Uri.parse(baseUrl+path);
 Map<String,String> get headers=>{'Accept':'application/json','Content-Type':'application/json',if(token!=null)'Authorization':'Bearer '+token!};
 Future<Map<String,dynamic>> get(String path) async {
  try {return parse(await _client.get(url(path),headers:headers).timeout(const Duration(seconds:12)));}
  on ApiException{rethrow;}catch(_){throw const ApiException('Impossibile contattare il server.');}
 }
 Future<Map<String,dynamic>> post(String path,Map<String,dynamic> body) async {
  try {return parse(await _client.post(url(path),headers:headers,body:jsonEncode(body)).timeout(const Duration(seconds:18)));}
  on ApiException{rethrow;}catch(_){throw const ApiException('Impossibile contattare il server.');}
 }
 Future<Map<String,dynamic>> upload(String path,List<int> bytes,String name) async {
  try {
   final req=http.MultipartRequest('POST',url(path));req.headers['Accept']='application/json';
   if(token!=null)req.headers['Authorization']='Bearer '+token!;
   req.files.add(http.MultipartFile.fromBytes('document',bytes,filename:name));
   final response=await _client.send(req).timeout(const Duration(seconds:30));
   return parse(await http.Response.fromStream(response));
  }on ApiException{rethrow;}catch(_){throw const ApiException('Caricamento non riuscito.');}
 }
 Map<String,dynamic> parse(http.Response response){
  Map<String,dynamic> obj;
  try {obj=jsonDecode(utf8.decode(response.bodyBytes)) as Map<String,dynamic>;}
  catch(_){throw ApiException('Risposta non valida.',response.statusCode);}
  if(response.statusCode>=400){
   String? fieldError;final errors=obj['errors'];
   if(errors is Map && errors.isNotEmpty){final first=errors.values.first;if(first is List && first.isNotEmpty)fieldError=first.first.toString();}
   throw ApiException(fieldError??obj['message']?.toString()??'Operazione non riuscita.',response.statusCode);
  }
  return obj;
 }
}
