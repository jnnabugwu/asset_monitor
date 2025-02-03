import 'package:asset_monitor/core/errors/exception.dart';
import 'package:asset_monitor/core/errors/failures.dart';
import 'package:asset_monitor/core/utils/typedef.dart';
import 'package:asset_monitor/features/asset_chatbot/data/datasources/openai_remote_datasource.dart';
import 'package:asset_monitor/features/asset_chatbot/domain/entities/chat_message.dart';
import 'package:asset_monitor/features/asset_chatbot/domain/repositories/chatbot_repository.dart';
import 'package:asset_monitor/features/asset_monitoring/data/datasources/asset_local_datasource.dart';
import 'package:asset_monitor/features/asset_monitoring/data/models/asset_model.dart';
import 'package:dartz/dartz.dart';


class ChatbotRepositoryImpl implements ChatbotRepository {
  final OpenAIRemoteDataSource openAIDatasource;
  final AssetLocalDataSource assetLocalDataSource;

  ChatbotRepositoryImpl({
    required this.openAIDatasource,
    required this.assetLocalDataSource,
  });

  @override
  ResultFuture<String> createThread() async {
    try {
      final threadId = await openAIDatasource.createThread();
      return Right(threadId);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: 'Didnt create thread'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 'Didnt create thread'));
    }
  }

  @override
  ResultFuture<void> sendMessage(String threadId, String userMessage) async {
    try {
      final assets = await assetLocalDataSource.getAllAssets();
      final assetContext = _formatAssetsForAI(assets);
      
      final messageWithContext = """
Current Asset Data:
$assetContext

User Question: $userMessage
""";

      await openAIDatasource.sendMessage(threadId, messageWithContext);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: 'Didnt send message'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 'Didnt send message'));
    }
  }

  @override
  ResultFuture<List<ChatMessage>> getMessages(String threadId) async {
    try {
      final messageModels = await openAIDatasource.getMessages(threadId);
      final messages = messageModels.map((model) => ChatMessage(
        id: model.id,
        content: model.content,
        role: model.role,
        timestamp: model.timestamp,
      )).toList();
      return Right(messages);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: 'Didnt get message'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 'Didnt get message'));
    }
  }

  String _formatAssetsForAI(List<AssetModel> assets) {
    final buffer = StringBuffer();
    for (var asset in assets) {
      buffer.writeln("""
Machine ID: ${asset.id}
Name: ${asset.name}
Location: ${asset.location ?? 'Not specified'}
Status: ${asset.status.name}
Temperature: ${asset.temperature ?? 'N/A'}°C
Vibration: ${asset.vibration ?? 'N/A'} Hz
Oil Level: ${asset.oilLevel ?? 'N/A'}%
Last Updated: ${asset.lastUpdated?.toIso8601String() ?? 'N/A'}
-------------------""");
    }
    return buffer.toString();
  }
}