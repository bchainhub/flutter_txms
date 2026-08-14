# Changelog

## 0.2.2

- Added EFTA to EEA to EU fallback, including Switzerland, and WB6 to EU
  fallback.

## 0.2.1

- Added XCB mainnet numbers for Australia, the Netherlands, Thailand, and the
  United Kingdom.

## 0.2.0

- Added `getNumber` with direct, calling-code, organization, and global fallback selection.
- Added `xcb` and `xab` pool names and aliases matching txms.js 1.3.4.
- Made aliases and country pools extensible by string-based blockchain names.
- Normalized alias and country-code lookups to lowercase, including `UK` to `gb`.
- Added recursive output-directory creation for downloaded messages.
- Made empty and prefix-only hex input report a `FormatException`.
- Updated compatible runtime dependencies, retained Flutter 3.29/Dart
  3.7-compatible constraints, and removed the unused `http` dependency.
- Expanded parity and edge-case tests.

## 0.1.3

- Updated pubspec.yaml
- Upgraded dependencies

## 0.1.2

- Fixed number of segments calculation
- Added missing comments

## 0.1.1

- Updated dependencies
- Fixed pub.dev publishing

## 0.1.0

Initial release of Flutter TxMS 🎉

### Features

- 🔄 Complete Dart/Flutter implementation
- 📱 Cross-platform support
  - Android
  - iOS
  - Web
  - macOS
  - Windows
  - Linux
- 🧪 Comprehensive test coverage
- 📚 Complete API documentation

### Added

- Core `TxMS` class implementation with:
  - Hex encoding/decoding
  - SMS/MMS URI generation
  - Message segmentation counting
  - File download support
  - Network alias management
  - Country-specific endpoints
- Transport interface definition
- Constants management
- Platform-specific optimizations
- Example Flutter application
- Comprehensive test suite

### Developer Experience

- ✨ Zero external runtime dependencies
- 🎯 Strong type definitions
- 🔒 Null safety support
- 📝 Detailed API documentation
- 🔍 Example usage in README
- 🧪 Unit tests

### Documentation

- Full API reference
- Usage examples
- Platform support details
- Contributing guidelines
