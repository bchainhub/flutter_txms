import 'package:flutter/material.dart';
import 'package:flutter_txms/flutter_txms.dart';

void main() {
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
