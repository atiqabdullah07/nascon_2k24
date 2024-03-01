part of 'user_cubit.dart';

@immutable
abstract class UserState {
  final User? user;
  final TaskMakerException? exception;

  const UserState({this.user, this.exception});
}

class UserInitial extends UserState {}

class UserReset extends UserState {}

class UserProcessing extends UserState {
  const UserProcessing({required super.user});
}

class UserCreated extends UserState {
  const UserCreated({required super.user});
}

class UserFetched extends UserState {
  const UserFetched({required super.user});
}

class UserException extends UserState {
  const UserException({required super.exception});
}
