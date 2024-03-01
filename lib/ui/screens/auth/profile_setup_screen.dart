import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/user/user_cubit.dart';
import '../../../core/constants.dart';
import '../../../core/utils.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  /// local State
  bool lock = false;
  XFile? pickedImage;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  /// Global State
  late final UserCubit userCubit;
  late final AuthBloc authBloc;
  late final User authUser;

  @override
  void initState() {
    userCubit = context.read<UserCubit>();
    authBloc = context.read<AuthBloc>();
    authUser = authBloc.state.credentials!.user!;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        switch (state.runtimeType) {
          case UserProcessing: // in case we are still processing
            setState(() => lock = true);
            break;
          case UserException: // in case of exceptions
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
          case UserCreated: // TODO progression
            setState(() => lock = false);
            navigator(context).popUntil((route) => route.isFirst);
            break;
          default:
            setState(() => lock = false);
            break;
        }
      },
      child: LockableScaffold(
        lock: lock,
        widget: Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              vertical: 0.1.sh,
              horizontal: isLandscape ? 0.2.sw : 0.09.sw,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ///
                /// Heading
                ///
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 72.h),
                  child: Text(
                    "Set up your\nProfile",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),

                ///
                /// Profile Picture
                ///
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: isLandscape ? 424.r : 196.r,
                      backgroundImage: pickedImage != null
                          ? Image.file(
                              File(pickedImage!.path),
                              fit: BoxFit.cover,
                            ).image
                          : null,
                      child: pickedImage != null
                          ? null
                          : SvgPicture.asset(
                              "assets/components/image_placeholder.svg",
                              fit: BoxFit.cover,
                            ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(100.r),
                      onTap: () => getImageFromGallery.then(
                        (value) => setState(() {
                          if (value != null) pickedImage = value;
                        }),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: CircleAvatar(
                          radius: isLandscape ? 96.r : 42.r,
                          child: SvgPicture.asset(
                            "assets/components/image_placeholder.svg",
                            height: isLandscape ? 24.w : 48.h,
                            width: isLandscape ? 24.w : 48.h,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                ///
                /// Text Fields
                ///
                Padding(
                  padding: EdgeInsets.only(
                    top: 164.h,
                    bottom: 96.h,
                  ),
                  child: Form(
                    child: Column(
                      children: [
                        /// Display Name Field
                        _buildProfileSetupTextField(
                          "Display Name",
                          nameController,
                          keyboardType: TextInputType.name,
                          isLandscape: isLandscape,
                        ),

                        /// spacing
                        SizedBox(height: 32.h),

                        /// Education Field
                        _buildProfileSetupTextField(
                          "Education",
                          educationController,
                          keyboardType: TextInputType.name,
                          isLandscape: isLandscape,
                        ),

                        /// spacing
                        SizedBox(height: 32.h),

                        /// Location Field
                        _buildProfileSetupTextField(
                          "Location",
                          locationController,
                          keyboardType: TextInputType.streetAddress,
                          isLandscape: isLandscape,
                          suffixIcon: const Icon(Icons.location_pin,
                              color: kColorBlack),
                        ),
                      ],
                    ),
                  ),
                ),

                /// SignUp Button
                ElevatedButton(
                  onPressed: () {
                    /// validation
                    if (nameController.text.isEmpty ||
                        educationController.text.isEmpty ||
                        locationController.text.isEmpty) {
                      messenger(context).clearSnackBars();
                      messenger(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please fill in all the fields and select a picture.",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                      return;
                    }

                    /// if valid, then create the user record in realtime database
                    userCubit.createUser(
                      uid: authUser.uid,
                      email: authUser.email!,
                      pfp: pickedImage!,
                      displayName: nameController.text,
                      education: educationController.text,
                      location: locationController.text,
                    );
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Another way to build this widget is following
  ///
  /// ```dart
  /// return TextField(
  ///   decoration: InputDecoration(
  ///     prefixIcon: FittedBox(
  ///       fit: BoxFit.scaleDown,
  ///       child: Padding(
  ///         padding: EdgeInsets.symmetric(horizontal: 40.w),
  ///         child: Text(
  ///           prefixText,
  ///           style: const TextStyle(color: Color(0xFFBDBDBD)),
  ///         ),
  ///       ),
  ///     ),
  ///     prefixStyle: const TextStyle(color: Color(0xFFBDBDBD)),
  ///     suffixIcon: suffixIcon,
  ///   ),
  /// );
  /// ```
  Widget _buildProfileSetupTextField(
    String prefixText,
    TextEditingController controller, {
    TextInputType? keyboardType,
    Widget? suffixIcon,
    bool isLandscape = false,
  }) {
    return Container(
      height: isLandscape ? 296.h : 148.h,
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      decoration: BoxDecoration(
        color: kColorSecondary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 0.25.sw,
            child: Text(
              prefixText,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: kColorGrey,
                fontSize: 10.spMax,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              style:
                  TextStyle(fontSize: 14.spMax, fontWeight: FontWeight.normal),
            ),
          ),
          if (suffixIcon != null) suffixIcon,
        ],
      ),
    );
  }
}
