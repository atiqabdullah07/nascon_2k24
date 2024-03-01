import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../core/constants.dart';
import '../../../core/utils.dart';
import 'forgot_pass_screen.dart';
import 'signup_screen.dart';

/// Lets the User to Sign in with an existing Account
class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  /// Local State
  bool lock = false;
  bool showPass = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  /// Global State
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
          case EmailAuthState:

            ///  TODO user specific state related initializations and Progression

            break;
          default:
            setState(() => lock = false);
            break;
        }
      },
      child: LockableScaffold(
        lock: lock,
        widget: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: SvgPicture.asset("assets/components/back_arrow.svg"),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: 132.h,
              bottom: 132.h,
              left: isLandscape ? 0.2.sw : 0.09.sw,
              right: isLandscape ? 0.2.sw : 0.09.sw,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Heading
                Text(
                  "Sign in to your Account",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                /// Spacing
                SizedBox(height: 132.h),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 96.h),
                  child: Form(
                    child: Column(
                      children: [
                        /// Email Field
                        TextFormField(
                          controller: emailController,
                          validator: validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: TextStyle(fontSize: 14.spMax),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            hintText: "Email",
                          ),
                        ),

                        /// spacing
                        SizedBox(height: 46.h),

                        /// Password Field
                        TextFormField(
                          controller: passController,
                          obscureText: !showPass,
                          validator: validatePassword,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: TextStyle(fontSize: 14.spMax),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock),
                            hintText: "Password",
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => showPass = !showPass),
                              icon: Icon(showPass
                                  ? Icons.visibility_outlined
                                  : Icons.visibility),
                            ),
                          ),
                        ),

                        /// spacing
                        SizedBox(height: 46.h),

                        /// Remember and Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => {},
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_box_outline_blank_rounded,
                                    size: 18.spMax,
                                  ),

                                  /// Spacing
                                  SizedBox(width: 8.spMax),

                                  Text(
                                    "Remember me",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const ForgotPassScreen()),
                              ),
                              child: Text(
                                "Forgot password?",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                /// SignUp Button
                ElevatedButton(
                  onPressed: () => authBloc.add(LoginWithEmailPass(
                    email: emailController.text,
                    pass: passController.text,
                  )),
                  child: const Text("Sign in"),
                ),

                /// Other Options for SignUp (Google, Facebook)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 148.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "or continue with",
                        style: TextStyle(fontSize: 16.spMax),
                      ),

                      /// spacing
                      const SizedBox(width: 20),

                      /// Google
                      InkWell(
                        borderRadius: BorderRadius.circular(1.sw),
                        onTap: () => {},
                        child: SvgPicture.asset(
                          "assets/logos/google.svg",
                          height: isLandscape ? 64.w : 128.h,
                          width: isLandscape ? 64.w : 128.h,
                        ),
                      ),

                      /// Facebook
                      InkWell(
                        borderRadius: BorderRadius.circular(1.sw),
                        onTap: () => {},
                        child: SvgPicture.asset(
                          "assets/logos/facebook.svg",
                          height: isLandscape ? 64.w : 128.h,
                          width: isLandscape ? 64.w : 128.h,
                        ),
                      ),
                    ],
                  ),
                ),

                /// Spacing
                SizedBox(height: 48.h),

                /// If have an account already, sign in
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Doesn't have an account?",
                      style: TextStyle(color: kColorGrey),
                    ),

                    /// Spacing
                    SizedBox(width: 10.spMax),

                    /// Sign in
                    InkWell(
                      onTap: () => Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const SignupScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      ),
                      borderRadius: BorderRadius.circular(24.r),
                      child: const Text(
                        "Sign up",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
