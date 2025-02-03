import 'package:asset_monitor/core/usecases/usecase.dart';
import 'package:asset_monitor/core/utils/typedef.dart';
import 'package:asset_monitor/features/asset_chatbot/domain/repositories/chatbot_repository.dart';

class CreateThread extends UsecaseWithoutParams<String>{
  final ChatbotRepository repository;

  CreateThread(this.repository);

  @override
  ResultFuture<String> call() async {
      return await repository.createThread();
  }
}