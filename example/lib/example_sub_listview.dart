import 'package:example/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';

class ExampleSubListView extends StatefulWidget {
  @override
  _ExampleSubListViewState createState() => _ExampleSubListViewState();
}

class _ExampleSubListViewState extends State<ExampleSubListView> {
  var sectionList = MockData.getExampleSections(10, 20);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("CustomSection Example")),
        body: ExpandableListView(
          builder: SliverExpandableChildDelegate<String, ExampleSection>(
              sectionList: sectionList,
              sectionBuilder: _buildSection,
              itemBuilder: (context, sectionIndex, itemIndex, index) {
                String item = sectionList[sectionIndex].items[itemIndex];
                print("section:$sectionIndex itemIndex:$itemIndex");
                return Container(
                  color: Colors.orange,
                  height: 300,
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
      height: 1000,
      child: ListView.builder(
        itemBuilder: containerInfo.childDelegate.builder,
        itemCount: containerInfo.childDelegate.childCount,
      ),
    );
  }
}
