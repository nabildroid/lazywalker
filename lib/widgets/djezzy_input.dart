import 'package:flutter/material.dart';

class DjezzyInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const DjezzyInput({
    Key? key,
    required this.controller,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: label,
      ),
    );
  }
}
