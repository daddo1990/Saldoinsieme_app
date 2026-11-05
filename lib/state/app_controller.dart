import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/aid_case.dart';
import '../services/api_service.dart';
class AppController extends ChangeNotifier {
 AppController({ApiService? service,FlutterSecureStorage? storage}):
  api=service??ApiService(const String.fromEnvironment('API_BASE_URL',defaultValue:'http://10.0.2.2:8000')),
  _storage=storage??const FlutterSecureStorage();
 final ApiService api;final FlutterSecureStorage _storage;
 List<AidCase> cases=AidCase.examples;
 bool offline=true,busy=false,started=false;
 String? token,name,email;
 bool get isLoggedIn=>token?.isNotEmpty==true;
 Future<void> start() async {
  try {
   token=await _storage.read(key:'saldoinsieme_token');api.token=token;
   if(isLoggedIn){
    try{final me=await api.get('/api/v1/me');name=me['name'] as String?;email=me['email'] as String?;}
    on ApiException catch(e){if(e.statusCode==401)await logout();}
   }
  }catch(_){token=null;api.token=null;}
  started=true;notifyListeners();await refresh();
 }
 Future<void> refresh() async {
  busy=true;notifyListeners();
  try {
   final obj=await api.get('/api/v1/requests');
   cases=(obj['data'] as List).map((v)=>AidCase.fromJson(Map<String,dynamic>.from(v as Map))).toList();
   offline=false;
  }catch(_){cases=AidCase.examples;offline=true;}
  busy=false;notifyListeners();
 }
 Future<void> login(String mail,String password) async {
  final obj=await api.post('/api/v1/auth/login',{'email':mail,'password':password});
  await _saveSession(obj);
 }
 Future<void> register(String userName,String mail,String password) async {
  final obj=await api.post('/api/v1/auth/register',{
   'name':userName,'email':mail,'password':password,'password_confirmation':password,
   'is_adult_confirmed':true,'accept_terms':true});
  await _saveSession(obj);
 }
 Future<void> _saveSession(Map<String,dynamic> obj) async {
  token=obj['token'] as String?;final user=Map<String,dynamic>.from(obj['user'] as Map);
  name=user['name'] as String?;email=user['email'] as String?;api.token=token;
  await _storage.write(key:'saldoinsieme_token',value:token);notifyListeners();
 }
 Future<void> logout() async {
  try{if(isLoggedIn)await api.post('/api/v1/auth/logout',{});}catch(_){}
  await _storage.delete(key:'saldoinsieme_token');token=null;name=null;email=null;api.token=null;notifyListeners();
 }
 Future<List<AidCase>> myRequests() async {
  final obj=await api.get('/api/v1/my/requests');
  return (obj['data'] as List).map((v)=>AidCase.fromJson(Map<String,dynamic>.from(v as Map))).toList();
 }
 Future<List<Map<String,dynamic>>> myPledges() async {
  final obj=await api.get('/api/v1/my/pledges');
  return (obj['data'] as List).map((v)=>Map<String,dynamic>.from(v as Map)).toList();
 }
 Future<int> createCase({required String category,required String title,required String story,required int goalCents}) async {
  final obj=await api.post('/api/v1/requests',{'category':category,'title':title,'story':story,'goal_cents':goalCents});
  return (Map<String,dynamic>.from(obj['data'] as Map)['id'] as num).toInt();
 }
 Future<void> uploadDocument(int id,List<int> bytes,String fileName) async=>api.upload('/api/v1/requests/$id/documents',bytes,fileName).then((_){});
 Future<void> submitCase(int id) async=>api.post('/api/v1/requests/$id/submit',{}).then((_){});
 Future<Map<String,dynamic>> simulate(int id,int amount,String key) async {
  if(id<0||offline)return {'amount_cents':amount,'fee_cents':serviceFeeCents(amount),
   'total_cents':totalCents(amount),'status':'demo_only','is_payment':false};
  final obj=await api.post('/api/v1/pledges',{
   'aid_request_id':id,'amount_cents':amount,'idempotency_key':key});
  return Map<String,dynamic>.from(obj['data'] as Map);
 }
}
