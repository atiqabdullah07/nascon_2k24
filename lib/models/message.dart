import 'dart:convert';

import 'package:equatable/equatable.dart';

enum MessageType { text, contract }

class Message extends Equatable {
  final String id;
  final String sender;
  final String? contract;
  final String? content;
  final MessageType type;
  final DateTime sent;

  const Message({
    required this.id,
    required this.sender,
    required this.type,
    required this.sent,
    this.contract,
    this.content,
  });

  @override
  List<Object?> get props {
    return [
      id,
      sender,
      sent,
      contract,
      content,
      type,
    ];
  }

  Message copyWith({
    String? id,
    String? sender,
    DateTime? sent,
    String? contract,
    String? content,
    MessageType? type,
  }) {
    return Message(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      sent: sent ?? this.sent,
      contract: contract ?? this.contract,
      content: content ?? this.content,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sender': sender,
      'sent': sent.millisecondsSinceEpoch,
      'contract': contract,
      'content': content,
      'type': type.name,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      sender: map['sender'] as String,
      sent: DateTime.fromMillisecondsSinceEpoch(map['sent'] as int),
      contract: map['contract'] as String?,
      content: map['content'] as String?,
      type: MessageType.values.firstWhere((e) => e.name == map['type']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}
