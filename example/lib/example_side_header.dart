import 'package:example/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';

class ExampleSideHeader extends StatefulWidget {
  @override
  _ExampleSideHeaderState createState() => _ExampleSideHeaderState();
}

class _ExampleSideHeaderState extends State<ExampleSideHeader> {
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
        appBar: AppBar(title: Text("Side Header Example")),
        body: ExpandableListView(
          builder: SliverExpandableChildDelegate<String, ExampleSection>(
              overlapsContent: true,
              controller: _controller,
              sectionList: sectionList,
              headerBuilder: _buildHeader,
              itemBuilder: (context, sectionIndex, itemIndex, index) {
                String item = sectionList[sectionIndex].items[itemIndex];
                return Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Container(
                    color: Colors.black26,
                    child: ListTile(
                      title: Text(
                        item,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, isSectionSeparator, index) {
                return isSectionSeparator
                    ? SizedBox(
                        height: 15,
                      )
                    : Container();
              }),
        ));
  }

  Widget _buildHeader(BuildContext context, int sectionIndex, int index) {
    return ExpandableAutoLayoutWidget(
        trigger: ExpandableDefaultAutoLayoutTrigger(_controller),
        builder: (context) {
          double opacity = _controller.switchingSectionIndex == sectionIndex
              ? (1 - _controller.percent)
              : 1;
          return Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: CircleAvatar(
                backgroundColor: Colors.lightBlue.withOpacity(opacity),
                child: Text(
                  "$sectionIndex",
                  style: TextStyle(color: Colors.white),
                ),
              ));
        });
  }
}
