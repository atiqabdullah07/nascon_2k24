import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../models/user_overview.dart';
import 'message.dart';

class Chat extends Equatable {
  final String id;
  final bool isFavourite;
  final UserOverview sender;
  final UserOverview receiver;
  final Message? lastMessage;

  const Chat({
    required this.id,
    required this.sender,
    required this.receiver,
    this.lastMessage,
    this.isFavourite = false,
  });

  @override
  List<Object?> get props => [id, sender, receiver, lastMessage, isFavourite];

  Chat copyWith({
    String? id,
    UserOverview? sender,
    UserOverview? receiver,
    Message? lastMessage,
    bool? isFavourite,
  }) {
    return Chat(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      lastMessage: lastMessage ?? this.lastMessage,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sender': sender.toMap(),
      'receiver': receiver.toMap(),
      'lastMessage': lastMessage?.toMap(),
      'isFavourite': isFavourite,
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] as String,
      sender: UserOverview.fromMap(
        Map<String, Object?>.from(map['sender'] as Map<Object?, Object?>),
      ),
      receiver: UserOverview.fromMap(
        Map<String, Object?>.from(map['receiver'] as Map<Object?, Object?>),
      ),
      lastMessage: map['lastMessage'] != null
          ? Message.fromMap(
              Map<String, Object?>.from(
                  map['lastMessage'] as Map<Object?, Object?>),
            )
          : null,
      isFavourite: map['isFavourite'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Chat.fromJson(String source) =>
      Chat.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}
