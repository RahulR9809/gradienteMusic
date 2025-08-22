import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';

class MyText extends StatelessWidget {
  final String text;
  final double? fontsize;
  final bool? multilanguage;
  final int? maxline;
  final FontStyle? fontstyle;
  final TextAlign? textalign;
  final FontWeight? fontwaight;
  final int? inter;
  final Color color;
  final TextOverflow? overflow;

  const MyText(
      {super.key,
      required this.color,
      this.inter,
      required this.text,
      this.fontsize,
      this.multilanguage,
      this.maxline,
      this.overflow,
      this.textalign,
      this.fontwaight,
      this.fontstyle});

  @override
  Widget build(BuildContext context) {
    return multilanguage == true
        ? LocaleText(
            text,
            textAlign: textalign,
            overflow: TextOverflow.ellipsis,
            maxLines: maxline,
            style: googleFontStyle(),
          )
        : Text(
            text,
            textAlign: textalign,
            overflow: TextOverflow.ellipsis,
            maxLines: maxline,
            style: googleFontStyle(),
          );
  }

  // FontFamily Type
  // Font = 1 => poppins
  // Font = 2 => Lobster
  // Font = 3 => Rubik
  // Font = (Any Other Number) => inter

  TextStyle googleFontStyle() {
    if (inter == 1) {
      return GoogleFonts.poppins(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    } else if (inter == 2) {
      return GoogleFonts.lobster(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    } else if (inter == 3) {
      return GoogleFonts.rubik(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    } else {
      return GoogleFonts.inter(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    }
  }
}
