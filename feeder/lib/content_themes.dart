import 'package:flutter/material.dart';

class ContentColors extends ThemeExtension<ContentColors> {
  final Color noteBackground;
  final Color commentaryBackground;
  final Color commentaryTextColor;
  final Color codeTextColor;
  final String meaningExpansionAsset;
  final String shlokaVisibleAsset;

  ContentColors({
    required this.noteBackground,
    required this.commentaryBackground,
    required this.commentaryTextColor,
    required this.codeTextColor,
    required this.meaningExpansionAsset,
    required this.shlokaVisibleAsset,
  });

  @override
  ContentColors copyWith({
    Color? noteBackground,
    Color? commentaryBackground,
    Color? commentaryTextColor,
    Color? codeTextColor,
    String? meaningExpansionAsset,
    String? shlokaVisibleAsset,
  }) {
    return ContentColors(
      noteBackground: noteBackground ?? this.noteBackground,
      commentaryBackground: commentaryBackground ?? this.commentaryBackground,
      commentaryTextColor: commentaryTextColor ?? this.commentaryTextColor,
      codeTextColor: codeTextColor ?? this.codeTextColor,
      meaningExpansionAsset: meaningExpansionAsset ?? this.meaningExpansionAsset,
      shlokaVisibleAsset: shlokaVisibleAsset ?? this.shlokaVisibleAsset,
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
      meaningExpansionAsset: other.meaningExpansionAsset,
      shlokaVisibleAsset: other.shlokaVisibleAsset,
    );
  }
}

ContentColors? contentColors(BuildContext context) {
  return Theme.of(context).extension<ContentColors>();
}

ThemeData lightTheme() {
  final defaultLightTheme = ThemeData.light();
  return defaultLightTheme.copyWith(
    scaffoldBackgroundColor: const Color(0xFFF5F5FA),
    cardColor: const Color(0xFFFCFCFF),
    extensions: <ThemeExtension<dynamic>>[
      ContentColors(
        noteBackground: Color(0xFFEDE7F6),
        commentaryBackground: Color(0xFFEDE7F6),
        commentaryTextColor: Color(0xFF4A4A6A),
        codeTextColor: Color(0xFF800000),
        meaningExpansionAsset: 'images/expand_meaning_light.png',
        shlokaVisibleAsset: 'images/shloka_visible_light.png',
      ),
    ],
  );
}

ThemeData darkTheme() {
  final defaultDarkTheme = ThemeData.dark();
  return defaultDarkTheme.copyWith(
    scaffoldBackgroundColor: const Color(0xFF1A1A2E),
    cardColor: const Color(0xFF252545),
    extensions: <ThemeExtension<dynamic>>[
      ContentColors(
        noteBackground: Color(0xFF322B3B),
        commentaryBackground: Color(0xFF28212D),
        commentaryTextColor: Color(0xFFF4F4F4),
        codeTextColor: Color.fromARGB(255, 236, 118, 82),
        meaningExpansionAsset: 'images/expand_meaning_dark.png',
        shlokaVisibleAsset: 'images/shloka_visible_dark.png',
      ),
    ],
  );
}
