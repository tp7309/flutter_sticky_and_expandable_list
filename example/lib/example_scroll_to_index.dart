import 'package:example/mock_data.dart';
import 'package:example/widgets.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';

class ExampleScrollToIndex extends StatefulWidget {
  @override
  _ExampleScrollToIndexState createState() => _ExampleScrollToIndexState();
}

class _ExampleScrollToIndexState extends State<ExampleScrollToIndex> {
  var sectionList = MockData.getExampleSections(10, 5);

  late AutoScrollController scrollController;
  int counter = 0;
  int maxCount = 10 * (5 + 1) - 1;

  @override
  void initState() {
    super.initState();
    scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
  }

  @override
  Widget build(BuildContext context) {
    //In this example, we create a custom model class(ExampleSection).
    //class ExampleSection implements ExpandableListSection<String> {}
    //so: SliverExpandableChildDelegate<String, ExampleSection>()
    return Scaffold(
      appBar: AppBar(title: TitleText("ListView Example")),
      body: ExpandableListView(
        controller: scrollController,
        builder: SliverExpandableChildDelegate<String, ExampleSection>(
            sectionList: sectionList,
            headerBuilder: _buildHeader,
            itemBuilder: (context, sectionIndex, itemIndex, index) {
              String item = sectionList[sectionIndex].items[itemIndex];
              return _wrapScrollTag(
                index: index,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text("$index"),
                  ),
                  title: Text(item),
                ),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scrollToIndex,
        tooltip: 'Increment',
        child: Text(counter.toString()),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int sectionIndex, int index) {
    ExampleSection section = sectionList[sectionIndex];
    return _wrapScrollTag(
      index: index,
      child: InkWell(
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
          }),
    );
  }

  Future _scrollToIndex() async {
    setState(() {
      counter++;
      if (counter >= maxCount) counter = 0;
    });

    await scrollController.scrollToIndex(counter,
        preferPosition: AutoScrollPosition.begin);
    scrollController.highlight(counter);
  }

  Widget _wrapScrollTag({required int index, required Widget child}) =>
      AutoScrollTag(
        key: ValueKey(index),
        controller: scrollController,
        index: index,
        child: child,
        highlightColor: Colors.black.withOpacity(0.1),
      );
}
