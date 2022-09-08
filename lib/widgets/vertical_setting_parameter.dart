import 'dart:async';

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class VerticalSettingParamter extends StatefulWidget {
  final String label;
  final int value;
  final String sefix;
  final IconData icon;
  final Function(int v) onChange;
  final int min;
  final int max;
  final int step;

  const VerticalSettingParamter({
    Key? key,
    required this.label,
    required this.value,
    required this.sefix,
    required this.icon,
    required this.onChange,
    required this.min,
    required this.max,
    required this.step,
  }) : super(key: key);

  @override
  State<VerticalSettingParamter> createState() =>
      _VerticalSettingParamterState();
}

class _VerticalSettingParamterState extends State<VerticalSettingParamter> {
  late final ValueNotifier<int> valueNotifier;

  @override
  void initState() {
    valueNotifier = ValueNotifier(widget.value);

    valueNotifier.addListener(() {
      widget.onChange(valueNotifier.value);
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        InkWell(
          onTap: () {
            showDialog(
              builder: (context) => SimpleDialog(
                title: Text(widget.label),
                children: <Widget>[
                  ValueListenableBuilder(
                    builder: (context, value, _) {
                      return NumberPicker(
                        value: value as int,
                        minValue: widget.min,
                        maxValue: widget.max,
                        zeroPad: true,
                        step: widget.step,
                        haptics: true,
                        onChanged: (value) {
                          valueNotifier.value = value;
                        },
                      );
                    },
                    valueListenable: valueNotifier,
                  ),
                ],
              ),
              context: context,
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon),
              Text("${valueNotifier.value} ${widget.sefix}")
            ],
          ),
        )
      ],
    );
  }
}
