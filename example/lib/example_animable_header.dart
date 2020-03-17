import 'package:example/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';

class ExampleAnimableHeader extends StatefulWidget {
  @override
  _ExampleAnimableHeaderState createState() => _ExampleAnimableHeaderState();
}

class _ExampleAnimableHeaderState extends State<ExampleAnimableHeader> {
  var sectionList = MockData.getExampleSections();

  double _headerOpacity = 1;
  int _swithingSectionIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Amimable Header Example")),
        body: ExpandableListView(
          builder: SliverExpandableChildDelegate<String, ExampleSection>(
              sectionList: sectionList,
              headerBuilder: (context, section, index) {
                if (_swithingSectionIndex == section.sectionIndex) {
                  return _Header(section: section, opacity: _headerOpacity);
                } else {
                  return _Header(section: section);
                }
              },
              headerController: _getHeaderController(),
              itemBuilder: (context, section, item, index) => ListTile(
                    leading: CircleAvatar(
                      child: Text("$index"),
                    ),
                    title: Text(item),
                  )),
        ));
  }

  _getHeaderController() {
    var controller = ExpandableListHeaderController();
    controller.addListener(() {
//      print(controller);
      _headerOpacity = 1 - controller.percent;
      _swithingSectionIndex = controller.switchingSectionIndex;
    });
    return controller;
  }
}

class _Header extends StatelessWidget {
  final ExampleSection section;
  final double opacity;

  _Header({this.section, this.opacity = 1.0});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.lightBlue.withOpacity(opacity),
        height: 48,
        padding: EdgeInsets.only(left: 20),
        alignment: Alignment.centerLeft,
        child: Text(
          section.header,
          style: TextStyle(color: Colors.white),
        ));
  }
}
