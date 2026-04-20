import 'package:flutter/material.dart';

class HintDialog extends StatelessWidget {
  const HintDialog({super.key, required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Hint 💡'),
      content: Text(hint),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Try Again'),
        ),
      ],
    );
  }
}
