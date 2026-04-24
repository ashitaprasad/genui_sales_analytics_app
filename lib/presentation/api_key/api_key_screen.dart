import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

/// A screen that prompts the user for their Amazon Bedrock API key,
/// region, and model ID.
class ApiKeyScreen extends ConsumerStatefulWidget {
  const ApiKeyScreen({super.key});

  @override
  ConsumerState<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends ConsumerState<ApiKeyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _regionController = TextEditingController(text: 'us-west-2');
  final _apiKeyController = TextEditingController();
  final _modelController = TextEditingController(
    text: BedrockCredentials.defaultModelId,
  );
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    // Pre-populate anything already present (e.g. from dart-define / env).
    final existing = ref.read(apiKeyProvider);
    if (existing.region.isNotEmpty) {
      _regionController.text = existing.region;
    }
    if (existing.apiKey.isNotEmpty) {
      _apiKeyController.text = existing.apiKey;
    }
    if (existing.modelId.isNotEmpty) {
      _modelController.text = existing.modelId;
    }
  }

  @override
  void dispose() {
    _regionController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final creds = BedrockCredentials(
      region: _regionController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      modelId: _modelController.text.trim().isEmpty
          ? BedrockCredentials.defaultModelId
          : _modelController.text.trim(),
    );
    ref.read(apiKeyProvider.notifier).setCredentials(creds);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 72,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Sales Analytics',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your Amazon Bedrock API key to get started.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _regionController,
                    decoration: const InputDecoration(
                      labelText: 'AWS Region',
                      hintText: 'e.g. us-west-2',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.public_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _apiKeyController,
                    autofocus: true,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Amazon Bedrock API Key',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.key_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        tooltip: _obscure ? 'Show key' : 'Hide key',
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _modelController,
                    decoration: const InputDecoration(
                      labelText: 'Amazon Bedrock Model ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.memory_outlined),
                    ),
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 32),

                  FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Continue'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
