import 'package:flutter/material.dart';

class ExpandableTopSection extends StatelessWidget {
  final Widget topSection;
  final Widget bottomSection;
  final double maxRatio;
  final double minRatio;

  final bool startWithMax;

  const ExpandableTopSection({
    Key? key,
    required this.topSection,
    required this.bottomSection,
    required this.maxRatio,
    required this.minRatio,
    this.startWithMax = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FractionallySizedBox(
            alignment: Alignment.topCenter,
            heightFactor: maxRatio,
            child: topSection),
        FractionallySizedBox(
            alignment: Alignment.bottomCenter,
            heightFactor: .45,
            child: bottomSection)
      ],
    );
  }
}
