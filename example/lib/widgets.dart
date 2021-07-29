import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TitleText extends StatelessWidget {
  final String data;

  const TitleText(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: TextStyle(color: Colors.white),
    );
  }
}
