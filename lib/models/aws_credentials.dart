/// Configuration for connecting to Amazon Bedrock using a Bedrock API key
/// (Bearer token authentication).
/// https://docs.aws.amazon.com/bedrock/latest/userguide/api-keys.html
class BedrockCredentials {
  const BedrockCredentials({
    required this.region,
    required this.apiKey,
    required this.modelId,
  });

  /// An empty record used before the user has entered their values.
  const BedrockCredentials.empty() : region = '', apiKey = '', modelId = '';

  /// AWS region that hosts the Bedrock endpoint, e.g. `us-west-2`.
  final String region;

  /// The Bedrock API key (short-term or long-term). Passed as a Bearer token.
  final String apiKey;

  /// The Bedrock model ID or inference profile.
  final String modelId;

  /// The default model used when none is supplied.
  static const String defaultModelId =
      'us.anthropic.claude-sonnet-4-5-20250929-v1:0';

  bool get isValid =>
      region.isNotEmpty && apiKey.isNotEmpty && modelId.isNotEmpty;
}
