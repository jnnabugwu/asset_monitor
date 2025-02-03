import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:asset_monitor/core/errors/exception.dart';
import 'package:asset_monitor/features/asset_chatbot/data/models/chat_message_model.dart';

abstract class OpenAIRemoteDataSource {
  Future<String> createThread();
  Future<void> sendMessage(String threadId, String content);
  Future<List<ChatMessageModel>> getMessages(String threadId);
}

class OpenAIRemoteDataSourceImpl implements OpenAIRemoteDataSource {
  final http.Client client;
  final String apiKey;
  final String assistantId;
  final String baseUrl = 'https://api.openai.com/v1';

  OpenAIRemoteDataSourceImpl({
    required this.client,
    required this.apiKey,
    required this.assistantId,
  });

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'OpenAI-Beta': 'assistants=v2'
      };

  @override
  Future<String> createThread() async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/threads'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['id'];
      } else {
        throw ServerException(
          message: 'Failed to create thread: ${response.body}',
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Error creating thread: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> sendMessage(String threadId, String content) async {
    try {
      // First, add the message to the thread
      final messageResponse = await client.post(
        Uri.parse('$baseUrl/threads/$threadId/messages'),
        headers: _headers,
        body: json.encode({
          'role': 'user',
          'content': content,
        }),
      );

      if (messageResponse.statusCode != 200) {
        throw ServerException(
          message: 'Failed to send message: ${messageResponse.body}', statusCode: '',
        );
      }

      // Then, run the assistant on the thread
      final runResponse = await client.post(
        Uri.parse('$baseUrl/threads/$threadId/runs'),
        headers: _headers,
        body: json.encode({
          'assistant_id': assistantId,
        }),
      );

      if (runResponse.statusCode != 200) {
        throw ServerException(
          message: 'Failed to run assistant: ${runResponse.body}',
        );
      }

      final runData = json.decode(runResponse.body);
      final runId = runData['id'];

      // Poll for completion
      await _waitForRunCompletion(threadId, runId);
    } catch (e) {
      throw ServerException(
        message: 'Error sending message: ${e.toString()}',
      );
    }
  }

  Future<void> _waitForRunCompletion(String threadId, String runId) async {
    const maxAttempts = 30; // Maximum number of polling attempts
    const delaySeconds = 1; // Delay between polling attempts

    for (var i = 0; i < maxAttempts; i++) {
      final response = await client.get(
        Uri.parse('$baseUrl/threads/$threadId/runs/$runId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to check run status: ${response.body}',
        );
      }

      final data = json.decode(response.body);
      final status = data['status'];

      if (status == 'completed') {
        return;
      } else if (status == 'failed' || status == 'cancelled') {
        throw ServerException(message: 'Run $status: ${data['last_error']}');
      }

      await Future.delayed(Duration(seconds: delaySeconds));
    }

    throw ServerException(message: 'Run timed out');
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String threadId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/threads/$threadId/messages'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final messages = (data['data'] as List)
            .map((message) => ChatMessageModel.fromJson(message))
            .toList();
        
        // Sort messages by timestamp, newest first
        messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return messages;
      } else {
        throw ServerException(
          message: 'Failed to get messages: ${response.body}',
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Error getting messages: ${e.toString()}',
      );
    }
  }
}