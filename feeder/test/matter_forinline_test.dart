import 'package:flutter_test/flutter_test.dart';
import 'package:askys/matter_forinline.dart';

void main() {
  test('highlights english words in the content by splitting and marking', () {
    {
      final midlastEmpha = makeMatterForInlines('Zero one two three four', SectionType.commentary, 'anytag',
          showPatterns: ['two', 'four']);
      expect(midlastEmpha.length, equals(4));
      expect(midlastEmpha[0].text.trim(), equals('Zero one'));
      expect(midlastEmpha[0].presentation, equals(Presentation.normal));
      expect(midlastEmpha[1].text.trim(), equals('two'));
      expect(midlastEmpha[1].presentation, equals(Presentation.emphasis));
      expect(midlastEmpha[2].text.trim(), equals('three'));
      expect(midlastEmpha[2].presentation, equals(Presentation.normal));
      expect(midlastEmpha[3].text.trim(), equals('four'));
      expect(midlastEmpha[3].presentation, equals(Presentation.emphasis));
    }
    {
      final firstmidEmpha = makeMatterForInlines('Zero one two three four', SectionType.commentary, 'anytag',
          showPatterns: ['zero', 'two']);
      expect(firstmidEmpha.length, equals(4));
      expect(firstmidEmpha[0].text, equals('Zero'));
      expect(firstmidEmpha[0].presentation, equals(Presentation.emphasis));
      expect(firstmidEmpha[3].text, equals(' three four'));
      expect(firstmidEmpha[3].presentation, equals(Presentation.normal));
    }
    {
      final strAndSubstr =
          makeMatterForInlines('one done', SectionType.commentary, 'anytag', showPatterns: ['one']);
      expect(strAndSubstr.length, equals(2));
      expect(strAndSubstr[1].text.trim(), equals('done'));
    }
  });
  test('retains whitespace after splitting and marking', () {
    const originalText = 'eka dvi\ntrINi catvari';
    final splitMarked =
        makeMatterForInlines(originalText, SectionType.commentary, 'anytag', showPatterns: ['dvi', 'trINi']);
    String readBack = '';
    for (final phrase in splitMarked) {
      readBack += phrase.text;
    }
    expect(readBack, equals(originalText));
  });
  final showPatterns = ["\u0905\u0939\u092e\u0947\u0935", "[ahameva]", "Me", "inside"];
  test('highlights sanskrit words in the content', () {
    final sanskritInlines =
        makeMatterForInlines("अहमेव", SectionType.commentary, 'anytag', showPatterns: showPatterns);
    expect(sanskritInlines[0].text, equals('अहमेव'));
    expect(sanskritInlines[0].presentation, equals(Presentation.emphasis));
  });
  test('highlights transliterated words in the content', () {
    final translitInInlines =
        makeMatterForInlines('[ahameva]', SectionType.meaning, 'anytag', showPatterns: showPatterns);
    expect(translitInInlines[0].text, equals('[ahameva]'));
    expect(translitInInlines[0].presentation, equals(Presentation.emphasis));
  });
  test('does not match english inside transliterated words', () {
    final engInTranslitInlines =
        makeMatterForInlines('[me matam]', SectionType.meaning, 'anytag', showPatterns: ['me']);
    expect(engInTranslitInlines.length, equals(1));
    expect(engInTranslitInlines[0].text, equals('[me matam]'));
    expect(engInTranslitInlines[0].presentation, equals(Presentation.normal));
  });
  group('search relevance computer', () {
    bool searchRelevanceMarked(String text, String foundText) {
      return makeMatterForInlines(text, SectionType.commentary, 'atag', foundText: foundText)
          .first
          .isRelevantToSearch;
    }

    test('marks the text relevant when the content is same as the text found', () {
      expect(searchRelevanceMarked('The quick brown fox jumps', 'the quick brown fox jumps'), isTrue);
    });
    test('marks the text relevant when the content is a subset of the text found', () {
      expect(
          searchRelevanceMarked('quick fox over dog', 'The quick brown fox jumps over the lazy dog'), isTrue);
    });
    test('marks text with links as relevant', () {
      final foundText =
          "To get rid of ignorance, we must \n[surrender](7-19.md#Sharanagati)\n to that very Person who is the origin of everything - 'that very Person' is the Lord - He described Himself in [9-10](9-10.md): \u2018The material environment guides this world according to My will, I being the supreme controller\u2019, in [10-8](10-8.md): \u2018I am the origin of everything; Each and every entity gets stimulated with the initiative given by Me\u2019 and in [7-7](7-7.md): \u2018There is absolutely nothing else that is superior to Me\u2019.";
      expect(searchRelevanceMarked('To get rid of ignorance, we must ', foundText), isTrue);
      expect(searchRelevanceMarked('surrender', foundText), isTrue);
    });
    test('does not report relevance when less than half the words of the search phrase are found', () {
      expect(searchRelevanceMarked('The quick brown fox', 'slow'), isFalse);
      expect(searchRelevanceMarked('The quick brown fox', 'be quick not slow'), isFalse);
    });
  });
}
