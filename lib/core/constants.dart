import 'dart:ui';

import 'package:google_fonts/google_fonts.dart';

/* ------------------------------------ Colors ------------------------------------- */
const kColorPrimary = Color(0xFFFEF10C);
const kColorSecondary = Color(0xFFF5F5F5);
const kColorGrey = Color(0xFFBDBDBD);
const kColorDarkGrey = Color(0x30030303);
const kColorWhite = Color(0xFFF5F5F5);
const kColorBlack = Color(0xFF030303);

/* ------------------------------------ Fonts ------------------------------------- */
final poppinsBlacked = GoogleFonts.poppins(
  fontWeight: FontWeight.w600,
  color: kColorBlack,
);

final poppinsNormal = poppinsBlacked.copyWith(
  fontWeight: FontWeight.w300,
);

final poppinsGreyNormal = GoogleFonts.poppins(
  color: kColorGrey,
);
