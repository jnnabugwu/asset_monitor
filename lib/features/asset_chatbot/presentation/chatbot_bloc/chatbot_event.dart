part of 'chatbot_bloc.dart';

abstract class ChatbotEvent extends Equatable {
  const ChatbotEvent();

  @override
  List<Object?> get props => [];
}

class InitializeChatbot extends ChatbotEvent {}

class SendMessageEvent extends ChatbotEvent {
  final String message;

  const SendMessageEvent({required this.message});

  @override
  List<Object?> get props => [message];
}

class ClearConversation extends ChatbotEvent {}

