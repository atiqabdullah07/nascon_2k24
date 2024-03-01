import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants.dart';

class SetNewPassScreen extends StatefulWidget {
  final String? oobCode;

  const SetNewPassScreen({super.key, required this.oobCode});

  @override
  State<SetNewPassScreen> createState() => _SetNewPassScreenState();
}

class _SetNewPassScreenState extends State<SetNewPassScreen> {
  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    return Scaffold(
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
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      hintText: "Password",
                      suffixIcon: IconButton(
                        onPressed: () => {},
                        icon: const Icon(Icons.visibility_outlined),
                      ),
                    ),
                  ),

                  /// spacing
                  SizedBox(height: 46.h),

                  /// Password Field
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_reset_rounded),
                      hintText: "Confirm Password",
                      suffixIcon: IconButton(
                        onPressed: () => {},
                        icon: const Icon(Icons.visibility_outlined),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// SignUp Button
            ElevatedButton(
              onPressed: () => {},
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
    );
  }
}
