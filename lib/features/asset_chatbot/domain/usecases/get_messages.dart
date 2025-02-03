import 'package:asset_monitor/core/utils/typedef.dart';
import 'package:asset_monitor/features/asset_chatbot/domain/entities/chat_message.dart';
import 'package:asset_monitor/features/asset_chatbot/domain/repositories/chatbot_repository.dart';

class GetMessages {
  final ChatbotRepository repository;

  GetMessages(this.repository);

  ResultFuture<List<ChatMessage>> call(String threadId) async {
    return await repository.getMessages(threadId);
  }
}