import 'dart:io';

import 'package:example/example_custom_section_animation.dart';
import 'package:example/example_with_provider.dart';
import 'package:example/example_side_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'example_animatable_header.dart';
import 'example_custom_section.dart';
import 'example_listview.dart';
import 'example_sliver.dart';

void main() {
  runApp(MyApp());
  if (Platform.isAndroid) {
    //set statusBar color
    var overlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.blue);
    SystemChrome.setSystemUIOverlayStyle(overlayStyle);
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter sticky and expandable list',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _HomePage(),
    );
  }
}

class _HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter sticky and expandable list"),
      ),
      body: ListView(
        children: <Widget>[
          _Item("ListView Example", (context) => ExampleListView()),
          _Item("Sliver Example", (context) => ExampleSliver()),
          _Item("Animatable Header Example",
              (context) => ExampleAnimatableHeader()),
          _Item("CustomSection Example", (context) => ExampleCustomSection()),
          _Item("CustomSectionAnimation Example",
              (context) => ExampleCustomSectionAnimation()),
          _Item("Side Header Example", (context) => ExampleSideHeader()),
          _Item("With Provider Example", (context) => ExampleWithProvider()),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final WidgetBuilder builder;
  final String title;

  _Item(this.title, this.builder);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColor,
      child: FlatButton(
        onPressed: () =>
            Navigator.of(context).push(new MaterialPageRoute(builder: builder)),
        child: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
