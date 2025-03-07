import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_txms/flutter_txms.dart';

void main() {
  late Txms txms;

  setUp(() {
    txms = Txms();
  });

  group('TXMS Tests', () {
    test('encode/decode hex string', () {
      const hex = '0x48656c6c6f20576f726c64'; // "Hello World"
      final encoded = txms.encode(hex);
      final decoded = txms.decode(encoded);
      expect(decoded.toLowerCase(), hex.toLowerCase());
    });

    test('count SMS segments', () {
      const hex = '0x48656c6c6f20576f726c64';
      final count = txms.count(hex, 'sms');
      expect(count, 1);
    });

    test('generate SMS URI', () {
      final uri = txms.sms(
        number: '+12019715152',
        message: '0x48656c6c6f',
        network: 'mainnet',
      );
      expect(uri.startsWith('sms:+12019715152?body='), true);
    });

    test('getEndpoint returns correct endpoints', () {
      final endpoints = txms.getEndpoint(1, 'us');
      expect(endpoints['us'], contains('+12019715152'));
    });

    test('add new alias', () {
      Txms.addAlias('testnet', 2);
      expect(aliases['testnet'], 2);
    });

    test('add new country', () {
      Txms.addCountry(1, 'uk', ['+441234567890']);
      expect(countries['1']!['uk'], contains('+441234567890'));
    });
  });
}
