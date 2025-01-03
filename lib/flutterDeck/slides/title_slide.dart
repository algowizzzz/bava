import 'package:flutter/widgets.dart';
import 'package:flutter_deck/flutter_deck.dart';

const _speakerNotes = '''
- Welcome to flutter_deck example! 🚀
- Use slide deck controls to navigate.
''';

class TitleSlide extends FlutterDeckSlideWidget {
   TitleSlide({
    required this.title,
    required this.subtitle,
    required this.route,
  }) : super(
          configuration: FlutterDeckSlideConfiguration(
            route: route,
            title: 'Welcome to flutter_deck',
            speakerNotes: _speakerNotes,
            footer: FlutterDeckFooterConfiguration(showFooter: false),
          ),
        );

  final String title;
  final String subtitle;
  final String route;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.title(
      title: title,
      subtitle: subtitle,
    );
  }
}