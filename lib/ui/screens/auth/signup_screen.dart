import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../core/constants.dart';
import '../../../core/utils.dart';
import 'signin_screen.dart';

/// Lets the User to create a new Account
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  /// Local State
  bool isProcessing = false;
  bool showPass = false;
  final TextEditingController nameController = TextEditingController();
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
            setState(() => isProcessing = true);
            break;
          case AuthException: // in case of exceptions
            setState(() => isProcessing = false);
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

            ///  TODO user specific state related initializations

            /// Progression
            setState(() => isProcessing = false);
            navigator(context).popUntil((route) => route.isFirst);
            break;
          default:
            setState(() => isProcessing = false);
            break;
        }
      },
      child: LockableScaffold(
        lock: isProcessing,
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
                    "Create your Account",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 96.h),
                  child: Form(
                    child: Column(
                      children: [
                        /// Username Field
                        TextFormField(
                          controller: nameController,
                          keyboardType: TextInputType.name,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: null,
                          style: TextStyle(fontSize: 13.spMax),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            hintText: "Username",
                          ),
                        ),

                        /// spacing
                        46.verticalSpace,

                        /// Email Field
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: validateEmail,
                          style: TextStyle(fontSize: 13.spMax),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            hintText: "Email",
                          ),
                        ),

                        /// spacing
                        46.verticalSpace,

                        /// Password Field
                        TextFormField(
                          controller: passController,
                          obscureText: !showPass,
                          validator: validatePassword,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.visiblePassword,
                          style: TextStyle(fontSize: 13.spMax),
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
                      ],
                    ),
                  ),
                ),

                /// SignUp Button
                ElevatedButton(
                  onPressed: () => authBloc.add(
                    RegisterWithEmailPass(
                      email: emailController.text,
                      pass: passController.text,
                    ),
                  ),
                  child: const Text("Sign up"),
                ),

                /// Spacing
                172.verticalSpace,

                /// If have an account already, sign in
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
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
                                  const SigninScreen(),
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
                        "Sign in",
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
