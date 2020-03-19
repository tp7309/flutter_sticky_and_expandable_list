import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../sticky_and_expandable_list.dart';

typedef ExpandableHeaderBuilder<S> = Widget Function(
    BuildContext context, S section, int index);
typedef ExpandableItemBuilder<T, S> = Widget Function(
    BuildContext context, S section, T item, int index);
typedef ExpandableSeparatorBuilder<T, S> = Widget Function(
    BuildContext context, bool isHeaderSeparator, int index);

/// A scrollable list of widgets arranged linearly, support expand/collapse item and
/// sticky header.
/// all build options are set in [SliverExpandableChildDelegate], this is to avoid
/// [SliverExpandableList] use generics.
class SliverExpandableList extends SliverList {
  final SliverExpandableChildDelegate builder;

  SliverExpandableList({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key, delegate: builder.delegate);
}

/// A delegate that supplies children for [SliverExpandableList] using
/// a builder callback.
class SliverExpandableChildDelegate<T, S extends ExpandableListSection<T>> {
  ///data source
  final List<S> sectionList;

  ///build section header
  final ExpandableHeaderBuilder<S> headerBuilder;

//  ///build animable header
//  final ExpandableAnimableHeader header;
  ///listen sticky header hide percent, [0.0-0.1].
  final ExpandableListHeaderController headerController;

  ///build section item
  final ExpandableItemBuilder<T, S> itemBuilder;

  ///build header and item separator
  final ExpandableSeparatorBuilder separatorBuilder;

  ///whether to sticky the header.
  final bool sticky;

  ///store section real index in SliverList, format: [sectionList index, SliverList index].
  final List<int> sectionRealIndexes;

  ///sliver list builder
  SliverChildBuilderDelegate delegate;

  SliverExpandableChildDelegate(
      {this.sectionList,
      this.headerBuilder,
      this.headerController,
      this.itemBuilder,
      this.separatorBuilder,
      this.sticky = true,
      bool addAutomaticKeepAlives = true,
      bool addRepaintBoundaries = true,
      bool addSemanticIndexes = true})
      : assert(sectionList != null),
        sectionRealIndexes = _buildSectionRealIndexes(sectionList) {
    if (separatorBuilder == null) {
      delegate = SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          S section = sectionList[index];
          List<T> items = section.getItems();
          int sectionIndex = sectionRealIndexes[index];
          int headerIndex = sectionIndex;
          return ExpandableListItemContainer(
            separated: false,
            listIndex: index,
            sectionRealIndexes: sectionRealIndexes,
            sticky: sticky,
            headerController: headerController,
            header: ExpandableAnimableHeader(
              builder: (context) =>
                  headerBuilder(context, section, headerIndex),
              controller: headerController,
            ),
            content: !section.isSectionExpanded() || items == null
                ? Container()
                : Column(
                    children: items
                        .map((T item) =>
                            itemBuilder(context, section, item, ++sectionIndex))
                        .toList(),
                  ),
          );
        },
        childCount: sectionList.length,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
      );
    } else {
      delegate = SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final int itemIndex = index ~/ 2;
          Widget itemView;
          int sectionIndex = sectionRealIndexes[itemIndex];
          S section = sectionList[itemIndex];
          List<T> items = section.getItems();
          if (index.isEven) {
            int sectionChildCount =
                _computeSemanticChildCount(items?.length ?? 0);
            //user list instead of list generator for compatible with Dart versions below 2.3.0.
            var semanticList = List.generate(sectionChildCount, (i) => i);
            int headerIndex = sectionIndex;
            itemView = ExpandableListItemContainer(
              separated: true,
              listIndex: index,
              sectionRealIndexes: sectionRealIndexes,
              sticky: sticky,
              headerController: headerController,
              header: ExpandableAnimableHeader(
                builder: (context) =>
                    headerBuilder(context, section, headerIndex),
                controller: headerController,
              ),
//              header: headerBuilder(context, section, sectionIndex++),
              content: !section.isSectionExpanded() || items == null
                  ? Container()
                  : Column(
                      children: semanticList
                          .map((i) => i.isEven
                              ? itemBuilder(context, section, items[i ~/ 2],
                                  ++sectionIndex)
                              : separatorBuilder(
                                  context, false, sectionIndex - 1))
                          .toList(),
                    ),
            );
          } else {
            itemView = separatorBuilder(
                context, true, sectionIndex + (items?.length ?? 0));
          }
          return itemView;
        },
        childCount: _computeSemanticChildCount(sectionList.length),
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        semanticIndexCallback: (Widget _, int index) {
          return index.isEven ? index ~/ 2 : null;
        },
      );
    }
  }

  static int _computeSemanticChildCount(int itemCount) {
    return math.max(0, itemCount * 2 - 1);
  }

  static List<int>
      _buildSectionRealIndexes<T, S extends ExpandableListSection<T>>(
          List<S> sectionList) {
    int calcLength = sectionList?.length ?? 0 - 1;
    List<int> sectionRealIndexes = List<int>();
    sectionRealIndexes.add(0);
    int realIndex = 0;
    for (int i = 0; i < calcLength; i++) {
      S section = sectionList[i];
      assert(section != null);
      realIndex += 1 + section.getItems()?.length ?? 0;
      sectionRealIndexes.add(realIndex);
    }
    return sectionRealIndexes;
  }
}

abstract class ExpandableListSection<T> {
  bool isSectionExpanded();

  void setSectionExpanded(bool expanded);

  List<T> getItems();
}

///controller for listen sticky header offset and current sticky header index.
class ExpandableListHeaderController extends ChangeNotifier {
  double _percent = 1.0;
  int _switchingSectionIndex = -1;
  int _stickySectionIndex = -1;

  ExpandableListHeaderController();

  double get percent => _percent;

  ///get floating header index
  int get switchingSectionIndex => _switchingSectionIndex;

  ///get pinned header index
  int get stickySectionIndex => _stickySectionIndex;

  updatePercent(int sectionIndex, double percent) {
    if (_percent == percent && _switchingSectionIndex == sectionIndex) {
      return;
    }
//    print(toString());
    _switchingSectionIndex = sectionIndex;
    _percent = percent;
    notifyListeners();
  }

  set stickySectionIndex(int value) {
    if (_stickySectionIndex == value) {
      return;
    }
    _stickySectionIndex = value;
//    notifyListeners();
  }

  @override
  String toString() {
    return 'ExpandableListHeaderController{_percent: $_percent, _switchingSectionIndex: $_switchingSectionIndex, _stickySectionIndex: $_stickySectionIndex}';
  }
}

///wrap header widget, when controller is set, the widget will rebuild
///when sticky header offset changed.ExpandableListHeaderController
class ExpandableAnimableHeader extends StatefulWidget {
  ///build section header
  final WidgetBuilder builder;

  ///listen sticky header hide percent, [0.0-0.1].
  final ExpandableListHeaderController controller;

  ExpandableAnimableHeader({this.builder, this.controller});

  @override
  _ExpandableAnimableHeaderState createState() =>
      _ExpandableAnimableHeaderState();
}

class _ExpandableAnimableHeaderState extends State<ExpandableAnimableHeader> {
  double _percent;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller.addListener(() {
        var newValue = widget.controller.percent;
        if (newValue != _percent) {
          _percent = newValue;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {});
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: widget.builder(context),
    );
  }
}
