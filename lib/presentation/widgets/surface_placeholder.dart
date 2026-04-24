import 'package:flutter/material.dart';

/// Shown while the AI is generating the first surface, or when an error occurs.
class SurfacePlaceholder extends StatelessWidget {
  const SurfacePlaceholder({
    super.key,
    required this.isProcessing,
    this.errorMessage,
    this.onChangeApiKey,
  });

  final bool isProcessing;
  final String? errorMessage;
  final VoidCallback? onChangeApiKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isProcessing) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  'Building your analytics form…',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ] else if (errorMessage != null) ...[
                Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (onChangeApiKey != null) ...[
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: onChangeApiKey,
                    icon: const Icon(Icons.key_outlined),
                    label: const Text('Change API Key'),
                  ),
                ],
              ] else ...[
                Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text('Sales Analytics', style: theme.textTheme.titleLarge),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
