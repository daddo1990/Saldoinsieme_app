import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saldoinsieme_app/main.dart';
void main(){
 test('The app root is a Flutter Widget',(){
  expect(const SaldoInsiemeApp(),isA<Widget>());
 });
}
