import 'package:asset_monitor/core/services/injection_container.dart';
import 'package:asset_monitor/features/asset_chatbot/presentation/chatbot_bloc/chatbot_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatbotProvider extends StatelessWidget {
  final Widget child;

  const ChatbotProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ChatbotBloc>()..add(InitializeChatbot()),
      child: child,
    );
  }
}