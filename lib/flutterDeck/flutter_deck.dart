import 'package:chatbot/flutterdeck/slides/big_fact_slide.dart';
import 'package:chatbot/flutterdeck/slides/blank_slide.dart';
import 'package:chatbot/flutterdeck/slides/image_slide.dart';
import 'package:chatbot/flutterdeck/slides/layout_structure_slide.dart';
import 'package:chatbot/flutterdeck/slides/split_slide.dart';
import 'package:chatbot/flutterdeck/slides/title_slide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class FlutterDeckExample extends StatefulWidget {
  const FlutterDeckExample({super.key});

  @override
  _FlutterDeckExampleState createState() => _FlutterDeckExampleState();
}

class _FlutterDeckExampleState extends State<FlutterDeckExample> {
  static const String slideData = """
  SLIDE 1: TITLE SLIDE
  • Title: Metals and Non-Metals
  • Subject: Science
  • Grade: 10A
  • Teacher: [Your Name]

  SLIDE 2: LEARNING OBJECTIVES
  • Students will be able to define metals and non-metals.
  • Students will be able to identify the physical and chemical properties of metals and non-metals.
  • Students will be able to compare and contrast metals and non-metals.

  SLIDE 3: INTRODUCTION
  • Begin by reviewing the previous lesson on elements and compounds.
  • Ask students to recall the different types of elements.
  • Explain that today's lesson will focus on two specific types of elements: metals and non-metals.
  """;

  List<Map<String, String>> parseSlideData(String data) {
    final slides = <Map<String, String>>[];
    final slideBlocks = data.split('\n\n');

    for (final block in slideBlocks) {
      final lines = block.split('\n');
      if (lines.isEmpty) continue;

      final titleLine = lines.first;
      final contentLines = lines.skip(1).join('\n');

      slides.add({
        'title': titleLine.replaceFirst('SLIDE ', '').trim(),
        'content': contentLines.trim(),
      });
    }

    return slides;
  }

  @override
  Widget build(BuildContext context) {
    final slides = parseSlideData(slideData);
    final slideWidgets = slides.map((slideData) {
      final random = DateTime.now().millisecondsSinceEpoch % 6;

      switch (random) {
        case 0:
          return TitleSlide(
            route: '/de${slideData['title']?.substring(3).replaceAll(' ', '_') ?? ''}',
            title: slideData['title'] ?? '',
            subtitle: slideData['content'] ?? '',
          );
        case 1:
          return LayoutStructureSlide(
            route: '/de${slideData['title']?.substring(3).replaceAll(' ', '_') ?? ''}',
            headerText: slideData['title'] ?? '',
            contentText: slideData['content'] ?? '',
            footerText: 'Page',
          );
        case 2:
          return BlankSlide(
            route: '/de${slideData['title']?.substring(3).replaceAll(' ', '_') ?? ''}',
            title: slideData['title'] ?? '',
            content: slideData['content'] ?? '',
          );
        case 3:
          return SplitSlide(
            route: '/de${slideData['title']?.substring(3).replaceAll(' ', '_') ?? ''}',
            title: slideData['title'] ?? '',
            leftContent: slideData['content'] ?? '',
            rightContent: slideData['content'] ?? '',
          );
        case 4:
          return ImageSlide(
            route: '/de${slideData['title']?.substring(3).replaceAll(' ', '_') ?? ''}',
            title: slideData['title'] ?? '',
            imagePath: 'assets/flutter_logo.png',
          );
        default:
          return BigFactSlide(
            route: '/de${slideData['title']?.substring(3).replaceAll(' ', '_') ?? ''}',
            title: slideData['title'] ?? '',
            subtitle: slideData['content'] ?? '',
          );
      }
    }).toList();

    return FlutterDeckApp(
      slides: slideWidgets,
    );
  }
}
