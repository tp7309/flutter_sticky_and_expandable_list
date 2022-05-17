import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../sticky_and_expandable_list.dart';

/// A scrollable list of widgets arranged linearly, support expand/collapse item and
/// sticky header.
/// all build options are set in [SliverExpandableChildDelegate], this is to avoid
/// [SliverExpandableList] use generics.
class ExpandableListView extends BoxScrollView {
  ///same as ListView
  final SliverExpandableChildDelegate builder;

  ExpandableListView({
    Key? key,
    required this.builder,
    bool reverse = false,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    double? cacheExtent,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
  }) : super(
          key: key,
          scrollDirection: Axis.vertical,
          reverse: reverse,
          controller: controller,
          primary: primary,
          physics: physics,
          shrinkWrap: shrinkWrap,
          padding: padding,
          cacheExtent: cacheExtent,
          semanticChildCount: builder.sectionList.length,
          dragStartBehavior: dragStartBehavior,
        );

  @override
  Widget buildChildLayout(BuildContext context) {
    return SliverExpandableList(
      builder: builder,
    );
  }
}
