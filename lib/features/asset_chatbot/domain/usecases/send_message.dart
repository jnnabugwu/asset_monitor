import 'package:asset_monitor/core/utils/typedef.dart';
import 'package:asset_monitor/features/asset_chatbot/domain/repositories/chatbot_repository.dart';

class SendMessage {
  final ChatbotRepository repository;

  SendMessage(this.repository);

  ResultFuture<void> call(String threadId, String message) async {
    return await repository.sendMessage(threadId, message);
  }
}