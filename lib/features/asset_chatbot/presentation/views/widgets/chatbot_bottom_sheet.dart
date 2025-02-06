import 'package:asset_monitor/features/asset_chatbot/domain/entities/chat_message.dart';
import 'package:asset_monitor/features/asset_chatbot/presentation/chatbot_bloc/chatbot_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatbotBottomSheet extends StatelessWidget {
  const ChatbotBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.4, 0.6, 0.9],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            children: [
              CustomScrollView(
                controller: scrollController,
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => Navigator.pop(context),
                            tooltip: 'Close chat',
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              context.read<ChatbotBloc>().add(ClearConversation());
                            },
                            tooltip: 'Clear conversation',
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Chat content
                  SliverFillRemaining(
                    hasScrollBody: true,
                    child: BlocBuilder<ChatbotBloc, ChatbotState>(
                      builder: (context, state) {
                        if (state is ChatbotLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state is ChatbotError) {
                          return Center(
                            child: Text(
                              state.message,
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        if (state is ChatbotReady) {
                          if (state.messages.isEmpty) {
                            return const Center(
                              child: Text('Start a conversation about your machines!'),
                            );
                          }

                          return ListView.builder(
                            reverse: true,
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 80,
                            ),
                            itemCount: state.messages.length,
                            itemBuilder: (context, index) {
                              return ChatMessageBubble(
                                message: state.messages[index],
                              );
                            },
                          );
                        }

                        return const Center(
                          child: Text('Start a conversation!'),
                        );
                      },
                    ),
                  ),
                ],
              ),
              // Input field at bottom
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MessageInputField(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: SelectableText(
          message.content,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class MessageInputField extends StatefulWidget {
  const MessageInputField({super.key});

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    FocusScope.of(context).unfocus();

    context.read<ChatbotBloc>().add(
      SendMessageEvent(message: _controller.text.trim()),
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Ask about machine status...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}