import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nascon_app/blocs/auth/auth_bloc.dart';
import 'package:nascon_app/blocs/messages/messages_cubit.dart';
import 'package:nascon_app/blocs/user/user_cubit.dart';
import 'package:nascon_app/core/utils.dart';
import 'package:nascon_app/ui/screens/auth/splash_screen.dart';

import 'core/constants.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final isLandscape = isOrientationLandscape(context);

    return ScreenUtilInit(
      designSize: const Size(1080, 2340),
      ensureScreenSize: true,
      minTextAdapt: true,
      builder: (context, child) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc()),
          BlocProvider(create: (_) => UserCubit()),
          BlocProvider(create: (_) => MessagesCubit()),
        ],
        child: MaterialApp(
          title: 'Nascon 2k24',

          /// Theme Settings
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: kColorPrimary),

            ///
            /// TextField Theme
            ///
            inputDecorationTheme: InputDecorationTheme(
              prefixIconColor: kColorGrey,
              suffixIconColor: kColorGrey,
              hintStyle: TextStyle(
                color: kColorGrey,
                fontWeight: FontWeight.normal,
                fontSize: 12.spMax,
              ),
              filled: true,
              isDense: true,
              fillColor: kColorSecondary,
              border: const OutlineInputBorder(borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(vertical: 16.h),
            ),

            ///
            /// Text Theme
            ///
            textTheme: GoogleFonts.poppinsTextTheme(
              TextTheme(
                headlineLarge: poppinsBlacked.copyWith(
                  fontSize: 46.spMax,
                ),
                headlineMedium: poppinsBlacked.copyWith(
                  fontSize: 36.spMax,
                ),
                headlineSmall: poppinsBlacked.copyWith(
                  fontSize: 20.spMax,
                ),
                titleLarge: poppinsBlacked,
                titleMedium: poppinsNormal,
                titleSmall: poppinsGreyNormal.copyWith(
                  fontSize: 13.spMax,
                ),
              ),
            ),

            ///
            /// Text Button Theme Data
            ///
            textButtonTheme: const TextButtonThemeData(
              style: ButtonStyle(
                foregroundColor: MaterialStatePropertyAll(kColorBlack),
              ),
            ),

            ///
            /// Choice Chip theme
            ///
            chipTheme: ChipThemeData(
              showCheckmark: false,
              labelStyle: TextStyle(
                fontSize: 12.spMax,
                color: kColorBlack,
              ),
              padding:
                  EdgeInsets.symmetric(horizontal: isLandscape ? 24.w : 48.w),
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1),
                borderRadius: BorderRadius.circular(max(64.h, 64.w)),
              ),
            ),

            ///
            /// Elevated Button Theme Data
            ///
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                elevation: const MaterialStatePropertyAll(0),
                foregroundColor: const MaterialStatePropertyAll(kColorBlack),
                backgroundColor:
                    MaterialStateProperty.resolveWith<Color>((states) {
                  return states.contains(MaterialState.disabled)
                      ? kColorGrey
                      : kColorPrimary;
                }),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                minimumSize:
                    MaterialStatePropertyAll(Size.fromHeight(max(164.h, 64.w))),
                textStyle:
                    MaterialStatePropertyAll(TextStyle(fontSize: 16.spMax)),
              ),
            ),

            ///
            /// Bottom Navigation Bar
            ///
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              elevation: 0,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              backgroundColor: kColorPrimary,
              unselectedItemColor: kColorDarkGrey,
              selectedItemColor: kColorBlack,
            ),
          ),

          /// Entry Point
          initialRoute: SplashScreen.routeName,

          /// Route Table
          routes: {
            SplashScreen.routeName: (_) => const SplashScreen(),
          },
        ),
      ),
    );
  }
}
