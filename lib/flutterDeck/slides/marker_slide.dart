import 'package:flutter/widgets.dart';
import 'package:flutter_deck/flutter_deck.dart';

const _speakerNotes = '''
- If you want to highlight something, you can use the marker tool.
- The tool is available in the options menu in the deck controls.
- You can also update the marker color and stroke width in the global configuration.
''';

class MarkerSlide extends FlutterDeckSlideWidget {
  const MarkerSlide({
    required this.title,
    required this.content,
    required this.imagePath,
  }) : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/marker',
            speakerNotes: _speakerNotes,
            header: FlutterDeckHeaderConfiguration(
              title: 'Marker tool',
            ),
          ),
        );

  final String title;
  final String content;
  final String imagePath;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) => Center(
        child: Column(
          children: [
            Text(
              content,
              style: FlutterDeckTheme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Image.asset(imagePath),
            ),
          ],
        ),
      ),
    );
  }
}