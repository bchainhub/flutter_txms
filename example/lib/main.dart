import 'package:flutter/material.dart';
import 'package:flutter_txms/flutter_txms.dart';

void main() {
  // Set custom phone numbers for mainnet (network 1)
  Txms.setCustomPhoneNumbers(
    1, // mainnet
    'us',
    ['+18005551234', '+18005555678'],
  );

  // Set custom phone numbers for testnet (network 3)
  Txms.setCustomPhoneNumbers(
    3, // testnet
    'global',
    ['+18005559876'],
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TXMS Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  final txms = Txms();

                  // Get endpoints with custom numbers
                  final mainnetEndpoints = txms.getEndpoint('mainnet', 'us');
                  print('Mainnet US endpoints: $mainnetEndpoints');

                  final testnetEndpoints = txms.getEndpoint(3, 'global');
                  print('Testnet global endpoints: $testnetEndpoints');

                  // Reset to default numbers
                  Txms.resetCustomPhoneNumbers();

                  // Get default endpoints
                  final defaultEndpoints = txms.getEndpoint('mainnet', 'us');
                  print('Default mainnet US endpoints: $defaultEndpoints');
                },
                child: const Text('Test Custom Numbers'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final txms = Txms();
                  try {
                    final success = await txms.openSmsClient(
                      number: '+12019715152',
                      message: '0x48656c6c6f', // "Hello"
                      network: 'mainnet',
                    );
                    print('SMS client opened: $success');
                  } catch (e) {
                    print('Error opening SMS client: $e');
                  }
                },
                child: const Text('Open SMS with Message'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final txms = Txms();
                  try {
                    final success = await txms.openMmsClient(
                      number: '+12019715152',
                      message: '0x48656c6c6f', // "Hello"
                      network: 'mainnet',
                    );
                    print('MMS client opened: $success');
                  } catch (e) {
                    print('Error opening MMS client: $e');
                  }
                },
                child: const Text('Open MMS with Message'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
