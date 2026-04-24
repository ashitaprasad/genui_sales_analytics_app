import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';
import '../../domain/chat_session.dart' show ChatSession;
import '../../providers/providers.dart';
import '../widgets/widgets.dart';

/// The root screen for the Sales Analytics app.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();

  /// Tracks which surface IDs are already shown so we can animate to new ones.
  int _lastKnownSurfaceCount = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _sendMessage(ChatSession session) {
    final text = _messageController.text.trim();
    if (text.isEmpty || session.isProcessing) return;
    _messageController.clear();
    session.sendMessage(text);
  }

  Widget _buildComposer(BuildContext context, ChatSession session) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                enabled: !session.isProcessing,
                decoration: InputDecoration(
                  hintText: 'Ask a follow-up question…',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(session),
                maxLines: 4,
                minLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: session.isProcessing
                  ? null
                  : () => _sendMessage(session),
              icon: const Icon(Icons.send_rounded),
              tooltip: 'Send',
            ),
          ],
        ),
      ),
    );
  }

  void _animateToLastPage(int surfaceCount) {
    if (surfaceCount > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            surfaceCount - 1,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read the session once — it is stable for the lifetime of the ProviderScope.
    // ListenableBuilder handles rebuilds whenever the session calls notifyListeners.
    final session = ref.read(chatSessionProvider)!;

    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final surfaces = session.messages
            .where((m) => m.isSurface)
            .map((m) => m.surfaceId!)
            .toList();

        // Animate to the new surface whenever one is added.
        if (surfaces.length > _lastKnownSurfaceCount) {
          _lastKnownSurfaceCount = surfaces.length;
          _animateToLastPage(surfaces.length);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Sales Analytics'),
            centerTitle: false,
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            bottom: session.isProcessing
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(3),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : null,
            actions: [
              if (surfaces.length > 1)
                PageIndicator(
                  pageController: _pageController,
                  count: surfaces.length,
                ),
              if (session.errorMessage != null)
                IconButton(
                  icon: const Icon(Icons.key_outlined),
                  tooltip: 'Change API Key',
                  onPressed: () => ref.read(apiKeyProvider.notifier).clear(),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: surfaces.isEmpty
                    ? SurfacePlaceholder(
                        isProcessing: session.isProcessing,
                        errorMessage: session.errorMessage,
                        onChangeApiKey: session.errorMessage != null
                            ? () => ref.read(apiKeyProvider.notifier).clear()
                            : null,
                      )
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: surfaces.length,
                        itemBuilder: (context, index) {
                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Surface(
                              surfaceContext: session.surfaceController
                                  .contextFor(surfaces[index]),
                            ),
                          );
                        },
                      ),
              ),
              _buildComposer(context, session),
            ],
          ),
        );
      },
    );
  }
}
