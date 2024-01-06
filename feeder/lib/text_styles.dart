import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle? styleFor(BuildContext context, String tag, {String? elmclass}) {
  if (elmclass == 'language-shloka-sa') {
    return GoogleFonts.roboto(color: Theme.of(context).textTheme.labelMedium?.color, fontSize: 20);
  } else if (tag == 'code') {
    return GoogleFonts.roboto(color: Theme.of(context).textTheme.labelMedium?.color, fontSize: 18);
  } else if (tag == 'h1') {
    return Theme.of(context).textTheme.headlineMedium;
  } else if (tag == 'h2') {
    return Theme.of(context).textTheme.headlineSmall?.copyWith(height: 3);
  } else if (tag == 'em') {
    return GoogleFonts.caveat(height: 1.5, fontSize: 24);
  } else if (tag == 'note') {
    return const TextStyle(fontSize: 14);
  } else {
    return const TextStyle(height: 1.5, fontSize: 18);
  }
}
