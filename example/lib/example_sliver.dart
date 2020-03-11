import 'sample_data.dart';
import 'package:flutter/material.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';

class ExampleSliver extends StatefulWidget {
  @override
  _ExampleSliverState createState() => _ExampleSliverState();
}

class _ExampleSliverState extends State<ExampleSliver> {
  var sectionList = MockData.getExampleSections();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            floating: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: Text("Sliver Example"),
            ),
          ),
          SliverExpandableList(
            builder: SliverExpandableChildDelegate<String, Section>(
              sectionList: sectionList,
              headerBuilder: _buildHeader,
              itemBuilder: (context, section, item, index) => ListTile(
                leading: CircleAvatar(
                  child: Text("$index"),
                ),
                title: Text(item),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Section section, int index) {
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
}
