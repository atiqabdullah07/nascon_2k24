import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uni_links/uni_links.dart';

import 'constants.dart';

/* ----------------------------- Loading Indicator Helper -------------------------------- */
class LockableScaffold extends StatelessWidget {
  final Widget widget;
  final bool lock;
  final String? dialog;

  const LockableScaffold(
      {super.key, required this.widget, this.lock = false, this.dialog});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !lock, // if not locked, only then can be popped
      child: Stack(
        children: [
          /// user scaffold
          widget,

          /// ModalBarrier to overlay the whole scaffold
          if (lock) ...[
            ModalBarrier(
              color: Colors.black.withOpacity(0.5),
              dismissible: false,
            ),
            if (dialog == null)
              const Center(
                child: CircularProgressIndicator(
                  color: kColorPrimary,
                  backgroundColor: kColorSecondary,
                ),
              ),
            if (dialog != null)
              SimpleDialog(
                alignment: Alignment.center,
                contentPadding: EdgeInsets.all(164.h),
                children: [
                  /// loader
                  const Center(
                    child: CircularProgressIndicator(
                      color: kColorPrimary,
                      backgroundColor: kColorSecondary,
                    ),
                  ),

                  /// spacing
                  64.verticalSpace,

                  /// content
                  SizedBox(
                    width: 100.w,
                    child: Text(
                      dialog!,
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
          ]
        ],
      ),
    );
  }
}

/* ---------------------------- Media Query Shorthands ----------------------------- */
bool isOrientationLandscape(BuildContext context) =>
    MediaQuery.orientationOf(context) == Orientation.landscape;

/* ------------------------- Scaffold Messenger Shorthands -------------------------- */
ScaffoldMessengerState messenger(BuildContext context) =>
    ScaffoldMessenger.of(context);

void clearSnackBars(BuildContext context) =>
    messenger(context).clearSnackBars();

void showSnackBarText(BuildContext context, String message) =>
    messenger(context).showSnackBar(SnackBar(
      showCloseIcon: true,
      closeIconColor: kColorPrimary,
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
    ));

/* ---------------------------------- Navigator Shorthands ------------------------------------- */

NavigatorState navigator(BuildContext context) => Navigator.of(context);

void navigatorPopUntilFirst(BuildContext context) =>
    navigator(context).popUntil((route) => route.isFirst);

MaterialPageRoute pageRoute(Widget widget) =>
    MaterialPageRoute(builder: (_) => widget);

void materialPushReplacement(BuildContext context, Widget widget) =>
    navigator(context).pushReplacement(pageRoute(widget));

void materialPush(BuildContext context, Widget widget) =>
    navigator(context).push(pageRoute(widget));

PageRouteBuilder pagePushSlide(
        BuildContext context, Widget widget, AxisDirection direction) =>
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: direction == AxisDirection.left
                ? const Offset(1.0, 0.0)
                : const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );

/* ---------------------------------- Image Picker  ----------------------------------- */
ImagePicker _picker = ImagePicker();

Future<XFile?> get getImageFromGallery async =>
    await _picker.pickImage(source: ImageSource.gallery);

/* --------------------------------- Validators ------------------------------------ */

/// Validate email format
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Email is required.';

  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
    return "Please enter a valid email address";
  }

  return null;
}

/// validate password format
String? validatePassword(String? value) {
  if (value != null && value.isNotEmpty) return null;

  return "Password must not be empty.";
}

/* -------------------------- DeepLink Config (uni_links) --------------------------- */
Future<StreamSubscription<Uri?>> deeplinkUriHandler(
  void Function(Uri uri) stateHandler,
) async {
  final Uri? uri = await getInitialUri();
  if (uri != null) stateHandler(uri);

  /// subscribe to uri scheme
  return uriLinkStream.listen((uri) {
    if (uri != null) stateHandler(uri);
  });
}

/* ------------------------------- String Manipulation ------------------------------ */
String capitalizeFirst(String input) {
  final splitted = input.split('');
  final upperCasedFirst = splitted.removeAt(0).toUpperCase();
  return upperCasedFirst + splitted.join();
}

/// Application Dependent
/// returns date in format: [Posted `int` `unit` ago, dd-mm-yyyy]
String formatDateTime(DateTime dateTime) {
  final base = dateTime.toIso8601String();
  // date
  final date = base.split("T").first.split("-").reversed.join("-");
  // time difference
  final difference = DateTime.now().difference(dateTime);
  final seconds = difference.inSeconds;
  final mins = difference.inMinutes;
  final hrs = difference.inHours;
  final days = difference.inDays;
  // appropriate unit
  final appropriateUnit = seconds > 60
      ? mins > 60
          ? hrs > 24
              ? "days"
              : "hours"
          : "mins"
      : "seconds";
  // appropriate value
  int appropriateValue = -1;
  switch (appropriateUnit) {
    case "seconds":
      appropriateValue = seconds;
      break;
    case "mins":
      appropriateValue = mins;
      break;
    case "hours":
      appropriateValue = hrs;
      break;
    case "days":
      appropriateValue = days;
      break;
  }

  return "Posted $appropriateValue $appropriateUnit ago, $date";
}

/// Normalize time
String normalizeTime(DateTime dateTime) {
  /// format time
  final String base = dateTime.toIso8601String();
  final timeBase = base.split("T")[1];
  final timeWithoutMSeconds = timeBase.split(".")[0];
  final splittedMSecTime = timeWithoutMSeconds.split(":");
  splittedMSecTime.removeAt(2);

  /// Am / Pm
  final String timeUnit = int.parse(splittedMSecTime[0]) >= 12 ? "pm" : "am";

  final int normalizedTimeForUnit = int.parse(splittedMSecTime[0]) % 12;
  splittedMSecTime.removeAt(0);
  splittedMSecTime.insert(0, "$normalizedTimeForUnit");
  final time = splittedMSecTime.join(":");

  return "$time $timeUnit";
}

/// Format for reviews
String formatPostedTimeForReview(DateTime dateTime) {
  return formatDateTime(dateTime).replaceFirst("Posted ", "").split(",").first;
}
