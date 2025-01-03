import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

const _speakerNotes = '''
- The split slide template renders two columns, one on the left and one on right.
- You can change the split ratio based on your needs.
''';

class SplitSlide extends FlutterDeckSlideWidget {
   SplitSlide({
    required this.title,
    required this.leftContent,
    required this.rightContent,
    required String route,
  }) : super(
          configuration: FlutterDeckSlideConfiguration(
            route: route,
            speakerNotes: _speakerNotes,
            header: FlutterDeckHeaderConfiguration(
              title: title,
            ),
          ),
        );

  final String title;
  final String leftContent;
  final String rightContent;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.split(
      leftBuilder: (context) => Center(
        child: Text(
          leftContent,
          style: FlutterDeckTheme.of(context).textTheme.bodyMedium,
        ),
      ),
      rightBuilder: (context) => Center(
        child: Text(
          rightContent,
          style: FlutterDeckTheme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}