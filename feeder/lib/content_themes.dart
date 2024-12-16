import 'package:flutter/material.dart';

class ContentColors extends ThemeExtension<ContentColors> {
  final Color noteBackground;
  final Color commentaryBackground;

  ContentColors({
    required this.noteBackground,
    required this.commentaryBackground,
  });

  @override
  ContentColors copyWith({
    Color? noteBackground,
    Color? commentaryBackground,
  }) {
    return ContentColors(
      noteBackground: noteBackground ?? this.noteBackground,
      commentaryBackground: commentaryBackground ?? this.commentaryBackground,
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
          noteBackground: Color(0xFFF0E6FF),
          commentaryBackground: Color(0xFFEBDAF4),
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
        ),
      ]);
}
