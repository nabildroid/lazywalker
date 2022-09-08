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
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          width: 8,
        ),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(4)),
          child: Center(
            child: Icon(Icons.currency_exchange_rounded),
          ),
        ),
      ]),
    );
  }
}
