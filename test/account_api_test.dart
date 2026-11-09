import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:saldoinsieme_app/services/api_service.dart';

void main() {
  test('Balance always distinguishes demo activity from actual funds', () async {
    final api = ApiService('https://example.test', client: MockClient((request) async {
      expect(request.url.path, '/api/v1/me/balance');
      return http.Response(jsonEncode({
        'payments_enabled': false,
        'wallet_enabled': false,
        'balance_available_cents': 0,
        'demo': {'pledges_count': 3}
      }), 200);
    }));
    final data = await api.get('/api/v1/me/balance');
    expect(data['payments_enabled'], false);
    expect(data['balance_available_cents'], 0);
    expect((data['demo'] as Map)['pledges_count'], 3);
  });

  test('Forgot password uses the expected public endpoint', () async {
    final api = ApiService('https://example.test', client: MockClient((request) async {
      expect(request.url.path, '/api/v1/auth/forgot-password');
      expect(request.method, 'POST');
      return http.Response(jsonEncode({'message': 'Istruzioni, se indirizzo valido.'}), 200);
    }));
    final data = await api.post('/api/v1/auth/forgot-password', {'email': 'sample@example.test'});
    expect(data['message'], isNotEmpty);
  });
}
