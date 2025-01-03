import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

const _speakerNotes = '''
- The blank slide template renders a header and a footer.
- The remaining space is free for your imagination.
''';

class BlankSlide extends FlutterDeckSlideWidget {
  final String title;
  final String content;
  final String route;

    BlankSlide({
    required this.title,
    required this.content,
    required this.route,
  }) : super(
          configuration: FlutterDeckSlideConfiguration(
            route: route,
            speakerNotes: _speakerNotes,
            header: FlutterDeckHeaderConfiguration(
              title: title,
            ),
          ),
        );

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) => Center(
        child: Text(
          content,
          style: FlutterDeckTheme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
