import 'dart:ui';

import 'package:google_fonts/google_fonts.dart';

/* ------------------------------------ Colors ------------------------------------- */
const kColorPrimary = Color(0xFF52B69A);
const kColorSecondary = Color(0xFFF3F3F5);
const kColorGrey = Color(0xFFBDBDBD);
const kColorSupportiveBlue = Color(0xFF0C0D34);
const kColorDarkGrey = Color(0xFF858699);
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
