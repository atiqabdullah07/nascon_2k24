import 'dart:convert';

import 'package:equatable/equatable.dart';

class UserOverview extends Equatable {
  final String id;
  final String name;
  final String location;
  final int rating;
  final String pfpUrl;
  final String? about;

  const UserOverview({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.pfpUrl,
    this.about,
  });

  @override
  List<Object?> get props {
    return [
      id,
      name,
      location,
      rating,
      pfpUrl,
      about,
    ];
  }

  UserOverview copyWith({
    String? id,
    String? name,
    String? location,
    int? rating,
    String? pfpUrl,
    String? about,
  }) {
    return UserOverview(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      pfpUrl: pfpUrl ?? this.pfpUrl,
      about: about ?? this.about,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'location': location,
      'rating': rating,
      'pfpUrl': pfpUrl,
      'about': about,
    };
  }

  factory UserOverview.fromMap(Map<String, dynamic> map) {
    return UserOverview(
      id: map['id'] as String,
      name: map['name'] as String,
      location: map['location'] as String,
      rating: map['rating'] as int,
      pfpUrl: map['pfpUrl'] as String,
      about: map['about'] != null ? map['about'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserOverview.fromJson(String source) =>
      UserOverview.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}
