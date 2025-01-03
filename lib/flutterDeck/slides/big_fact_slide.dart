import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

const _speakerNotes = '''
- The big fact slide is a template slide with a large title and a subtitle.
- You can customize the text styles and colors.
''';

class BigFactSlide extends FlutterDeckSlideWidget {
   BigFactSlide({
    required this.title,
    required this.subtitle,
    required this.route,
  }) 
  : super(
          configuration: FlutterDeckSlideConfiguration(
            route: route,
            speakerNotes: _speakerNotes,
            header: const FlutterDeckHeaderConfiguration(
              title: 'Big fact slide template',
            ),
          ),
        );

  final String title;
  final String subtitle;
  final String route;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.bigFact(
      title: title,
      subtitle: subtitle,
      theme: FlutterDeckTheme.of(context).copyWith(
        bigFactSlideTheme: const FlutterDeckBigFactSlideThemeData(
          titleTextStyle: TextStyle(color: Colors.amber),
        ),
      ),
    );
  }
}