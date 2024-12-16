import 'package:flutter/material.dart';

class ContentColors extends ThemeExtension<ContentColors> {
  final Color noteBackground;
  final Color commentaryBackground;
  final Color commentaryTextColor;
  final Color codeTextColor;

  ContentColors({
    required this.noteBackground,
    required this.commentaryBackground,
    required this.commentaryTextColor,
    required this.codeTextColor,
  });

  @override
  ContentColors copyWith({
    Color? noteBackground,
    Color? commentaryBackground,
    Color? commentaryTextColor,
    Color? codeTextColor,
  }) {
    return ContentColors(
      noteBackground: noteBackground ?? this.noteBackground,
      commentaryBackground: commentaryBackground ?? this.commentaryBackground,
      commentaryTextColor: commentaryTextColor ?? this.commentaryTextColor,
      codeTextColor: codeTextColor ?? this.codeTextColor,
    );
  }

  @override
  ContentColors lerp(ThemeExtension<ContentColors>? other, double t) {
    // for animation
    if (other is! ContentColors) {
      return this;
    }
    return ContentColors(
      noteBackground: Color.lerp(noteBackground, other.noteBackground, t)!,
      commentaryBackground: Color.lerp(commentaryBackground, other.commentaryBackground, t)!,
      commentaryTextColor: Color.lerp(commentaryTextColor, other.commentaryTextColor, t)!,
      codeTextColor: Color.lerp(codeTextColor, other.codeTextColor, t)!,
    );
  }
}

ContentColors? contentColors(BuildContext context) {
  return Theme.of(context).extension<ContentColors>();
}

ThemeData lightTheme() {
  final defaultLightTheme = ThemeData.light();
  return defaultLightTheme.copyWith(cardColor: const Color(0xFFFFFFFF), extensions: <ThemeExtension<dynamic>>[
    ContentColors(
      noteBackground: Color(0xFFEDE7F6),
      commentaryBackground: Color(0xFFEDE7F6),
      commentaryTextColor: Color(0xFF4A4A6A),
      codeTextColor: Color(0xFF800000),
    ),
  ]);
}

ThemeData darkTheme() {
  final defaultDarkTheme = ThemeData.dark();
  return defaultDarkTheme.copyWith(cardColor: const Color(0xFF000000), extensions: <ThemeExtension<dynamic>>[
    ContentColors(
      noteBackground: Color(0xFF322B3B),
      commentaryBackground: Color(0xFF28212D),
      commentaryTextColor: Color(0xFFF4F4F4),
      codeTextColor: Color(0xFFFE7033),
    ),
  ]);
}
