import 'package:flutter/material.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';

import 'mock_data.dart';

class ExampleNestedScrollView extends StatefulWidget {
  @override
  _ExampleNestedScrollViewState createState() =>
      _ExampleNestedScrollViewState();
}

class _ExampleNestedScrollViewState extends State<ExampleNestedScrollView>
    with TickerProviderStateMixin {
  var sectionList = MockData.getExampleSections();
  late TabController tabController, subTabController;
  final GlobalKey<NestedScrollViewState> nestedScrollKey = GlobalKey();
  double _expandedHeight = 200;

  bool _isPinnedTitleShown = false;

  @override
  void initState() {
    super.initState();
    this.tabController = TabController(length: 2, vsync: this);
    this.subTabController = TabController(length: 2, vsync: this);
    var headerContentHeight = _expandedHeight - kToolbarHeight;
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      outerController.addListener(() {
        var pinned = outerController.offset >= headerContentHeight;
        if (_isPinnedTitleShown != pinned) {
          setState(() {
            _isPinnedTitleShown = pinned;
          });
        }
        // print("outerController position: $outerController $kToolbarHeight");
      });
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    subTabController.dispose();
    super.dispose();
  }

  ScrollController get outerController {
    return nestedScrollKey.currentState!.outerController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        key: nestedScrollKey,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.white,
              pinned: false,
              expandedHeight: _expandedHeight,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Appbar top area",
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ),
            // ),
          ];
        },
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Colors.white,
              pinned: true,
              elevation: 0,
              title: Text(
                _isPinnedTitleShown ? "PinnedTitle" : "",
                style: TextStyle(color: Colors.black),
              ),
              bottom: TabBar(
                labelColor: Colors.black,
                controller: this.tabController,
                tabs: <Widget>[
                  Tab(text: 'Home'),
                  Tab(text: 'Profile'),
                ],
              ),
            ),
            SliverPersistentHeader(
              // 可以吸顶的TabBar
              pinned: true,
              delegate: StickyTabBarDelegate(
                child: TabBar(
                  labelColor: Colors.black,
                  controller: this.subTabController,
                  tabs: <Widget>[
                    Tab(text: 'SubTab1'),
                    Tab(text: 'SubTab2'),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 300,
                child: TabBarView(
                  controller: this.subTabController,
                  children: <Widget>[
                    Center(child: Text('Content of SubTab1')),
                    Center(child: Text('Content of SubTab2')),
                  ],
                ),
              ),
            ),
            // SliverFillRemaining(
            //   // 剩余补充内容TabBarView
            //   child: TabBarView(
            //     controller: this.tabController,
            //     children: <Widget>[
            //       Center(child: Text('Content of Home')),
            //       Center(child: Text('Content of Profile')),
            //     ],
            //   ),
            // ),
            SliverExpandableList(
              builder: SliverExpandableChildDelegate<String, ExampleSection>(
                sectionList: sectionList,
                headerBuilder: _buildHeader,
                itemBuilder: (context, sectionIndex, itemIndex, index) {
                  String item = sectionList[sectionIndex].items[itemIndex];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text("$index"),
                    ),
                    title: Text(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int sectionIndex, int index) {
    ExampleSection section = sectionList[sectionIndex];
    return InkWell(
        child: Container(
            color: Colors.lightBlue,
            height: 48,
            padding: EdgeInsets.only(left: 20),
            alignment: Alignment.centerLeft,
            child: Text(
              "Header #$sectionIndex",
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

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;

  StickyTabBarDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // print("shrinkOffset:$shrinkOffset overlapsContent:$overlapsContent");
    return Container(color: Colors.yellow, child: this.child);
  }

  @override
  double get maxExtent => this.child.preferredSize.height;

  @override
  double get minExtent => this.child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
