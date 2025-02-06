import 'package:asset_monitor/core/errors/exception.dart';
import 'package:asset_monitor/core/errors/failures.dart';
import 'package:asset_monitor/core/utils/typedef.dart';
import 'package:asset_monitor/features/asset_chatbot/data/datasources/openai_remote_datasource.dart';
import 'package:asset_monitor/features/asset_chatbot/domain/entities/chat_message.dart';
import 'package:asset_monitor/features/asset_chatbot/domain/repositories/chatbot_repository.dart';
import 'package:dartz/dartz.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  final OpenAIRemoteDataSource openAIDatasource;

  ChatbotRepositoryImpl({
    required this.openAIDatasource,
  });

  @override
  ResultFuture<String> createThread() async {
    try {
      final threadId = await openAIDatasource.createThread();
      return Right(threadId);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message, 
        statusCode: 'Didnt create the thread'
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(), 
        statusCode: 'Didnt create the thread'
      ));
    }
  }

  @override
  ResultFuture<void> sendMessage(String threadId, String userMessage) async {
    try {
      // Just send the user's message directly - the Assistant already has file access
      await openAIDatasource.sendMessage(threadId, userMessage);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message, 
        statusCode: 'Didnt send the message'
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(), 
        statusCode: 'Didnt send the message'
      ));
    }
  }

  @override
  ResultFuture<List<ChatMessage>> getMessages(String threadId) async {
    try {
      final messageModels = await openAIDatasource.getMessages(threadId);

      print('Raw message models: $messageModels'); 
      
      final messages = messageModels.map((model) {
      print('Model ID type: ${model.id.runtimeType}');
      print('Model timestamp type: ${model.timestamp.runtimeType}');


        return ChatMessage(
        id: model.id,
        content: model.content,
        role: model.role,
        timestamp: model.timestamp,
      );
      }).toList();
      return Right(messages);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message, 
        statusCode: 'Didnt get any message'
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(), 
        statusCode: 'Didnt get any message'
      ));
    }
  }
}