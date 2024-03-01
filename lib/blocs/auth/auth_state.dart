part of 'auth_bloc.dart';

@immutable
abstract class AuthState {
  final UserCredential? credentials;
  final TaskMakerException? exception;

  const AuthState({this.credentials, this.exception});
}

class AuthInitial extends AuthState {}

class AuthProcessing extends AuthState {
  const AuthProcessing({required super.credentials, required super.exception});
}

class EmailAuthState extends AuthState {
  const EmailAuthState({required super.credentials});
}

class GoogleAuthState extends AuthState {
  const GoogleAuthState({required super.credentials});
}

class FacebookAuthState extends AuthState {
  const FacebookAuthState({required super.credentials});
}

class AuthException extends AuthState {
  const AuthException({required super.credentials, required super.exception});
}

class PassResetEmailSentState extends AuthState {}

class PassResetConfirmState extends AuthState {}

class LogoutState extends AuthState {}
