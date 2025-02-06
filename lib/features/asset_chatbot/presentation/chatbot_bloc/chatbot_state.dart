part of 'chatbot_bloc.dart';

abstract class ChatbotState extends Equatable {
  const ChatbotState();

  @override
  List<Object?> get props => [];
}

class ChatbotInitial extends ChatbotState {}

class ChatbotLoading extends ChatbotState {}

class ChatbotReady extends ChatbotState {
  final String threadId;
  final List<ChatMessage> messages;

  const ChatbotReady({
    required this.threadId,
    this.messages = const [],
  });

  @override
  List<Object?> get props => [threadId,messages];
}

class ChatbotError extends ChatbotState {
  final String message;

  const ChatbotError(this.message);

  @override
  List<Object?> get props => [message];
}