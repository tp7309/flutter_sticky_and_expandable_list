import 'package:example/example_animable_header.dart';
import 'package:example/example_listview.dart';
import 'package:example/example_sliver.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter sticky and expandable list',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
//          textTheme: TextTheme(
//            title: TextStyle(color: Colors.white),
//            headline: TextStyle(color: Colors.white),
//            caption: TextStyle(color: Colors.white),
//          )
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
          _Item(
              "Amimable Header Example", (context) => ExampleAnimableHeader()),
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
