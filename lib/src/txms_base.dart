import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/transport.dart';
import 'constants.dart';

class Txms implements Transport {
  static final Map<String, Map<String, List<String>>> _customPhoneNumbers = {};

  static void addAlias(String name, int id) {
    aliases[name] = id;
  }

  static void addCountry(
    dynamic networkId,
    String countryCode,
    List<String> phoneNumbers,
  ) {
    final networkKey = networkId.toString();
    countries[networkKey] ??= {};
    countries[networkKey]![countryCode] = phoneNumbers;
  }

  static void setCustomPhoneNumbers(
    dynamic networkId,
    String countryCode,
    List<String> phoneNumbers,
  ) {
    for (final number in phoneNumbers) {
      if (!RegExp(r'^\+\d+$').hasMatch(number)) {
        throw FormatException('Invalid phone number format', number);
      }
    }

    final networkKey = networkId.toString();
    _customPhoneNumbers[networkKey] ??= {};
    _customPhoneNumbers[networkKey]![countryCode] = phoneNumbers;
  }

  static void resetCustomPhoneNumbers() {
    _customPhoneNumbers.clear();
  }

  List<String> _getPhoneNumbers(String networkKey, String countryCode) {
    if (_customPhoneNumbers.containsKey(networkKey) &&
        _customPhoneNumbers[networkKey]!.containsKey(countryCode)) {
      return _customPhoneNumbers[networkKey]![countryCode]!;
    }

    return countries[networkKey]?[countryCode] ?? [];
  }

  String _slugify(String str) {
    return str
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s_-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  @override
  String encode(String hex) {
    var data = '';
    if (hex.substring(0, 2).toLowerCase() == '0x') {
      hex = hex.substring(2);
    }

    final hextest = RegExp(r'^[0-9a-fA-F]+$');
    if (!hextest.hasMatch(hex)) {
      throw FormatException('Not a hex format', hex);
    }

    if (hex.length % 4 != 0) {
      hex = '0' * (4 - (hex.length % 4)) + hex;
    }

    for (var j = 0; j < hex.length; j += 4) {
      final hexchar = hex.substring(j, j + 4);
      final character = String.fromCharCode(int.parse(hexchar, radix: 16));
      data += character.replaceAllMapped(
        RegExp(r'[\p{C}\p{Z}\ufffd\u007e]', unicode: true),
        (match) =>
            '~${String.fromCharCode(int.parse('01${hexchar.substring(0, 2)}', radix: 16))}${String.fromCharCode(int.parse('01${hexchar.substring(2, 4)}', radix: 16))}',
      );
    }
    return data;
  }

  @override
  String decode(String data) {
    var hex = '';
    for (var i = 0; i < data.length; i++) {
      if (data[i] == '~') {
        hex += data.codeUnitAt(i + 1).toRadixString(16).padLeft(2, '0') +
            data.codeUnitAt(i + 2).toRadixString(16).padLeft(2, '0');
        i += 2;
      } else {
        hex += data.codeUnitAt(i).toRadixString(16).padLeft(4, '0');
      }
    }
    return '0x${hex.replaceAll(RegExp(r'^0+'), '')}';
  }

  @override
  int count(String hex, [String? type]) {
    final message = encode(hex);

    if (type == null) return message.length;

    if (type == 'sms') {
      const singleSmsLimit = 70;
      const multipartSmsLimit = 67;

      if (message.length <= singleSmsLimit) return 1;
      return (message.length / multipartSmsLimit).ceil();
    }

    if (type == 'mms') {
      const mmsSizeLimit = 300 * 1024;
      final messageSizeInBytes = message.length * 2;

      if (messageSizeInBytes <= mmsSizeLimit) return 1;
      return (messageSizeInBytes / mmsSizeLimit).ceil();
    }

    return message.length;
  }

  @override
  Map<String, List<String>> getEndpoint([
    dynamic network,
    dynamic countriesList,
  ]) {
    List<String>? requestedList;
    if (countriesList is List) {
      requestedList = List<String>.from(countriesList);
    } else if (countriesList is String) {
      requestedList = [countriesList];
    }

    final netw = network == null
        ? 1
        : network is String
            ? aliases[network.toLowerCase()] ?? int.parse(network)
            : network as int;

    final networkKey = netw.toString();

    if (requestedList == null) {
      final result = <String, List<String>>{};
      final defaultCountries = countries[networkKey] ?? {};

      for (final country in {
        ...defaultCountries.keys,
        ..._customPhoneNumbers[networkKey]?.keys ?? {},
      }) {
        result[country] = _getPhoneNumbers(networkKey, country);
      }
      return result;
    }

    final endpoints = <String, List<String>>{};
    for (final countryCode in requestedList) {
      final numbers = _getPhoneNumbers(networkKey, countryCode);
      if (numbers.isNotEmpty) {
        endpoints[countryCode] = numbers;
      }
    }
    return endpoints;
  }

  @override
  String sms({
    dynamic number,
    String? message,
    dynamic network,
    bool encodeMessage = true,
    String platform = 'global',
  }) {
    return generateMessageUri(
      'sms',
      number: number,
      message: message,
      network: network,
      encodeMessage: encodeMessage,
      platform: platform,
    );
  }

  @override
  String mms({
    dynamic number,
    String? message,
    dynamic network,
    bool encodeMessage = true,
    String platform = 'global',
  }) {
    return generateMessageUri(
      'mms',
      number: number,
      message: message,
      network: network,
      encodeMessage: encodeMessage,
      platform: platform,
    );
  }

  @override
  String generateMessageUri(
    String type, {
    dynamic number,
    String? message,
    dynamic network,
    bool encodeMessage = true,
    String platform = 'global',
  }) {
    String? endpoint;
    final netw = network == null || network == 1 || network == 'mainnet'
        ? 1
        : network is String
            ? aliases[network.toLowerCase()]!
            : network as int;

    if (number == true) {
      endpoint = countries[netw.toString()]!['global']![0];
    } else if (number is int) {
      endpoint = '+$number';
    } else if (number is String) {
      if (RegExp(r'^\+\d+$').hasMatch(number)) {
        endpoint = number;
      } else {
        throw FormatException('Invalid number format', number);
      }
    } else if (number is List) {
      final validNumbers = number.map((num) {
        if (num is int) {
          return '+$num';
        } else if (num is String && RegExp(r'^\+\d+$').hasMatch(num)) {
          return num;
        } else {
          throw FormatException('Invalid number format', num);
        }
      }).toList();
      endpoint = validNumbers.join(',');
    }

    var encodedMessage = '';
    if (message != null) {
      encodedMessage = Uri.encodeComponent(
        encodeMessage ? encode(message) : message,
      );
    }

    return endpoint != null
        ? '$type:$endpoint${encodedMessage.isNotEmpty ? '${platform == 'ios' ? '&' : '?'}body=$encodedMessage' : ''}'
        : '$type:${platform == 'ios' ? '&' : '?'}body=$encodedMessage';
  }

  @override
  Future<String> downloadMessage(
    dynamic hex, {
    String? optionalFilename,
    String? optionalPath,
  }) async {
    final encodedMessage = hex is List
        ? hex.map((h) => encode(h)).join('\n')
        : encode(hex as String);

    final cleanedHex =
        (hex is List ? hex[0] : hex as String).toLowerCase().startsWith('0x')
            ? (hex is List ? hex[0] : hex as String).substring(2)
            : (hex is List ? hex[0] : hex as String);

    var filename = cleanedHex.length < 12
        ? cleanedHex
        : '${cleanedHex.substring(0, 6)}'
            '${cleanedHex.substring(cleanedHex.length - 6)}';

    if (hex is List && hex.length > 1 && optionalFilename == null) {
      filename = '$filename.batch';
    }

    filename = optionalFilename != null
        ? '${_slugify(optionalFilename)}.txms.txt'
        : '$filename.txms.txt';

    if (Platform.isAndroid || Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      final outputPath = optionalPath != null
          ? path.join(optionalPath, filename)
          : path.join(directory.path, filename);

      final file = File(outputPath);
      await file.writeAsString(encodedMessage);
      return outputPath;
    } else {
      final outputPath =
          optionalPath != null ? path.join(optionalPath, filename) : filename;

      final file = File(outputPath);
      await file.writeAsString(encodedMessage);
      return outputPath;
    }
  }

  /// Opens the device's SMS client with the encoded message
  /// Returns true if the SMS client was opened successfully
  Future<bool> openSmsClient({
    dynamic number,
    String? message,
    dynamic network,
    bool encodeMessage = true,
    String platform = 'global',
  }) async {
    final uri = sms(
      number: number,
      message: message,
      network: network,
      encodeMessage: encodeMessage,
      platform: platform,
    );

    final url = Uri.parse(uri);
    if (await canLaunchUrl(url)) {
      return launchUrl(url);
    }
    throw 'Could not launch SMS client';
  }

  /// Opens the device's MMS client with the encoded message
  /// Returns true if the MMS client was opened successfully
  Future<bool> openMmsClient({
    dynamic number,
    String? message,
    dynamic network,
    bool encodeMessage = true,
    String platform = 'global',
  }) async {
    final uri = mms(
      number: number,
      message: message,
      network: network,
      encodeMessage: encodeMessage,
      platform: platform,
    );

    final url = Uri.parse(uri);
    if (await canLaunchUrl(url)) {
      return launchUrl(url);
    }
    throw 'Could not launch MMS client';
  }
}
