import 'package:example/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';

class ExampleAnimableHeader extends StatefulWidget {
  @override
  _ExampleAnimableHeaderState createState() => _ExampleAnimableHeaderState();
}

class _ExampleAnimableHeaderState extends State<ExampleAnimableHeader> {
  var sectionList = MockData.getExampleSections();
  var _controller = ExpandableListController();

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
              headerBuilder: (context, sectionIndex, index) {
                var section = sectionList[sectionIndex];
                return ExpandableAutoLayoutWidget(
                  trigger: ExpandableAutoLayoutTriggerDefault(_controller),
                  builder: (context) {
                    print("autoLayout");
                    double opacity =
                        _controller.stickySectionIndex == sectionIndex
                            ? (1 - _controller.percent)
                            : 1;
                    return _Header(section: section, opacity: opacity);
                  },
                );
              },
              controller: _controller,
              itemBuilder: (context, sectionIndex, itemIndex, index) {
                String item = sectionList[sectionIndex].items[itemIndex];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text("$index"),
                  ),
                  title: Text(item),
                );
              }),
        ));
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
