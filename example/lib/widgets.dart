import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({
    Key? key,
    String title = "",
  }) : super(
          key: key,
          title: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        );
}
