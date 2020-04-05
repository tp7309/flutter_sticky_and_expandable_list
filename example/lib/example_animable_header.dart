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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Amimable Header Example")),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
              child: Container(
            height: 100,
            width: 100,
            color: Colors.black,
            alignment: Alignment.center,
            child: Text(
              "Sliver",
              style: TextStyle(color: Colors.white),
            ),
          )),
          SliverExpandableList(
            builder: SliverExpandableChildDelegate<String, ExampleSection>(
                sectionList: sectionList,
                headerBuilder: _buildHeader,
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
          )
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int sectionIndex, int index) {
    var section = sectionList[sectionIndex];
    return ExpandableAutoLayoutWidget(
      trigger: ExpandableDefaultAutoLayoutTrigger(_controller),
      builder: (context) {
        double opacity = _controller.switchingSectionIndex == sectionIndex
            ? (1 - _controller.percent)
            : 1;
        String headerText = section.header;
        if (_controller.switchingSectionIndex == sectionIndex) {
          headerText += " Switching";
        } else if (_controller.stickySectionIndex == sectionIndex) {
          headerText += " Pinned";
        }
        return Container(
            color: Colors.lightBlue.withOpacity(opacity),
            height: 48,
            padding: EdgeInsets.only(left: 20),
            alignment: Alignment.centerLeft,
            child: Text(
              headerText,
              style: TextStyle(color: Colors.white),
            ));
      },
    );
  }
}
