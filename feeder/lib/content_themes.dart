import 'package:flutter/material.dart';

class ContentColors extends ThemeExtension<ContentColors> {
  final Color noteBackground;
  final Color commentaryBackground;
  final Color commentaryTextColor;
  final Color codeTextColor;
  final String assetSuffix;

  ContentColors({
    required this.noteBackground,
    required this.commentaryBackground,
    required this.commentaryTextColor,
    required this.codeTextColor,
    required this.assetSuffix,
  });

  @override
  ContentColors copyWith({
    Color? noteBackground,
    Color? commentaryBackground,
    Color? commentaryTextColor,
    Color? codeTextColor,
    String? assetSuffix,
  }) {
    return ContentColors(
      noteBackground: noteBackground ?? this.noteBackground,
      commentaryBackground: commentaryBackground ?? this.commentaryBackground,
      commentaryTextColor: commentaryTextColor ?? this.commentaryTextColor,
      codeTextColor: codeTextColor ?? this.codeTextColor,
      assetSuffix: assetSuffix ?? this.assetSuffix,
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
      assetSuffix: other.assetSuffix,
    );
  }
}

ContentColors? contentColors(BuildContext context) {
  return Theme.of(context).extension<ContentColors>();
}

String contentAssetSuffix(BuildContext context) {
  return Theme.of(context).extension<ContentColors>()?.assetSuffix ?? '_light';
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
        assetSuffix: '_light',
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
        assetSuffix: '_dark',
      ),
    ],
  );
}
