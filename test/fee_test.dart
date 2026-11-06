import 'package:flutter_test/flutter_test.dart';
import 'package:saldoinsieme_app/models/aid_case.dart';

void main(){
 test('The fixed 5% fee is added to a 100 euro help amount',(){
  expect(serviceFeeCents(10000),500);
  expect(totalCents(10000),10500);
 });
 test('Fractional fee always rounds up a cent',(){
  expect(serviceFeeCents(101),6);
  expect(totalCents(101),107);
 });
 test('Preview cases contain no verified paid amount',(){
  expect(AidCase.examples.every((x)=>x.isDemo&&x.fundedCents==0),isTrue);
 });
}
