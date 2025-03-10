/// Transport interface for handling hex-encoded messages in SMS/MMS communication.
/// Provides methods for encoding, decoding, and managing message transport.
abstract class Transport {
  /// Encodes a hex string into a format suitable for SMS/MMS transmission.
  ///
  /// The [hex] parameter should be a valid hexadecimal string, optionally starting with '0x'.
  /// Returns the encoded string ready for transmission.
  String encode(String hex);

  /// Decodes a previously encoded message back to its original hex format.
  ///
  /// The [data] parameter should be the encoded string from [encode].
  /// Returns the original hex string with '0x' prefix.
  String decode(String data);

  /// Counts the number of segments needed to transmit a hex message.
  ///
  /// The [hex] parameter is the hex string to be transmitted.
  /// Optional [type] parameter specifies 'sms' or 'mms' for specific segment counting.
  /// Returns the number of segments needed.
  int count(String hex, [String? type]);

  /// Gets the endpoint information for a specific network and countries.
  ///
  /// Optional [network] parameter specifies the network ID or alias.
  /// Optional [countriesList] parameter filters endpoints by country codes.
  /// Returns a map of country codes to their respective phone numbers.
  Map<String, List<String>> getEndpoint([
    dynamic network,
    dynamic countriesList,
  ]);

  /// Generates an SMS URI with the encoded message.
  ///
  /// Parameters:
  /// - [number]: Target phone number or endpoint
  /// - [message]: Hex message to encode and send
  /// - [network]: Network ID or alias
  /// - [encodeMessage]: Whether to encode the message
  /// - [platform]: Target platform for URI generation
  String sms({
    dynamic number,
    String? message,
    dynamic network,
    bool encodeMessage = true,
    String platform = 'global',
  });

  /// Generates an MMS URI with the encoded message.
  ///
  /// Parameters:
  /// - [number]: Target phone number or endpoint
  /// - [message]: Hex message to encode and send
  /// - [network]: Network ID or alias
  /// - [encodeMessage]: Whether to encode the message
  /// - [platform]: Target platform for URI generation
  String mms({
    dynamic number,
    String? message,
    dynamic network,
    bool encodeMessage = true,
    String platform = 'global',
  });

  /// Generates a message URI for either SMS or MMS.
  ///
  /// Parameters:
  /// - [type]: Message type ('sms' or 'mms')
  /// - [number]: Target phone number or endpoint
  /// - [message]: Hex message to encode and send
  /// - [network]: Network ID or alias
  /// - [encodeMessage]: Whether to encode the message
  /// - [platform]: Target platform for URI generation
  String generateMessageUri(
    String type, {
    dynamic number,
    String? message,
    dynamic network,
    bool encodeMessage = true,
    String platform = 'global',
  });

  /// Downloads a message to a file.
  ///
  /// Parameters:
  /// - [hex]: Hex message or list of messages to save
  /// - [optionalFilename]: Custom filename for the saved message
  /// - [optionalPath]: Custom path for saving the file
  /// Returns the path to the saved file.
  Future<String> downloadMessage(
    dynamic hex, {
    String? optionalFilename,
    String? optionalPath,
  });

  /// Opens the device's SMS client with the encoded message.
  ///
  /// Parameters:
  /// - [number]: Target phone number or endpoint
  /// - [message]: Hex message to encode and send
  /// - [network]: Network ID or alias
  /// - [encodeMessage]: Whether to encode the message
  /// - [platform]: Target platform for URI generation
  /// Returns true if the SMS client was opened successfully.
  Future<bool> openSmsClient({
    dynamic number,
    String? message,
    dynamic network,
    bool encodeMessage = true,
    String platform = 'global',
  });

  /// Opens the device's MMS client with the encoded message.
  ///
  /// Parameters:
  /// - [number]: Target phone number or endpoint
  /// - [message]: Hex message to encode and send
  /// - [network]: Network ID or alias
  /// - [encodeMessage]: Whether to encode the message
  /// - [platform]: Target platform for URI generation
  /// Returns true if the MMS client was opened successfully.
  Future<bool> openMmsClient({
    dynamic number,
    String? message,
    dynamic network,
    bool encodeMessage = true,
    String platform = 'global',
  });
}
