part of 'messages_cubit.dart';

@immutable
abstract class MessagesState {
  final List<Message>? messages;
  final TaskMakerException? exception;

  const MessagesState({this.messages, this.exception});
}

class MessagesInitial extends MessagesState {}

class MessagesReset extends MessagesState {}

class MessagesProcessing extends MessagesState {
  const MessagesProcessing({required super.messages});
}

class MessagesInitialized extends MessagesState {
  const MessagesInitialized({required super.messages});
}

class MessagesException extends MessagesState {
  const MessagesException({super.messages, super.exception});
}
