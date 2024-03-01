import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nascon_app/core/utils.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../core/constants.dart';

class SetNewPassScreen extends StatefulWidget {
  final String? oobCode;

  const SetNewPassScreen({super.key, required this.oobCode});

  @override
  State<SetNewPassScreen> createState() => _SetNewPassScreenState();
}

class _SetNewPassScreenState extends State<SetNewPassScreen> {
  /// local state
  bool lock = false;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  /// global state
  late final AuthBloc authBloc;

  @override
  void initState() {
    authBloc = context.read<AuthBloc>();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    ///
    /// Auth Bloc Listener
    ///
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
          case PassResetConfirmState:
            setState(() => lock = false);

            /// Progression
            navigatorPopUntilFirst(context);
            break;
          default:
            setState(() => lock = false);
            break;
        }
      },
      child: Scaffold(
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
                  "Set New\nPassword",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 96.h),
                child: Column(
                  children: [
                    /// Email Field
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        hintText: "Password",
                      ),
                    ),

                    /// spacing
                    SizedBox(height: 46.h),

                    /// Password Field
                    TextField(
                      controller: confirmPasswordController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_reset_rounded),
                        hintText: "Confirm Password",
                      ),
                    ),
                  ],
                ),
              ),

              /// SignUp Button
              ElevatedButton(
                onPressed: () {
                  /// check if both fields are filled
                  if (passwordController.text.trim().isEmpty ||
                      confirmPasswordController.text.trim().isEmpty) {
                    clearSnackBars(context);
                    showSnackBarText(
                        context, "Please fill both fields to continue.");

                    /// check if both passwords are same
                  } else if (passwordController.text.trim() !=
                      confirmPasswordController.text.trim()) {
                    clearSnackBars(context);
                    showSnackBarText(context, "Passwords don't match.");

                    /// continue
                  } else {
                    authBloc.add(
                      ResetPasswordConfirm(
                        code: "${widget.oobCode}",
                        newPassword: passwordController.text.trim(),
                      ),
                    );
                  }
                },
                child: const Text("Save Password"),
              ),

              /// Spacing
              SizedBox(height: 32.h),

              /// Message
              const Text(
                "Sign in with this new password afterwards.",
                textAlign: TextAlign.center,
                style: TextStyle(color: kColorGrey),
              )
            ],
          ),
        ),
      ),
    );
  }
}
