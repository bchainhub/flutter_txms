# Flutter TxMS

A Flutter package for encoding and decoding hex messages for SMS/MMS communication. This package provides a robust solution for handling hex-encoded messages across multiple platforms.

[![pub package](https://img.shields.io/pub/v/flutter_txms.svg)](https://pub.dev/packages/flutter_txms)
[![License: CORE](https://img.shields.io/badge/License-CORE-yellow.svg)](LICENSE)

## Features

- 🔄 Hex encoding and decoding
- 📱 SMS/MMS message generation
- 📊 Message segmentation counting
- 💾 File download support
- 📲 Direct SMS/MMS client opening
- 🌐 Cross-platform support (iOS, Android, Web, Desktop)
- ✨ Zero external runtime dependencies
- 🔒 Null safety
- 📚 Comprehensive documentation

## Getting Started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_txms: ^0.1.0
```

## Usage

### Basic Example

```dart
import 'package:flutter_txms/flutter_txms.dart';

void main() {
  final txms = Txms();

  // Encode a hex string
  final encoded = txms.encode('0x48656c6c6f20576f726c64'); // "Hello World"
  print('Encoded: $encoded');

  // Decode back to hex
  final decoded = txms.decode(encoded);
  print('Decoded: $decoded');
}
```

### SMS Generation and Opening

```dart
final txms = Txms();

// Generate SMS URI
final smsUri = txms.sms(
  number: '+12019715152',
  message: '0x48656c6c6f',
  network: 'mainnet',
);
print('SMS URI: $smsUri');

// Open SMS client directly with encoded message
await txms.openSmsClient(
  number: '+12019715152',
  message: '0x48656c6c6f',
  network: 'mainnet',
);

// Open MMS client directly with encoded message
await txms.openMmsClient(
  number: '+12019715152',
  message: '0x48656c6c6f',
  network: 'mainnet',
);
```

### File Operations

```dart
final txms = Txms();

// Save message to file
final filePath = await txms.downloadMessage(
  '0x48656c6c6f20576f726c64',
  optionalFilename: 'hello',
);
print('Saved to: $filePath');
```

### Message Counting

```dart
final txms = Txms();

// Count SMS segments
final smsCount = txms.count('0x48656c6c6f20576f726c64', 'sms');
print('Number of SMS segments: $smsCount');

// Count MMS segments
final mmsCount = txms.count('0x48656c6c6f20576f726c64', 'mms');
print('Number of MMS segments: $mmsCount');
```

## Platform Support

| Android | iOS | Web | macOS | Windows | Linux |
|---------|-----|-----|-------|---------|-------|
| ✅      | ✅  | ✅  | ✅    | ✅     | ✅     |

## Additional Features

- Custom network aliases
- Country-specific endpoints
- Batch message processing
- Platform-specific URI generation
- Comprehensive error handling
- Direct SMS/MMS client launching

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the CORE License - see the [LICENSE](LICENSE) file for details.
