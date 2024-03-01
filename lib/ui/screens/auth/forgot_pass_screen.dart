import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../core/constants.dart';
import '../../../core/utils.dart';
import 'set_new_pass_screen.dart';

class ForgotPassScreen extends StatefulWidget {
  const ForgotPassScreen({super.key});

  @override
  State<ForgotPassScreen> createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  /// local state
  bool lock = false;
  bool emailValid = false;
  StreamSubscription<Uri?>? uriStream;
  final TextEditingController emailController = TextEditingController();

  /// Global State
  late final AuthBloc authBloc;

  @override
  void initState() {
    authBloc = context.read<AuthBloc>();
    super.initState();

    /// Deeplink Helper
    subscribeToDeeplinkStream();
  }

  @override
  void dispose() {
    uriStream?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    /// Returned Widget
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state.runtimeType) {
          case AuthProcessing: // processing indicator
            setState(() => lock = true);
            break;
          case AuthException: // in case of exceptions
            setState(() => lock = false);
            messenger(context).clearSnackBars();
            messenger(context).showSnackBar(
              SnackBar(
                  content: Text(
                "${state.exception?.message}",
                textAlign: TextAlign.center,
              )),
            );
            break;
          case PassResetEmailSentState:
            break;
          default:
            setState(() => lock = false);
            break;
        }
      },
      child: LockableScaffold(
        lock: lock,
        dialog:
            "Please follow the instructions to the email sent to ${emailController.text}.",
        widget: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: SvgPicture.asset("assets/components/back_arrow.svg"),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: isLandscape ? 0.1.sh : 0,
              left: isLandscape ? 0.2.sw : 0.09.sw,
              right: isLandscape ? 0.2.sw : 0.09.sw,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Heading
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 132.h),
                  child: Text(
                    "Forgot\nPassword",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),

                /// Email Field
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 96.h),
                  child: TextFormField(
                    controller: emailController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => setState(() {
                      validateEmail(value) == null
                          ? emailValid = true
                          : emailValid = false;
                    }),
                    style: TextStyle(fontSize: 14.spMax),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      hintText: "Email",
                    ),
                  ),
                ),

                /// SignUp Button
                ElevatedButton(
                  onPressed: !emailValid
                      ? null // disable the button
                      : () => authBloc.add(
                          SendResetPasswordEmail(email: emailController.text)),
                  child: const Text("Reset Password"),
                ),

                /// Spacing
                SizedBox(height: 32.h),

                /// Message
                const Text(
                  "You will receive a reset password link on your email if you are a registered user.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kColorGrey),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void subscribeToDeeplinkStream() async {
    uriStream = await deeplinkUriHandler((uri) {});

    /// Listen to Uri Stream
    uriStream
      ?..onData((uri) {
        if (uri != null) {
          navigatorPopUntilFirst(context);
          materialPush(
            context,
            SetNewPassScreen(oobCode: uri.queryParameters["oobCode"]),
          );
        }
      })

      /// InCase Of Error
      ..onError((error) {
        setState(() => lock = false);
        messenger(context).clearSnackBars();
        messenger(context).showSnackBar(
          SnackBar(
              content: Text(
            "${error.runtimeType} - ${error.toString()} : ${error.hashCode}",
            textAlign: TextAlign.center,
          )),
        );
      });
  }
}
