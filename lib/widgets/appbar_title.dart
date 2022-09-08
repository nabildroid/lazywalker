import 'package:flutter/material.dart';

class AppbarTitle extends StatelessWidget {
  const AppbarTitle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context)
            .textTheme
            .headline6
            ?.copyWith(color: Colors.white),
        text: "Lazy ",
        children: [
          TextSpan(
            text: "W",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          TextSpan(text: "alker")
        ],
      ),
    );
  }
}
