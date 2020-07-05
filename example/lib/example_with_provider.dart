import 'package:flutter/material.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';

import 'package:provider/provider.dart';

class ExampleWithProvider extends StatefulWidget {
  @override
  _ExampleWithProviderState createState() => _ExampleWithProviderState();
}

class _ExampleWithProviderState extends State<ExampleWithProvider> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SectionListModel(),
      child: TestScaffold(),
    );
  }
}

class TestScaffold extends StatefulWidget {
  @override
  _TestScaffoldState createState() => _TestScaffoldState();
}

class _TestScaffoldState extends State<TestScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("With Provider Example"),
          actions: <Widget>[
            FlatButton(
              child: Text("Section"),
              onPressed: () {
                Provider.of<SectionListModel>(context, listen: false)
                    .addSection(Section()
                      ..header = "NewHeader"
                      ..expanded = true);
              },
            ),
            FlatButton(
              child: Text("Item"),
              onPressed: () {
                Provider.of<SectionListModel>(context, listen: false)
                    .addItem("List Tile");
              },
            )
          ],
        ),
        body: _buildListView());
  }

  _buildListView() {
    print("buildListView");
    return Consumer<SectionListModel>(
      builder: (context, model, child) {
        print("enter builder");
        var sectionList = model.sectionList;
        return ExpandableListView(
          builder: SliverExpandableChildDelegate<String, Section>(
            sectionList: sectionList,
            itemBuilder: (context, sectionIndex, itemIndex, index) {
              String item = sectionList[sectionIndex].items[itemIndex];
              return ListTile(
                leading: CircleAvatar(
                  child: Text("$index"),
                ),
                title: Text(item),
              );
            },
            sectionBuilder: (context, containerInfo) => _SectionWidget(
              section: sectionList[containerInfo.sectionIndex],
              containerInfo: containerInfo,
              onStateChanged: () {
                // notify ExpandableListView that expand state has changed, calc new layout etc...
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {});
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }
}

class _SectionWidget extends StatefulWidget {
  final Section section;
  final ExpandableSectionContainerInfo containerInfo;
  final VoidCallback onStateChanged;

  _SectionWidget(
      {@required this.section,
      @required this.containerInfo,
      @required this.onStateChanged})
      : assert(onStateChanged != null);

  @override
  __SectionWidgetState createState() => __SectionWidgetState();
}

class __SectionWidgetState extends State<_SectionWidget>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);
  AnimationController _controller;

  Animation _iconTurns;

  Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _iconTurns =
        _controller.drive(_halfTween.chain(CurveTween(curve: Curves.easeIn)));
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeIn));

    if (widget.section.isSectionExpanded()) {
      _controller.value = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.containerInfo
      ..header = _buildHeader()
      ..content = _buildContent();
    return ExpandableSectionContainer(
      info: widget.containerInfo,
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.lightBlue,
      child: ListTile(
        title: Text(
          widget.section.header,
          style: TextStyle(color: Colors.white),
        ),
        trailing: RotationTransition(
          turns: _iconTurns,
          child: const Icon(
            Icons.expand_more,
            color: Colors.white70,
          ),
        ),
        onTap: _onTap,
      ),
    );
  }

  ///toggle expand state
  void _onTap() {
    widget.section.setSectionExpanded(!widget.section.isSectionExpanded());
    if (widget.section.isSectionExpanded()) {
      widget.onStateChanged();
      _controller.forward();
    } else {
      _controller.reverse().then<void>((_) {
        widget.onStateChanged();
      });
    }
  }

  Widget _buildContent() {
    return SizeTransition(
      sizeFactor: _heightFactor,
      child: widget.containerInfo.content,
    );
  }
}

class SectionListModel extends ChangeNotifier {
  List<Section> sectionList;

  SectionListModel() {
    sectionList = List<Section>();
    var section = Section()
      ..header = "Header"
      ..expanded = true;
    sectionList.add(section);
  }

  Future requestData() {
    sectionList = List<Section>()..add(Section()..header = "Header #0");
    return Future.value(sectionList);
  }

  void addSection(Section section) {
    sectionList.add(section);
    notifyListeners();
  }

  void addItem(String item) {
    var section = sectionList[sectionList.length - 1];
    if (section.items == null) {
      section.items = List();
    }
    section.items.add(item);
    notifyListeners();
  }
}

///Section model example
///
///Section model must implements ExpandableListSection<T>, each section has
///expand state, sublist. "T" is the model of each item in the sublist.
class Section implements ExpandableListSection<String> {
  //store expand state.
  bool expanded;

  //return item model list.
  List<String> items;

  //example header, optional
  String header;

  @override
  List<String> getItems() {
    return items;
  }

  @override
  bool isSectionExpanded() {
    return expanded;
  }

  @override
  void setSectionExpanded(bool expanded) {
    this.expanded = expanded;
  }
}
