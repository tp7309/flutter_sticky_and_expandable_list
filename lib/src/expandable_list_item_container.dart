import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';

///wrap expandable list section(header content).
class ExpandableListItemContainer extends MultiChildRenderObjectWidget {
  final Widget header;
  final Widget content;
  final int listIndex;
  final List<int> sectionRealIndexes;
  final bool separated;

  final ExpandableListHeaderController headerController;
  final bool sticky;

  ExpandableListItemContainer({
    @required this.header,
    @required this.content,
    @required this.listIndex,
    @required this.sectionRealIndexes,
    @required this.separated,
    this.sticky = true,
    this.headerController,
  }) : super(children: [content, header]);

  @override
  RenderExpandableListItemContainer createRenderObject(BuildContext context) {
    var renderSliver =
        context.findAncestorRenderObjectOfType<RenderSliverList>();
//    print("createRenderObject callback:$callback");
    return RenderExpandableListItemContainer(
      renderSliver: renderSliver,
      scrollable: Scrollable.of(context),
      headerController: this.headerController,
      sticky: this.sticky,
      listIndex: this.listIndex,
      sectionRealIndexes: this.sectionRealIndexes,
      separated: this.separated,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderExpandableListItemContainer renderObject) {
//    print("updateRenderObject callback:$callback");
    renderObject
      ..scrollable = Scrollable.of(context)
      ..headerController = this.headerController
      ..sticky = this.sticky
      ..listIndex = this.listIndex
      ..sectionRealIndexes = this.sectionRealIndexes
      ..separated = this.separated;
  }
}

///render [ExpandableListItemContainer]
class RenderExpandableListItemContainer extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  bool _sticky;
  ScrollableState _scrollable;
  ExpandableListHeaderController _headerController;
  RenderSliverList _renderSliver;
  int _listIndex;
  int _stickyIndex = -1;

  ///store [ExpandableListItemContainer] [SliverList index, layoutOffset].
  List<double> _containerOffsets = List<double>();

  ///[sectionIndex, section in SliverList index].
  List<int> _sectionRealIndexes;

  /// is SliverList has separator
  bool _separated;

  RenderExpandableListItemContainer({
    @required ScrollableState scrollable,
    ExpandableListHeaderController headerController,
    sticky = true,
    int listIndex = -1,
    List<int> sectionRealIndexes = const [],
    bool separated = false,
    RenderBox header,
    RenderBox content,
    RenderSliverList renderSliver,
  })  : _scrollable = scrollable,
        _headerController = headerController,
        _sticky = sticky,
        _listIndex = listIndex,
        _sectionRealIndexes = sectionRealIndexes,
        _separated = separated,
        _renderSliver = renderSliver {
    if (content != null) {
      add(content);
    }
    if (header != null) {
      add(header);
    }
  }

  get sectionRealIndexes => _sectionRealIndexes;

  set sectionRealIndexes(List<int> value) {
    if (_sectionRealIndexes == value) {
      return;
    }
    _sectionRealIndexes = value;
    markNeedsLayout();
  }

  get separated => _separated;

  set separated(bool value) {
    if (_separated == value) {
      return;
    }
    _separated = value;
    markNeedsLayout();
  }

  get scrollable => _scrollable;

  set scrollable(ScrollableState value) {
    assert(value != null);
    if (_scrollable == value) {
      return;
    }
    final ScrollableState oldValue = _scrollable;
    _scrollable = value;
    markNeedsLayout();
    if (attached) {
      oldValue.position?.removeListener(markNeedsLayout);
      if (_sticky) {
        _scrollable.position?.addListener(markNeedsLayout);
      }
    }
  }

  get headerController => _headerController;

  set headerController(ExpandableListHeaderController value) {
    if (_headerController == value) {
      return;
    }
    _headerController = value;
    markNeedsLayout();
  }

  get sticky => _sticky;

  set sticky(bool value) {
    if (_sticky == value) {
      return;
    }
    _sticky = value;
    markNeedsLayout();
    if (attached && !_sticky) {
      _scrollable.position?.removeListener(markNeedsLayout);
    }
  }

  get listIndex => _listIndex;

  set listIndex(int value) {
    if (_listIndex == value) {
      return;
    }
    _listIndex = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData)
      child.parentData = MultiChildLayoutParentData();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (sticky) {
      _scrollable.position?.addListener(markNeedsLayout);
    }
  }

  @override
  void detach() {
    _scrollable.position?.removeListener(markNeedsLayout);
    super.detach();
  }

  RenderBox get content => firstChild;

  RenderBox get header => lastChild;

  @override
  double computeMinIntrinsicWidth(double height) {
    return max(header.getMinIntrinsicWidth(height),
        content.getMinIntrinsicWidth(height));
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return max(header.getMaxIntrinsicWidth(height),
        content.getMaxIntrinsicWidth(height));
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return header.getMinIntrinsicHeight(width) +
        content.getMinIntrinsicHeight(width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return header.getMaxIntrinsicHeight(width) +
        content.getMaxIntrinsicHeight(width);
  }

  @override
  void performLayout() {
    assert(childCount == 2);

    //layout two child
    BoxConstraints exactlyConstraints = constraints.loosen();
    header.layout(exactlyConstraints, parentUsesSize: true);
    content.layout(exactlyConstraints, parentUsesSize: true);

    double width =
        max(constraints.minWidth, max(header.size.width, content.size.width));
    double height =
        max(constraints.minHeight, header.size.height + content.size.height);
    size = Size(width, height);
    assert(size.width == constraints.constrainWidth(width));
    assert(size.height == constraints.constrainHeight(height));

    //calc content offset
    positionChild(content, Offset(0, header.size.height));

    //update stickyIndex
    double sliverListOffset = _getSliverListVisibleScrollOffset();
    if (_containerOffsets.length <= _listIndex ||
        (_listIndex > 0 && _containerOffsets[_listIndex] <= 0)) {
      _refreshContainerLayoutOffsets();
    }
    double currContainerOffset = _listIndex < _containerOffsets.length
        ? _containerOffsets[_listIndex]
        : -1;
    bool containerPainted = (_listIndex == 0 && currContainerOffset == 0) ||
        currContainerOffset > 0;
    if (!containerPainted) {
      positionChild(header, Offset.zero);
      return;
    }
    double minScrollOffset = _listIndex >= _containerOffsets.length
        ? 0
        : _containerOffsets[_listIndex];
    double maxScrollOffset = minScrollOffset + size.height;
    if (sliverListOffset > minScrollOffset &&
        sliverListOffset <= maxScrollOffset) {
      if (_stickyIndex != _listIndex) {
        _stickyIndex = _listIndex;
        if (_headerController != null) {
          _headerController.stickySectionIndex = sectionIndex;
        }
      }
    } else {
      _stickyIndex = -1;
    }

    //calc header offset
    double currHeaderOffset = 0;
    double headerMaxOffset = content.size.height;
    if (_sticky && isStickyChild && sliverListOffset > minScrollOffset) {
      currHeaderOffset = sliverListOffset - minScrollOffset;
    }
//    print(
//        "index:$listIndex currHeaderOffset:${currHeaderOffset.toStringAsFixed(2)}" +
//            " sliverListOffset:${sliverListOffset.toStringAsFixed(2)}" +
//            " [$minScrollOffset,$maxScrollOffset] size:${content.size.height}");
    positionChild(header, Offset(0, min(currHeaderOffset, headerMaxOffset)));

    //callback header hide percent
    if (_headerController != null) {
      if (currHeaderOffset >= headerMaxOffset) {
        double switchingPercent = 0;
        if (currHeaderOffset > height) {
          //ensure callback 100% percent.
          switchingPercent = 1;
        } else {
          switchingPercent =
              (currHeaderOffset - headerMaxOffset) / header.size.height;
        }
        _headerController.updatePercent(sectionIndex, switchingPercent);
      } else if (sliverListOffset < minScrollOffset + content.size.height) {
        //ensure callback 0% percent.
        if (_headerController.stickySectionIndex == sectionIndex) {
          _headerController.updatePercent(sectionIndex, 0);
        }
      }
    }
  }

  bool get isStickyChild => _listIndex == _stickyIndex;

  int get sectionIndex => separated ? _listIndex ~/ 2 : _listIndex;

  double _getSliverListVisibleScrollOffset() {
    return _renderSliver.constraints.overlap +
        _renderSliver.constraints.scrollOffset;
  }

  void _refreshContainerLayoutOffsets() {
    _renderSliver.visitChildren((renderObject) {
      var containerParentData =
          renderObject.parentData as SliverMultiBoxAdaptorParentData;
//      print("visitChildren $containerParentData");

      while (_containerOffsets.length <= containerParentData.index) {
        _containerOffsets.add(0);
      }
      _containerOffsets[containerParentData.index] =
          containerParentData.layoutOffset;
    });
  }

  void positionChild(RenderBox child, Offset offset) {
    final MultiChildLayoutParentData childParentData = child.parentData;
    childParentData.offset = offset;
  }

  Offset childOffset(RenderBox child) {
    final MultiChildLayoutParentData childParentData = child.parentData;
    return childParentData.offset;
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
