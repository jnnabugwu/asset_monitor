import 'package:asset_monitor/features/asset_chatbot/domain/entities/chat_message.dart';
import 'package:asset_monitor/features/asset_chatbot/domain/usecases/create_thread.dart';
import 'package:asset_monitor/features/asset_chatbot/domain/usecases/get_messages.dart';
import 'package:asset_monitor/features/asset_chatbot/domain/usecases/send_message.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';


part 'chatbot_event.dart';
part 'chatbot_state.dart';

class ChatbotBloc extends Bloc<ChatbotEvent, ChatbotState> {
  final CreateThread createThread;
  final SendMessage sendMessage;
  final GetMessages getMessages;

  ChatbotBloc({
    required this.createThread,
    required this.sendMessage,
    required this.getMessages,
  }) : super(ChatbotInitial()) {
    on<InitializeChatbot>(_onInitializeChatbot);
    on<SendMessageEvent>(_onSendMessage);
    on<ClearConversation>(_onClearConversation);
  }

  Future<void> _onInitializeChatbot(
    InitializeChatbot event,
    Emitter<ChatbotState> emit,
  ) async {
    emit(ChatbotLoading());
    
    final result = await createThread();
    
    result.fold(
      (failure) => emit(ChatbotError(failure.message)),
      (newThreadId) {
        emit(ChatbotReady(threadId: newThreadId));
      },
    );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatbotState> emit,
  ) async {
    if (state is! ChatbotReady) {
      emit(const ChatbotError('Chat not initialized'));
      return;
    }

    final threadId = (state as ChatbotReady).threadId;
    emit(ChatbotLoading());

    final sendResult = await sendMessage(threadId, event.message);
    
    await sendResult.fold(
      (failure) async => emit(ChatbotError(failure.message)),
      (_) async {
        final messagesResult = await getMessages(threadId);
        
        messagesResult.fold(
          (failure) => emit(ChatbotError(failure.message)),
          (messages) => emit(ChatbotReady(messages: messages
                            , threadId: threadId)),
        );
      },
    );
  }

  Future<void> _onClearConversation(
    ClearConversation event,
    Emitter<ChatbotState> emit,
  ) async {
    emit(ChatbotLoading());
    
    final result = await createThread();
    
    result.fold(
      (failure) => emit(ChatbotError(failure.message)),
      (newThreadId) {
        emit(ChatbotReady(threadId: newThreadId));
      },
    );
  }
}