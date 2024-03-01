import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';

/// This is the Screen that is first shown to the user once they open the
/// application.
///
/// Using this screen user can navigate to two possible flows:
/// * [SignupScreen]  - to create a new user account
/// * [SigninScreen]  - or sign in to an existing account
class SplashScreen extends StatelessWidget {
  static const routeName = "/splash";

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLandscape = isOrientationLandscape(context);

    return Scaffold(
      /// Scroll View to keep layout sane while in landscape
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: 0.14.sh,
          bottom: 0.08.sh,
          left: isLandscape ? 0.2.sw : 0.09.sw,
          right: isLandscape ? 0.2.sw : 0.09.sw,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Spacing
            SizedBox(height: 0.07.sh),

            /// Logo
            SizedBox(
              child: Image.asset(
                "assets/logos/logo_black.png",
                width: isLandscape ? 0.2.sw : 0.55.sw,
                fit: BoxFit.contain,
              ),
            ),

            /// Spacing
            SizedBox(height: isLandscape ? 0.1.sh : 0.22.sh),

            /// Actions
            SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    ),
                    child: const Text("Create Account"),
                  ),

                  /// Spacing
                  SizedBox(height: 36.h),

                  ///
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SigninScreen()),
                    ),
                    child: const Text("Sign in to your Account"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
