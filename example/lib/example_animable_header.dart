import 'package:example/sample_data.dart';
import 'package:flutter/material.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';

class ExampleAnimableHeader extends StatefulWidget {
  @override
  _ExampleAnimableHeaderState createState() => _ExampleAnimableHeaderState();
}

class _ExampleAnimableHeaderState extends State<ExampleAnimableHeader> {
  var sectionList = MockData.getExampleSections();

  double _headerOpacity = 1;
  int _hidingSectionIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Amimable Header Example")),
        body: ExpandableListView(
          //检查ListView需不需要停止监听Scrollable
          // RenderStickyHeaderLayoutBuilder get renderObject => super.renderObject;
          builder: SliverExpandableChildDelegate<String, Section>(
              sectionList: sectionList,
              headerBuilder: (context, section, index) {
                if (_hidingSectionIndex == sectionList.indexOf(section)) {
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
      _hidingSectionIndex = controller.switchingSectionIndex;
    });
    return controller;
  }
}

class _Header extends StatelessWidget {
  final Section section;
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
