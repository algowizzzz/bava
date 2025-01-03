import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

const _speakerNotes = '''
- You can use a custom footer widget in your slides.
- This example showcases a custom footer with an icon and text.
''';

class FooterSlide extends FlutterDeckSlideWidget {
   FooterSlide({
    required this.title,
    required this.content,
  }) : super(
          configuration: FlutterDeckSlideConfiguration(
            footer: const FlutterDeckFooterConfiguration(
              showSlideNumbers: true,
              showSocialHandle: true,
              widget: _CustomFooter(),
            ),
            route: '/footer-slide',
            speakerNotes: _speakerNotes,
            header: FlutterDeckHeaderConfiguration(
              title: title,
            ),
          ),
        );

  final String title;
  final String content;

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

class _CustomFooter extends StatelessWidget {
  const _CustomFooter();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.home),
        SizedBox(width: 8),
        Text('This is a custom footer with icon and text'),
      ],
    );
  }
}