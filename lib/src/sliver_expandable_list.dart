import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../sticky_and_expandable_list.dart';

typedef ExpandableHeaderBuilder = Widget Function(
    BuildContext context, int sectionIndex, int index);
typedef ExpandableItemBuilder = Widget Function(
    BuildContext context, int sectionIndex, int itemIndex, int index);
typedef ExpandableSeparatorBuilder = Widget Function(
    BuildContext context, bool isSectionSeparator, int index);
typedef ExpandableSectionBuilder = Widget Function(
    BuildContext context, ExpandableSectionContainerInfo containerInfo);

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
  final List sectionList;

  ///build section header
  final ExpandableHeaderBuilder headerBuilder;

  ///build section item
  final ExpandableItemBuilder itemBuilder;

  ///build header and item separator, if pass null, SliverList has no separators.
  ///default null.
  final ExpandableSeparatorBuilder separatorBuilder;

  ///whether to sticky the header.
  final bool sticky;

  ///store section real index in SliverList, format: [sectionList index, SliverList index].
  final List<int> sectionRealIndexes;

  ///use this return a custom content widget, when use this builder, headerBuilder
  ///is invalid.
  ExpandableSectionBuilder sectionBuilder;

  ///expandable list controller, listen sticky header index scroll offset etc.
  ExpandableListController controller;

  ///sliver list builder
  SliverChildBuilderDelegate delegate;

  ///when section is collapsed, all child widget in content widget will be removed.
  bool removeItemsOnCollapsed = true;

  SliverExpandableChildDelegate(
      {@required this.sectionList,
      @required this.itemBuilder,
      this.controller,
      this.separatorBuilder,
      this.headerBuilder,
      this.sectionBuilder,
      this.sticky = true,
      this.removeItemsOnCollapsed = true,
      bool addAutomaticKeepAlives = true,
      bool addRepaintBoundaries = true,
      bool addSemanticIndexes = true})
      : assert(sectionList != null),
        //only use one builder
        assert(headerBuilder == null || sectionBuilder == null),
        sectionRealIndexes = _buildSectionRealIndexes(sectionList) {
    if (controller == null) {
      controller = ExpandableListController();
    }
    if (separatorBuilder == null) {
      delegate = SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          int sectionIndex = index;
          S section = sectionList[sectionIndex];
          int sectionRealIndex = sectionRealIndexes[sectionIndex];
          int itemRealIndex = sectionRealIndex;

          bool hasChildren =
              ((removeItemsOnCollapsed && !section.isSectionExpanded()) ||
                  section.getItems() == null);
          //user List.generate() instead of list generator for compatible with Dart versions below 2.3.0.
          var children = hasChildren
              ? <Widget>[]
              : List.generate(
                  section.getItems().length,
                  (i) =>
                      itemBuilder(context, sectionIndex, i, ++itemRealIndex));
          var containerInfo = ExpandableSectionContainerInfo(
            separated: false,
            listIndex: index,
            sectionIndex: sectionIndex,
            sectionRealIndexes: sectionRealIndexes,
            sticky: sticky,
            controller: controller,
            header: null,
            content: Column(
              children: children,
            ),
            children: children,
          );
          Widget container = sectionBuilder != null
              ? sectionBuilder(context, containerInfo)
              : null;
          if (container == null) {
            containerInfo
              ..header = headerBuilder(context, sectionIndex, sectionRealIndex);
            container = ExpandableSectionContainer(
              info: containerInfo,
            );
          }
          return container;
        },
        childCount: sectionList.length,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
      );
    } else {
      delegate = SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final int sectionIndex = index ~/ 2;
          Widget itemView;
          S section = sectionList[sectionIndex];
          int sectionRealIndex = sectionRealIndexes[sectionIndex];
          if (index.isEven) {
            int sectionChildCount =
                _computeSemanticChildCount(section.getItems()?.length ?? 0);
            int itemRealIndex = sectionRealIndex;

            bool hasChildren =
                ((removeItemsOnCollapsed && !section.isSectionExpanded()) ||
                    section.getItems() == null);
            //user List.generate() instead of list generator for compatible with Dart versions below 2.3.0.
            var children = hasChildren
                ? <Widget>[]
                : List.generate(
                    sectionChildCount,
                    (i) => i.isEven
                        ? itemBuilder(
                            context, sectionIndex, i ~/ 2, ++itemRealIndex)
                        : separatorBuilder(context, false, itemRealIndex - 1));

            var containerInfo = ExpandableSectionContainerInfo(
              separated: true,
              listIndex: index,
              sectionIndex: sectionIndex,
              sectionRealIndexes: sectionRealIndexes,
              sticky: sticky,
              controller: controller,
              header: null,
              children: children,
              content: Column(
                children: children,
              ),
            );
            Widget container = sectionBuilder != null
                ? sectionBuilder(context, containerInfo)
                : null;
            if (container == null) {
              containerInfo
                ..header =
                    headerBuilder(context, sectionIndex, sectionRealIndex);
              container = ExpandableSectionContainer(
                info: containerInfo,
              );
            }
            return container;
          } else {
            itemView = separatorBuilder(context, true,
                sectionIndex + (section.getItems()?.length ?? 0));
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
          List sectionList) {
    int calcLength = sectionList?.length ?? 0 - 1;
    List<int> sectionRealIndexes = List<int>();
    if (calcLength < 0) {
      return sectionRealIndexes;
    }
    sectionRealIndexes.add(0);
    int realIndex = 0;
    for (int i = 0; i < calcLength; i++) {
      S section = sectionList[i];
      //each section model should not null.
      assert(section != null);
      realIndex += 1 + (section.getItems()?.length ?? 0);
      sectionRealIndexes.add(realIndex);
    }
    return sectionRealIndexes;
  }
}

///Used to provide information for each section, each section model
///should implement [ExpandableListSection<Item Model>].
abstract class ExpandableListSection<T> {
  bool isSectionExpanded();

  void setSectionExpanded(bool expanded);

  List<T> getItems();
}

///Controller for listen sticky header offset and current sticky header index.
class ExpandableListController extends ChangeNotifier {
  ///switchingSection scroll percent, [0.1-1.0], 1.0 mean that the last sticky section
  ///is completely hidden.
  double _percent = 1.0;
  int _switchingSectionIndex = -1;
  int _stickySectionIndex = -1;

  ExpandableListController();

  ///store [ExpandableSectionContainer] information. [SliverList index, layoutOffset].
  ///don't modify it.
  List<double> containerOffsets = List<double>();

  double get percent => _percent;

  int get switchingSectionIndex => _switchingSectionIndex;

  ///get pinned header index
  int get stickySectionIndex => _stickySectionIndex;

  updatePercent(int sectionIndex, double percent) {
    if (_percent == percent && _switchingSectionIndex == sectionIndex) {
      return;
    }
    _switchingSectionIndex = sectionIndex;
    _percent = percent;
    notifyListeners();
  }

  set stickySectionIndex(int value) {
    if (_stickySectionIndex == value) {
      return;
    }
    _stickySectionIndex = value;
    notifyListeners();
  }

  void forceNotifyListeners() {
    notifyListeners();
  }

  @override
  String toString() {
    return 'ExpandableListController{_percent: $_percent, _switchingSectionIndex: $_switchingSectionIndex, _stickySectionIndex: $_stickySectionIndex}';
  }
}

///Check if need rebuild [ExpandableAutoLayoutWidget]
abstract class ExpandableAutoLayoutTrigger {
  ExpandableListController get controller;

  bool needBuild();
}

///Default [ExpandableAutoLayoutTrigger] implementation, auto build when
///switch sticky header index.
class ExpandableDefaultAutoLayoutTrigger
    implements ExpandableAutoLayoutTrigger {
  final ExpandableListController _controller;

  double _percent = 0;
  int _stickyIndex = 0;

  ExpandableDefaultAutoLayoutTrigger(this._controller) : super();

  @override
  bool needBuild() {
    if (_percent == _controller.percent &&
        _stickyIndex == _controller.stickySectionIndex) {
      return false;
    }
    _percent = _controller.percent;
    _stickyIndex = _controller.stickySectionIndex;
    return true;
  }

  @override
  ExpandableListController get controller => _controller;
}

///Wrap header widget, when controller is set, the widget will rebuild
///when [trigger] condition matched.
class ExpandableAutoLayoutWidget extends StatefulWidget {
  ///listen sticky header hide percent, [0.0-0.1].
  final ExpandableAutoLayoutTrigger trigger;

  ///build section header
  final WidgetBuilder builder;

  ExpandableAutoLayoutWidget({this.builder, this.trigger});

  @override
  _ExpandableAutoLayoutWidgetState createState() =>
      _ExpandableAutoLayoutWidgetState();
}

class _ExpandableAutoLayoutWidgetState
    extends State<ExpandableAutoLayoutWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.trigger != null && widget.trigger.controller != null) {
      widget.trigger.controller.addListener(_onChange);
    }
  }

  void _onChange() {
    if (widget.trigger.needBuild()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    if (widget.trigger != null && widget.trigger.controller != null) {
      widget.trigger.controller.removeListener(_onChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: widget.builder(context),
    );
  }
}
