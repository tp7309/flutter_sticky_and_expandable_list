import 'dart:io';

import 'package:example/example_custom_section_animation.dart';
import 'package:example/example_nested_scroll_view.dart';
import 'package:example/example_scroll_to_index.dart';
import 'package:example/example_side_header.dart';
import 'package:example/route_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'example_animatable_header.dart';
import 'example_custom_section.dart';
import 'example_listview.dart';
import 'example_sliver.dart';
import 'example_nested_listview.dart';

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
      routes: _buildRoutes(),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      RoutePath.home: (context) => _HomePage(),
      RoutePath.listView: (context) => ExampleListView(),
      RoutePath.sliver: (context) => ExampleSliver(),
      RoutePath.animatableHeader: (context) => ExampleAnimatableHeader(),
      RoutePath.customSection: (context) => ExampleCustomSection(),
      RoutePath.nestedListView: (context) => ExampleNestedListView(),
      RoutePath.customSectionAnimation: (context) =>
          ExampleCustomSectionAnimation(),
      RoutePath.nestedScrollView: (context) => ExampleNestedScrollView(),
      RoutePath.sideHeader: (context) => ExampleSideHeader(),
      RoutePath.scrollToIndex: (context) => ExampleScrollToIndex(),
    };
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
          _Item("ListView Example", RoutePath.listView),
          _Item("Sliver Example", RoutePath.sliver),
          _Item("Animatable Header Example", RoutePath.animatableHeader),
          _Item("CustomSection Example", RoutePath.customSection),
          _Item("NestedListView Example", RoutePath.nestedListView),
          _Item("CustomSectionAnimation Example",
              RoutePath.customSectionAnimation),
          _Item("NestedScrollView Example", RoutePath.nestedScrollView),
          _Item("Side Header Example", RoutePath.sideHeader),
          _Item("ScrollToIndex Example", RoutePath.scrollToIndex),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String jumpUrl;
  final String title;

  _Item(this.title, this.jumpUrl);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(jumpUrl),
      color: Theme.of(context).primaryColor,
      child: TextButton(
        onPressed: () => Navigator.of(context).pushNamed(jumpUrl),
        child: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
