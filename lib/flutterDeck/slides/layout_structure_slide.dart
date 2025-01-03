import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

const _speakerNotes = '''
- The template slide template renders a header, a footer, and a content area.
''';

class LayoutStructureSlide extends FlutterDeckSlideWidget {
   LayoutStructureSlide({
    required this.headerText,
    required this.contentText,
    required this.footerText,
    required this.route,
  }) : super(
          configuration: FlutterDeckSlideConfiguration(
            route: route,
            speakerNotes: _speakerNotes,
            title: 'Layout structure',
          ),
        );

  final String headerText;
  final String contentText;
  final String footerText;
  final String route;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.template(
      backgroundBuilder: (context) => FlutterDeckBackground.solid(
        Theme.of(context).colorScheme.surface,
      ),
      contentBuilder: (context) => Center(
        child: Text(
          contentText,
          style: FlutterDeckTheme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
      footerBuilder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return ColoredBox(
          color: colorScheme.secondary,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                footerText,
                style: FlutterDeckTheme.of(context)
                    .textTheme
                    .bodyMedium
                    .copyWith(color: colorScheme.onSecondary),
              ),
            ),
          ),
        );
      },
      headerBuilder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return ColoredBox(
          color: colorScheme.primary,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                headerText,
                style: FlutterDeckTheme.of(context)
                    .textTheme
                    .bodyMedium
                    .copyWith(color: colorScheme.onPrimary),
              ),
            ),
          ),
        );
      },
    );
  }
}