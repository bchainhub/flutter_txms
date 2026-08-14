import 'dart:io';

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

    test('rejects empty and non-hex input', () {
      expect(() => txms.encode(''), throwsFormatException);
      expect(() => txms.encode('0x'), throwsFormatException);
      expect(() => txms.encode('0xGG'), throwsFormatException);
    });

    test('count SMS segments', () {
      const hex = '0x48656c6c6f20576f726c64';
      final count = txms.count(hex, 'sms');
      expect(count, 1);
    });

    test('count MMS segments', () {
      const hex = '0x48656c6c6f20576f726c64';
      final count = txms.count(hex, 'mms');
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

    test('generate MMS URI', () {
      final uri = txms.mms(
        number: '+12019715152',
        message: '0x48656c6c6f',
        network: 'mainnet',
      );
      expect(uri.startsWith('mms:+12019715152?body='), true);
    });

    test('getEndpoint returns correct endpoints', () {
      final endpoints = txms.getEndpoint(1, 'us');
      expect(endpoints['us'], contains('+12019715152'));
    });

    test('includes the XCB mainnet country numbers', () {
      expect(countries['xcb']!['au'], ['+61485883792']);
      expect(countries['xcb']!['gb'], ['+447893984933']);
      expect(countries['xcb']!['nl'], ['+3197058019443']);
      expect(countries['xcb']!['th'], ['+66830551102']);
    });

    test('add new alias', () {
      Txms.addAlias('testnet', 2);
      expect(aliases['testnet'], '2');
      aliases.remove('testnet');
    });

    test('add new country', () {
      Txms.addCountry(1, 'uk', ['+441234567890']);
      expect(countries['xcb']!['uk'], contains('+441234567890'));
      countries['xcb']!.remove('uk');
    });
  });

  group('txms.js network and number selection parity', () {
    tearDown(() {
      Txms.resetCustomPhoneNumbers();
      countries['xcb']!.remove('ca');
      countries['xcb']!.remove('cz');
      countries['xcb']!.remove('de');
      countries['xcb']!.remove('fr');
      countries['xcb']!.remove('no');
      countries.remove('teth');
      aliases.remove('testnet');
    });

    test('supports numeric, canonical, and friendly aliases', () {
      expect(txms.getNumber(), '+12019715152');
      expect(txms.getNumber(network: 1), '+12019715152');
      expect(txms.getNumber(network: 'mainnet'), '+12019715152');
      expect(txms.getNumber(network: 'xcb'), '+12019715152');
      expect(txms.getNumber(network: 3), '+12014835939');
      expect(txms.getNumber(network: 'devin'), '+12014835939');
      expect(txms.getNumber(network: 'xab'), '+12014835939');
    });

    test('normalizes country codes and supports the UK alias', () {
      Txms.addCountry('xcb', 'GB', ['+441234567890']);
      expect(txms.getNumber(iso3166A2: ' gb '), '+441234567890');
      expect(txms.getNumber(iso3166A2: 'UK'), '+441234567890');
      countries['xcb']!.remove('gb');
    });

    test('falls back to a shared calling-code country', () {
      expect(txms.getNumber(iso3166A2: 'ca'), '+12019715152');
    });

    test('falls back by organization population order', () {
      Txms.addCountry(1, 'FR', ['+33123456789']);
      Txms.addCountry(1, 'DE', ['+49123456789']);
      expect(txms.getNumber(iso3166A2: 'sk'), '+49123456789');
    });

    test('falls back from an EEA country to an available EU number', () {
      expect(txms.getNumber(iso3166A2: 'is'), '+3197058019443');
    });

    test('checks EEA numbers before EU numbers', () {
      Txms.addCountry(1, 'NO', ['+4712345678']);
      expect(txms.getNumber(iso3166A2: 'is'), '+4712345678');
    });

    test('falls back globally or returns null when requested', () {
      expect(txms.getNumber(iso3166A2: 'zz'), '+12019715152');
      expect(txms.getNumber(iso3166A2: 'zz', returnNone: true), isNull);
      expect(txms.getNumber(network: 'unknown'), isNull);
    });

    test('supports extensible blockchain pool names and aliases', () {
      Txms.addCountry('teth', 'global', ['+441234567890']);
      Txms.addCountry('teth', 'gb', ['+441234567890']);
      Txms.addAlias('testnet', 'teth');

      expect(
        txms.getNumber(iso3166A2: 'gb', network: 'testnet'),
        '+441234567890',
      );
    });

    test('normalizes endpoint filters and custom number keys', () {
      Txms.setCustomPhoneNumbers('XCB', 'US', ['+18005551234']);
      expect(txms.getEndpoint('MAINNET', 'US'), {
        'us': ['+18005551234'],
      });
    });

    test('boolean default recipient follows the requested network pool', () {
      expect(
        txms.sms(number: true, message: '01', network: 'xab'),
        startsWith('sms:+12014835939?body='),
      );
    });

    test('rejects malformed recipient numbers', () {
      expect(
        () => txms.sms(number: '12019715152', message: '01'),
        throwsFormatException,
      );
      expect(
        () => txms.sms(number: ['+12019715152', 'bad'], message: '01'),
        throwsFormatException,
      );
    });

    test('uses the iOS message URI separator', () {
      expect(
        txms.sms(
          number: '+12019715152',
          message: '01',
          platform: 'ios',
        ),
        contains('&body='),
      );
    });
  });

  group('Custom Phone Numbers Tests', () {
    setUp(() {
      // Reset custom numbers before each test
      Txms.resetCustomPhoneNumbers();
    });

    test('setCustomPhoneNumbers sets numbers correctly', () {
      Txms.setCustomPhoneNumbers(1, 'us', ['+18005551234']);
      final endpoints = txms.getEndpoint(1, 'us');
      expect(endpoints['us'], contains('+18005551234'));
    });

    test('resetCustomPhoneNumbers clears custom numbers', () {
      Txms.setCustomPhoneNumbers(1, 'us', ['+18005551234']);
      Txms.resetCustomPhoneNumbers();
      final endpoints = txms.getEndpoint(1, 'us');
      expect(endpoints['us'], equals(countries['xcb']!['us']));
    });

    test('invalid phone number format throws FormatException', () {
      expect(
        () => Txms.setCustomPhoneNumbers(1, 'us', ['invalid']),
        throwsA(isA<FormatException>()),
      );
    });

    test('custom numbers take precedence over default numbers', () {
      const customNumber = '+18005551234';
      Txms.setCustomPhoneNumbers(1, 'us', [customNumber]);
      final endpoints = txms.getEndpoint(1, 'us');
      expect(endpoints['us']![0], equals(customNumber));
      expect(
        endpoints['us']![0],
        isNot(equals(countries['xcb']!['us']![0])),
      );
    });
  });

  group('Download message parity', () {
    late Directory temporaryDirectory;

    setUp(() {
      temporaryDirectory = Directory.systemTemp.createTempSync('txms-test-');
    });

    tearDown(() {
      temporaryDirectory.deleteSync(recursive: true);
    });

    test('creates nested output directories and derives the filename',
        () async {
      final outputDirectory = Directory(
        '${temporaryDirectory.path}${Platform.pathSeparator}nested',
      );
      final outputPath = await txms.downloadMessage(
        '0x1234567890abcdef',
        optionalPath: outputDirectory.path,
      );

      expect(outputPath, endsWith('123456abcdef.txms.txt'));
      expect(File(outputPath).existsSync(), isTrue);
      expect(
          File(outputPath).readAsStringSync(), txms.encode('1234567890abcdef'));
    });

    test('writes batch messages and slugifies a custom filename', () async {
      final outputPath = await txms.downloadMessage(
        ['01', '02'],
        optionalFilename: 'My Batch File!',
        optionalPath: temporaryDirectory.path,
      );

      expect(outputPath, endsWith('my-batch-file.txms.txt'));
      expect(
        File(outputPath).readAsStringSync(),
        '${txms.encode('01')}\n${txms.encode('02')}',
      );
    });

    test('adds the default batch suffix', () async {
      final outputPath = await txms.downloadMessage(
        ['1234567890abcdef', '02'],
        optionalPath: temporaryDirectory.path,
      );

      expect(outputPath, endsWith('123456abcdef.batch.txms.txt'));
    });
  }, skip: !const bool.fromEnvironment('dart.library.io'));

  group('SMS/MMS Client Tests', () {
    test('openSmsClient generates correct URI', () async {
      expect(
        () => txms.openSmsClient(
          number: '+12019715152',
          message: '0x48656c6c6f',
          network: 'mainnet',
        ),
        throwsA(anything),
      );
    });

    test('openMmsClient generates correct URI', () async {
      expect(
        () => txms.openMmsClient(
          number: '+12019715152',
          message: '0x48656c6c6f',
          network: 'mainnet',
        ),
        throwsA(anything),
      );
    });
  });
}
