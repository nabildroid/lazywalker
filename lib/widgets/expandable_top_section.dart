import 'package:flutter/material.dart';

class ExpandableTopSection extends StatefulWidget {
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
  State<ExpandableTopSection> createState() => _ExpandableTopSectionState();
}

class _ExpandableTopSectionState extends State<ExpandableTopSection> {
  double currentRatio = 0.0;

  @override
  void initState() {
    currentRatio = widget.startWithMax ? widget.maxRatio : widget.minRatio;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onVerticalDragUpdate: (details) => setState(() {
            currentRatio += details.delta.dy / context.size!.height;
            currentRatio = currentRatio.clamp(widget.minRatio, widget.maxRatio);
          }),
          onVerticalDragEnd: (details) => setState(() {
            if (currentRatio > (widget.maxRatio + widget.minRatio) / 2) {
              currentRatio = widget.maxRatio;
            } else {
              currentRatio = widget.minRatio;
            }
          }),
          child: AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticInOut,
            alignment: Alignment.topCenter,
            heightFactor: currentRatio,
            child: widget.topSection,
          ),
        ),
        Align(
          alignment: Alignment(0, -1 + currentRatio * 2 - .03),
          child: Container(
            height: 5,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
        FractionallySizedBox(
          alignment: Alignment.bottomCenter,
          heightFactor: 1 - currentRatio,
          child: widget.bottomSection,
        )
      ],
    );
  }
}
