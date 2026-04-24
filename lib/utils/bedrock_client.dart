import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

/// Thin client for Amazon Bedrock's Converse API.
class BedrockClient {
  BedrockClient({
    required this.region,
    required this.apiKey,
    required this.modelId,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String region;
  final String apiKey;
  final String modelId;
  final http.Client _httpClient;
  final Logger _logger = Logger('BedrockClient');

  Uri get _uri => Uri.https(
    'bedrock-runtime.$region.amazonaws.com',
    '/model/$modelId/converse',
  );

  /// Sends a raw Converse request and returns the parsed JSON response.
  ///
  /// [messages] are passed through untouched so the caller can use the full
  /// content-block palette (`text`, `toolUse`, `toolResult`, …). If
  /// [toolConfig] is non-null, it is forwarded as-is.
  Future<Map<String, Object?>> converseRaw({
    required List<Map<String, Object?>> system,
    required List<Map<String, Object?>> messages,
    Map<String, Object?>? toolConfig,
    int maxTokens = 8192,
    double temperature = 0.2,
  }) async {
    final requestBody = <String, Object?>{
      'system': system,
      'messages': messages,
      'inferenceConfig': {'maxTokens': maxTokens, 'temperature': temperature},
      // ignore: use_null_aware_elements
      if (toolConfig != null) 'toolConfig': toolConfig,
    };

    _logger.fine('POST ${_uri.toString()}');

    final http.Response response;
    try {
      response = await _httpClient.post(
        _uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(requestBody),
      );
    } on Exception catch (e) {
      throw BedrockConnectionException('Connection failed: $e');
    }

    _logger.fine('Response status: ${response.statusCode}');

    if (response.statusCode >= 400) {
      throw BedrockApiException(response.statusCode, response.body);
    }

    return jsonDecode(response.body) as Map<String, Object?>;
  }

  void close() => _httpClient.close();
}

/// Thrown when Bedrock returns an HTTP error status code (4xx/5xx).
class BedrockApiException implements Exception {
  const BedrockApiException(this.statusCode, this.responseBody);

  final int statusCode;
  final String responseBody;

  @override
  String toString() => 'BedrockApiException: HTTP $statusCode - $responseBody';
}

/// Thrown when a network connection failure occurs.
class BedrockConnectionException implements Exception {
  const BedrockConnectionException(this.message);

  final String message;

  @override
  String toString() => 'BedrockConnectionException: $message';
}
