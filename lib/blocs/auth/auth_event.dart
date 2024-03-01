part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

/// Authentication Event allowing user to sign up using email and password.
class RegisterWithEmailPass extends AuthEvent {
  final String email;
  final String pass;

  RegisterWithEmailPass({
    required this.email,
    required this.pass,
  });
}

/// Authentication Event allowing user to sign in using email and password.
class LoginWithEmailPass extends AuthEvent {
  final String email;
  final String pass;

  LoginWithEmailPass({required this.email, required this.pass});
}

/// Authentication Event allowing user to RESET their password using provided email.
class SendResetPasswordEmail extends AuthEvent {
  final String email;

  SendResetPasswordEmail({required this.email});
}

class ResetPasswordConfirm extends AuthEvent {
  final String code;
  final String newPassword;

  ResetPasswordConfirm({required this.code, required this.newPassword});
}

/// Authentication Event allowing user to sign in using google account.
class LoginWithGoogle extends AuthEvent {}

/// Authentication Event allowing user to sign in using facebook account.
class LoginWithFacebook extends AuthEvent {}

/// Authentication Event allowing user to log out.
class Logout extends AuthEvent {}
