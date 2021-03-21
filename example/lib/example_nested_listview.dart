import 'package:example/mock_data.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';
import 'package:example/example_custom_section.dart';

///if you want user ListView inside ExpandableListView, you have two options:
///
///Option 1:
///use shrinkWrap:true, like [ExampleCustomSection]
///
///Option 2:
///wrap ListView with SizeBox/Container, like [ExampleNestedListView], fixed length.
///
class ExampleNestedListView extends StatefulWidget {
  @override
  _ExampleNestedListViewState createState() => _ExampleNestedListViewState();
}

class _ExampleNestedListViewState extends State<ExampleNestedListView> {
  var sectionList = MockData.getExampleSections(10, 20);

  ScrollController _scrollListener;

  Drag drag;

  DragStartDetails dragStartDetails;

  @override
  void initState() {
    super.initState();
    _scrollListener = new ScrollController();
  }

  @override
  void dispose() {
    _scrollListener?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("NestedListView Example")),
        body: ExpandableListView(
          controller: _scrollListener,
          builder: SliverExpandableChildDelegate<String, ExampleSection>(
              sectionList: sectionList,
              sectionBuilder: _buildSection,
              itemBuilder: (context, sectionIndex, itemIndex, index) {
                String item = sectionList[sectionIndex].items[itemIndex];
                print("section:$sectionIndex itemIndex:$itemIndex");
                return Container(
                  color: Colors.orange,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text("$index"),
                    ),
                    title: Text(item),
                  ),
                );
              }),
        ));
  }

  Widget _buildSection(
      BuildContext context, ExpandableSectionContainerInfo containerInfo) {
    containerInfo
      ..header = _buildHeader(containerInfo)
      ..content = _buildContent(context, containerInfo);
    return ExpandableSectionContainer(
      info: containerInfo,
    );
  }

  Widget _buildHeader(ExpandableSectionContainerInfo containerInfo) {
    ExampleSection section = sectionList[containerInfo.sectionIndex];
    return InkWell(
        child: Container(
            color: Colors.lightBlue,
            height: 48,
            padding: EdgeInsets.only(left: 20),
            alignment: Alignment.centerLeft,
            child: Text(
              section.header,
              style: TextStyle(color: Colors.white),
            )),
        onTap: () {
          //toggle section expand state
          setState(() {
            section.setSectionExpanded(!section.isSectionExpanded());
          });
        });
  }

  Widget _buildContent(
      BuildContext context, ExpandableSectionContainerInfo containerInfo) {
    ExampleSection section = sectionList[containerInfo.sectionIndex];
    if (!section.isSectionExpanded()) {
      return Container();
    }
    return Container(
      height: 300,
      child: NotificationListener(
        onNotification: _onNotification,
        child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: containerInfo.childDelegate.builder,
          itemCount: containerInfo.childDelegate.childCount,
        ),
      ),
    );
  }

  bool _onNotification(ScrollNotification notification) {
    var metrics = notification.metrics;
    if (notification is ScrollEndNotification) {
      drag = null;
    }
    if (metrics.axis == Axis.horizontal || _scrollListener == null) {
      return true;
    }
    if (notification is ScrollStartNotification) {
      drag = null;
      dragStartDetails = notification.dragDetails;
    }
    if (notification is UserScrollNotification) {
      if (metrics.pixels <= metrics.minScrollExtent) {
        if (drag == null) {
          drag = _scrollListener.position.drag(dragStartDetails, () {
            drag = null;
          });
        }
      } else if (metrics.pixels >= metrics.maxScrollExtent) {
        if (drag == null) {
          drag = _scrollListener.position.drag(dragStartDetails, () {
            drag = null;
          });
        }
      }
    }
    return true;
  }
}
