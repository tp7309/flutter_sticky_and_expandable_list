# sticky_and_expandable_list
Flutter implementation of sticky headers and expandable list.Support use it in a CustomScrollView.

[![Pub](https://img.shields.io/pub/v/sticky_and_expandable_list.svg)](https://pub.dartlang.org/packages/sticky_and_expandable_list)
README i18n:[中文说明](https://github.com/tp7309/flutter_sticky_and_expandable_list/blob/master/README_zh_CN.md)

![Screenshot](https://raw.githubusercontent.com/tp7309/flutter_sticky_and_expandable_list/master/doc/images/sliverlist.gif)

## Features

- Build a grouped list, which support expand/collapse section and sticky header.
- Use it with CustomScrollView、SliverAppBar.
- Listen the scroll offset of current sticky header, current sticky header index and switching header index.
- Only use one list widget, so it supports large data and a normal memory usage.
- More section customization support, you can return a new section widget by sectionBuilder, to customize background，expand/collapse animation, section layout, and so on.
- Support add divider.
- Support overlap content.
- Support scroll to index like ListView, by [scroll-to-index](https://github.com/quire-io/scroll-to-index).
- Pull to refresh and load more, by [pull_to_refresh](https://github.com/peng8350/flutter_pulltorefresh).

## Getting Started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  sticky_and_expandable_list: ^1.1.2
```

## Basic Usage
`sectionList` is a custom data source for `ExpandableListView`.
We should create a model list to store the information of each section, the model must implement `ExpandableListSection`.
```dart
    //In this example, we create a custom model class(ExampleSection).
    //class ExampleSection implements ExpandableListSection<String> {}
    //so: SliverExpandableChildDelegate<String, ExampleSection>()
    List<ExampleSection> sectionList = List<ExampleSection>();
    return ExpandableListView(
      builder: SliverExpandableChildDelegate<String, ExampleSection>(
          sectionList: sectionList,
          headerBuilder: (context, sectionIndex, index) =>
              Text("Header #$sectionIndex"),
          itemBuilder: (context, sectionIndex, itemIndex, index) {
            String item = sectionList[sectionIndex].items[itemIndex];
            return ListTile(
              leading: CircleAvatar(
                child: Text("$index"),
              ),
              title: Text(item),
            );
          }),
    );
```

[Detail Examples](https://github.com/tp7309/flutter_sticky_and_expandable_list/tree/master/example/lib)

If you want to use it with sliver widget, use **SliverExpandableList** instead of ExpandableListView.

## FAQ

### How to expand/collapse item?

```dart
setState(() {
  sectionList[i].setSectionExpanded(true);
});
```

[Example](https://github.com/tp7309/flutter_sticky_and_expandable_list/blob/master/example/lib/example_listview.dart)

### How to listen current sticky header or the sticky header scroll offset?

```dart
  @override
  Widget build(BuildContext context) {
    ExpandableListView(
      builder: SliverExpandableChildDelegate<String, ExampleSection>(
        headerController: _getHeaderController(),
      ),
    )
  }

  _getHeaderController() {
    var controller = ExpandableListController();
    controller.addListener(() {
      print("switchingSectionIndex:${controller.switchingSectionIndex}, stickySectionIndex:" +
          "${controller.stickySectionIndex},scrollPercent:${controller.percent}");
    });
    return controller;
  }
```

### How to set background for each section?

Use [sectionBuilder](https://github.com/tp7309/flutter_sticky_and_expandable_list/blob/master/example/lib/example_custom_section_animation.dart)

### Customize expand/collapse animation support?

[Example](https://github.com/tp7309/flutter_sticky_and_expandable_list/blob/master/example/lib/example_custom_section_animation.dart)

## Change Log

[CHANGELOG](https://github.com/tp7309/flutter_sticky_and_expandable_list/blob/master/CHANGELOG.md)

## Donate

Buy a cup of coffee for me (Scan by wechat)：

![qrcode](https://user-images.githubusercontent.com/5046191/118354036-b075ca80-b59b-11eb-862e-ffd1b8e1659f.png)


