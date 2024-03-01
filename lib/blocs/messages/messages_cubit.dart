import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';

import '../../core/exceptions.dart';
import '../../models/message.dart';

part 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  final DatabaseReference _messagesRef =
      FirebaseDatabase.instance.ref("messages");
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref("users");
  late StreamSubscription<DatabaseEvent> _messagesStream;

  MessagesCubit() : super(MessagesInitial());

  /// Initialize Messages Stream for chat
  void initializeChat(String cid) async {
    try {
      final chatRef = _messagesRef.child(cid);

      _messagesStream = chatRef.onValue.listen((event) {
        List<Message> container = List.empty(growable: true);
        if (event.snapshot.value != null) {
          final messages = event.snapshot.value as Map<Object?, Object?>;

          for (var messageData in messages.values) {
            final data = messageData as Map<Object?, Object?>;
            final messageAttrs = Map<String, Object?>.from(data);
            final message = Message.fromMap(messageAttrs);

            container.add(message);
          }
        }

        /// sort messages
        container.sort((e, f) => e.sent.compareTo(f.sent));
        container = container.reversed.toList();

        emit(MessagesInitialized(messages: container));
      });

      /// on any exception
    } on TaskMakerException catch (exception) {
      emit(MessagesException(messages: state.messages, exception: exception));
    } on FirebaseException catch (exception) {
      emit(MessagesException(
        messages: state.messages,
        exception: RemoteException(
          message: "${exception.message}",
          code: int.tryParse(exception.code) ?? 500,
        ),
      ));
    }
  }

  /// Send a Text Message in chat
  void sendMessage(
    String sender,
    String receiver,
    String content,
    String cid,
  ) async {
    try {
      final chatMessagesRef = _messagesRef.child(cid);

      // get a new message ref
      final newMessageRef = chatMessagesRef.push();

      if (newMessageRef.key != null) {
        // create new message
        final message = Message(
          id: newMessageRef.key!,
          sender: sender,
          type: MessageType.text,
          content: content.trim(),
          sent: DateTime.now(),
        );

        await newMessageRef.set(message.toMap());

        /// update the last message now in sender and receiver chat
        final senderChatRef = _usersRef.child(sender).child("chats").child(cid);
        final receiverChatRef =
            _usersRef.child(receiver).child("chats").child(cid);

        // update relevant chat last message
        await senderChatRef.update({"lastMessage": message.toMap()});
        await receiverChatRef.update({"lastMessage": message.toMap()});
      }

      /// on any exception
    } on TaskMakerException catch (exception) {
      emit(MessagesException(messages: state.messages, exception: exception));
    } on FirebaseException catch (exception) {
      emit(MessagesException(
        messages: state.messages,
        exception: RemoteException(
          message: "${exception.message}",
          code: int.tryParse(exception.code) ?? 500,
        ),
      ));
    }
  }

  /// Send a Text Message in chat
  void sendContract(
    String sender,
    String receiver,
    String contractId,
    String cid,
  ) async {
    try {
      final chatMessagesRef = _messagesRef.child(cid);

      // get a new message ref
      final newMessageRef = chatMessagesRef.push();

      if (newMessageRef.key != null) {
        // create new message
        final message = Message(
          id: newMessageRef.key!,
          sender: sender,
          type: MessageType.contract,
          contract: contractId,
          sent: DateTime.now(),
        );

        await newMessageRef.set(message.toMap());

        /// update the last message now in sender and receiver chat
        final senderChatRef = _usersRef.child(sender).child("chats").child(cid);
        final receiverChatRef =
            _usersRef.child(receiver).child("chats").child(cid);

        // update relevant chat last message
        await senderChatRef.update({"lastMessage": message.toMap()});
        await receiverChatRef.update({"lastMessage": message.toMap()});
      }

      /// on any exception
    } on TaskMakerException catch (exception) {
      emit(MessagesException(messages: state.messages, exception: exception));
    } on FirebaseException catch (exception) {
      emit(MessagesException(
        messages: state.messages,
        exception: RemoteException(
          message: "${exception.message}",
          code: int.tryParse(exception.code) ?? 500,
        ),
      ));
    }
  }

  ///
  /// Dispose
  ///
  void dispose() async {
    await _messagesStream.cancel();
    emit(MessagesReset());
  }
}
