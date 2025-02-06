import 'package:asset_monitor/features/asset_chatbot/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.content,
    required super.role,
    required super.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    String content = json['content'][0]['text']['value'];

 // First remove specific file citation patterns in numbers
  content = content
    // Remove number:number assets.json pattern
    .replaceAll(RegExp(r'\d+:\d+\s*assets\.json'), '') 
    // Remove any remaining citations
    .replaceAll(RegExp(r'\.?\s*═+\s*$'), '')
    .replaceAll(RegExp(r'\.?\s*▮+\s*$'), '')
    .replaceAll(RegExp(r'\.?\s*ã.*?ã\.?\s*$'), '')
    // Only keep alphanumeric and specific punctuation
    .replaceAll(RegExp(r'[^a-zA-Z0-9\s:;!.,?#%-]'), '')
    // Clean up any double spaces and trim
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();
      // Clean up any double spaces and trim
      content = content
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return ChatMessageModel(
      id: json['id'],
      content: content,
      role: json['role'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'role': role,
    'timestamp': timestamp.toIso8601String(),
  };
}