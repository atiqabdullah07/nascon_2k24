import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../core/exceptions.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    /// Event Mapping
    on<RegisterWithEmailPass>(_registerWithEmailPass);
    on<LoginWithEmailPass>(_loginWithEmailPass);
    on<LoginWithGoogle>(_loginWithGoogle);
    on<LoginWithFacebook>(_loginWithFacebook);
    on<SendResetPasswordEmail>(_sendResetPasswordEmail);
    on<ResetPasswordConfirm>(_resetPassConfirmation);
    on<Logout>(_logout);
  }

  /// registration with Email and Password
  FutureOr<void> _registerWithEmailPass(
      RegisterWithEmailPass event, Emitter<AuthState> emit) async {
    try {
      emit(AuthProcessing(
          credentials: state.credentials, exception: state.exception));

      final credentials = await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email.trim(),
        password: event.pass.trim(),
      );

      emit(EmailAuthState(credentials: credentials));

      /// Exceptions
    } on TaskMakerException catch (exception) {
      emit(AuthException(credentials: state.credentials, exception: exception));
    } on FirebaseException catch (exception) {
      emit(
        AuthException(
          credentials: state.credentials,
          exception: RemoteException(
            message: '${exception.message}',
            code: int.tryParse(exception.code) ?? 500,
          ),
        ),
      );
    }
  }

  /// Login with Email Pass handler
  FutureOr<void> _loginWithEmailPass(
      LoginWithEmailPass event, Emitter<AuthState> emit) async {
    try {
      emit(AuthProcessing(
          credentials: state.credentials, exception: state.exception));

      final credentials = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email.trim(),
        password: event.pass.trim(),
      );

      emit(EmailAuthState(credentials: credentials));

      /// Exceptions
    } on TaskMakerException catch (exception) {
      emit(AuthException(credentials: state.credentials, exception: exception));
    } on FirebaseException catch (exception) {
      emit(
        AuthException(
          credentials: state.credentials,
          exception: RemoteException(
            message: '${exception.message}',
            code: int.tryParse(exception.code) ?? 500,
          ),
        ),
      );
    }
  }

  /// Login With Google handler
  FutureOr<void> _loginWithGoogle(
      LoginWithGoogle event, Emitter<AuthState> emit) async {
    try {
      emit(AuthProcessing(
          credentials: state.credentials, exception: state.exception));

      final credentials = await _firebaseAuth.signInWithProvider(
        GoogleAuthProvider(),
      );

      emit(GoogleAuthState(credentials: credentials));

      /// Exceptions
    } on TaskMakerException catch (exception) {
      emit(AuthException(credentials: state.credentials, exception: exception));
    } on FirebaseException catch (exception) {
      emit(
        AuthException(
          credentials: state.credentials,
          exception: RemoteException(
            message: '${exception.message}',
            code: int.tryParse(exception.code) ?? 500,
          ),
        ),
      );
    }
  }

  /// Login With Facebook handler
  FutureOr<void> _loginWithFacebook(
      LoginWithFacebook event, Emitter<AuthState> emit) async {
    try {
      emit(AuthProcessing(
          credentials: state.credentials, exception: state.exception));
      // Trigger the sign-in flow
      final loginResult = await FacebookAuth.instance.login();

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);

      // Once signed in, return the UserCredential
      final credentials =
          await _firebaseAuth.signInWithCredential(facebookAuthCredential);

      emit(FacebookAuthState(credentials: credentials));
    } on TaskMakerException catch (exception) {
      emit(AuthException(credentials: state.credentials, exception: exception));
    } on FirebaseException catch (exception) {
      emit(
        AuthException(
          credentials: state.credentials,
          exception: RemoteException(
            message: '${exception.message}',
            code: int.tryParse(exception.code) ?? 500,
          ),
        ),
      );
    }
  }

  /// Logout handler
  FutureOr<void> _logout(Logout event, Emitter<AuthState> emit) async {
    try {
      emit(AuthProcessing(
          credentials: state.credentials, exception: state.exception));

      // logout the user
      await _firebaseAuth.signOut();

      emit(LogoutState());
    } on TaskMakerException catch (exception) {
      emit(AuthException(credentials: state.credentials, exception: exception));
    } on FirebaseException catch (exception) {
      emit(
        AuthException(
          credentials: state.credentials,
          exception: RemoteException(
            message: '${exception.message}',
            code: int.tryParse(exception.code) ?? 500,
          ),
        ),
      );
    }
  }

  /// Reset User Password
  FutureOr<void> _sendResetPasswordEmail(
      SendResetPasswordEmail event, Emitter<AuthState> emit) async {
    try {
      emit(AuthProcessing(
          credentials: state.credentials, exception: state.exception));

      // Configure Action Code Settings
      ActionCodeSettings actionCodeSettings = ActionCodeSettings(
        // domain from firebase hosting, use app-links for android and
        // uni_links for getting the data from the deeplink
        url: "https://task-maker-splenify.web.app/reset-password",
        androidInstallApp: false,
        handleCodeInApp: true,
      );

      // send password reset email
      await _firebaseAuth.sendPasswordResetEmail(
        email: event.email.trim(),
        actionCodeSettings: actionCodeSettings,
      );

      emit(PassResetEmailSentState());
    } on TaskMakerException catch (exception) {
      emit(AuthException(credentials: state.credentials, exception: exception));
    } on FirebaseException catch (exception) {
      emit(
        AuthException(
          credentials: state.credentials,
          exception: RemoteException(
            message: '${exception.message}',
            code: int.tryParse(exception.code) ?? 500,
          ),
        ),
      );
    }
  }

  FutureOr<void> _resetPassConfirmation(
      ResetPasswordConfirm event, Emitter<AuthState> emit) async {
    try {
      emit(AuthProcessing(
          credentials: state.credentials, exception: state.exception));

      // Confirm user email code, and set new password
      await _firebaseAuth.confirmPasswordReset(
        code: event.code,
        newPassword: event.newPassword,
      );

      emit(PassResetConfirmState());
    } on TaskMakerException catch (exception) {
      emit(AuthException(credentials: state.credentials, exception: exception));
    } on FirebaseException catch (exception) {
      emit(
        AuthException(
          credentials: state.credentials,
          exception: RemoteException(
            message: '${exception.message}',
            code: int.tryParse(exception.code) ?? 500,
          ),
        ),
      );
    }
  }
}
