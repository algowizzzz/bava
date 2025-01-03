import 'package:flutter/widgets.dart';
import 'package:flutter_deck/flutter_deck.dart';

const _speakerNotes = '''
- The image slide template renders an image with a small label.
- You can customize the label text style.
''';

class ImageSlide extends FlutterDeckSlideWidget {
   ImageSlide({
    required this.title,
    required this.imagePath,
    required this.route,
    this.label,
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
  final String imagePath;
  final String route;
  final String? label;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.image(
      imageBuilder: (context) => Image.asset(imagePath),
      label: label,
    );
  }
}