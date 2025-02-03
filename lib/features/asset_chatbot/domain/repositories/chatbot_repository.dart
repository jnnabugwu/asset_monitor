import 'package:asset_monitor/core/utils/typedef.dart';
import 'package:asset_monitor/features/asset_chatbot/domain/entities/chat_message.dart';

abstract class ChatbotRepository {
  ResultFuture<String> createThread();
  ResultFuture<void> sendMessage(String threadId, String content);
  ResultFuture<List<ChatMessage>> getMessages(String threadId);
}