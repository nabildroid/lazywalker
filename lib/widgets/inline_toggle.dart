import 'package:flutter/material.dart';

class InlineToggle extends StatelessWidget {
  final bool isSelected;
  final Function select;
  final String label;

  const InlineToggle({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.select,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => select(),
      child: Row(children: [
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
          ),
        ),
        SizedBox(
          width: 16,
        ),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
              color: Colors.white70, borderRadius: BorderRadius.circular(4)),
          child: Center(
            child: Icon(
              isSelected
                  ? Icons.battery_6_bar_outlined
                  : Icons.battery_1_bar_outlined,
            ),
          ),
        ),
      ]),
    );
  }
}
