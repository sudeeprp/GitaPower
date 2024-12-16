import 'package:flutter/material.dart';

class ContentColors extends ThemeExtension<ContentColors> {
  final Color noteBackground;
  final Color commentaryBackground;
  final Color commentaryTextColor;

  ContentColors({
    required this.noteBackground,
    required this.commentaryBackground,
    required this.commentaryTextColor,
  });

  @override
  ContentColors copyWith({
    Color? noteBackground,
    Color? commentaryBackground,
    Color? commentaryTextColor,
  }) {
    return ContentColors(
      noteBackground: noteBackground ?? this.noteBackground,
      commentaryBackground: commentaryBackground ?? this.commentaryBackground,
      commentaryTextColor: commentaryTextColor ?? this.commentaryTextColor,
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
    );
  }
}

ContentColors? contentColors(BuildContext context) {
  return Theme.of(context).extension<ContentColors>();
}

ThemeData lightTheme() {
  final defaultLightTheme = ThemeData.light();
  const codeTextLight = TextStyle(color: Color(0xFF800000), height: 1.5);
  return defaultLightTheme.copyWith(
      cardColor: const Color(0xFFFFFFFF),
      textTheme: defaultLightTheme.textTheme.copyWith(labelMedium: codeTextLight),
      extensions: <ThemeExtension<dynamic>>[
        ContentColors(
          noteBackground: Color(0xFFF7F204),
          commentaryBackground: Color(0xFFEDE7F6),
          commentaryTextColor: Color(0xFF4A4A6A),
        ),
      ]);
}

ThemeData darkTheme() {
  final defaultDarkTheme = ThemeData.dark();
  const codeTextDark = TextStyle(color: Color(0xFFFE7033), height: 1.5, fontWeight: FontWeight.w300);
  return defaultDarkTheme.copyWith(
      cardColor: const Color(0xFF000000),
      textTheme: defaultDarkTheme.textTheme.copyWith(labelMedium: codeTextDark),
      extensions: <ThemeExtension<dynamic>>[
        ContentColors(
          noteBackground: Color(0xFF322B3B),
          commentaryBackground: Color(0xFF28212D),
          commentaryTextColor: Color(0xFFF4F4F4),
        ),
      ]);
}
