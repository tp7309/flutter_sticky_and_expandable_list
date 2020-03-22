import 'package:flutter/material.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';

import 'mock_data.dart';

class ExampleCustomSectionAnimation extends StatefulWidget {
  @override
  _ExampleCustomSectionAnimationState createState() =>
      _ExampleCustomSectionAnimationState();
}

class _ExampleCustomSectionAnimationState
    extends State<ExampleCustomSectionAnimation> {
  var sectionList = MockData.getExampleSections(3, 3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("CustomSectionAnimation Example"),
        ),
        body: ExpandableListView(
          builder: SliverExpandableChildDelegate<String, ExampleSection>(
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
                sectionList[containerInfo.sectionIndex], containerInfo),
          ),
        ));
  }
}

class _SectionWidget extends StatefulWidget {
  final ExampleSection section;
  final ExpandableSectionContainerInfo containerInfo;

  _SectionWidget(this.section, this.containerInfo);

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
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
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

  void _onTap() {
    setState(() {
      widget.section.setSectionExpanded(!widget.section.isSectionExpanded());
      if (widget.section.isSectionExpanded()) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (mounted) {
            setState(() {
              // Rebuild without widget.children.
            });
          }
        });
      }
    });
  }

  Widget _buildContent() {
    final bool closed =
        !widget.section.isSectionExpanded() && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            heightFactor: _heightFactor.value,
            child: child,
          ),
        );
      },
      child: closed ? null : Column(children: widget.containerInfo.children),
    );
  }
}
