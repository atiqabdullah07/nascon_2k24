import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'chat.dart';
import 'user_overview.dart';

enum UserType { seeker, provider }

class User extends Equatable {
  final String id;
  final String email;
  final String pfp;
  final String username;
  final String location;
  final String education;
  final int rating;
  final int reviewsCount;
  final int responseTime;
  final String? about;
  final String? stripeCuid;
  final List<Chat>? chats;
  final List<String>? favouriteJobs;
  final List<String>? biddenJobs;
  final List<UserOverview>? favouriteSeekers;

  const User({
    required this.id,
    required this.email,
    required this.pfp,
    required this.username,
    required this.location,
    required this.education,
    required this.rating,
    required this.reviewsCount,
    required this.responseTime,
    this.about,
    this.stripeCuid,
    this.chats,
    this.favouriteJobs,
    this.biddenJobs,
    this.favouriteSeekers,
  });

  User copyWith({
    String? id,
    String? email,
    String? about,
    String? pfp,
    String? username,
    String? location,
    String? education,
    int? rating,
    int? reviewsCount,
    int? responseTime,
    String? stripeCuid,
    List<Chat>? chats,
    List<String>? favouriteJobs,
    List<String>? biddenJobs,
    List<UserOverview>? favouriteSeekers,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      about: about ?? this.about,
      pfp: pfp ?? this.pfp,
      username: username ?? this.username,
      location: location ?? this.location,
      education: education ?? this.education,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      responseTime: responseTime ?? this.responseTime,
      stripeCuid: stripeCuid ?? this.stripeCuid,
      chats: chats ?? this.chats,
      favouriteJobs: favouriteJobs ?? this.favouriteJobs,
      biddenJobs: biddenJobs ?? this.biddenJobs,
      favouriteSeekers: favouriteSeekers ?? this.favouriteSeekers,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'about': about,
      'pfp': pfp,
      'username': username,
      'location': location,
      'education': education,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'responseTime': responseTime,
      'stripeCuid': stripeCuid,
      'favouriteJobs': favouriteJobs,
      'biddenJobs': biddenJobs,
      'chats':
          chats?.asMap().map((key, value) => MapEntry(value.id, value.toMap())),
      'favouriteSeekers': favouriteSeekers
          ?.asMap()
          .map((key, value) => MapEntry(value.id, value.toMap())),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      pfp: map['pfp'] as String,
      username: map['username'] as String,
      location: map['location'] as String,
      education: map['education'] as String,
      rating: map['rating'] as int,
      reviewsCount: map['reviewsCount'] as int,
      responseTime: map['responseTime'] as int,
      about: map['about'] as String?,
      stripeCuid: map['stripeCuid'] as String?,
      favouriteJobs: List<String>.from(
          map['favouriteJobs'] as List<Object?>? ?? List.empty()),
      biddenJobs: List<String>.from(
          map['biddenJobs'] as List<Object?>? ?? List.empty()),
      chats:
          List<Chat>.from((map['chats'] as Map<Object?, Object?>?)?.values.map(
                    (e) => Chat.fromMap(
                        Map<String, dynamic>.from(e as Map<Object?, Object?>)),
                  ) ??
              List.empty()),
      favouriteSeekers: List<UserOverview>.from(
          (map['favouriteSeekers'] as Map<Object?, Object?>?)?.values.map(
                    (e) => UserOverview.fromMap(
                        Map<String, dynamic>.from(e as Map<Object?, Object?>)),
                  ) ??
              List.empty()),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      id,
      email,
      pfp,
      username,
      location,
      education,
      rating,
      reviewsCount,
      responseTime,
      stripeCuid,
      chats,
      favouriteJobs,
      favouriteSeekers,
    ];
  }
}
