# sticky_and_expandable_list

可拆叠列表的 Flutter 实现，支持粘性头部，可以与 Sliver 家族控件配合使用。

[![Pub](https://img.shields.io/pub/v/sticky_and_expandable_list.svg)](https://pub.dartlang.org/packages/sticky_and_expandable_list)

![Screenshot](https://raw.githubusercontent.com/tp7309/flutter_sticky_and_expandable_list/master/doc/images/sliverlist.gif)

## 特性

- 支持构建可切换拆叠/展开状态的 ListView，支持粘性头部。
- 可以与 Sliver 家族控件配合使用，用在如 CustomScrollView、NestedScrollView 中。
- 通过 controller 监听当前粘性头部的滚动偏移量，当前被固定 header 的索引和正在隐藏/显示的 header 的索引值。
- 整个列表是一个类似 ListView 的控件，Builder 方式创建分组项，所以支持大量数据显示，不会把所有分组全部创建出来。
- 可使用 sectionBuilder 进行更多 section 控件定制，如背景、自定义折叠/展开动画、不同 section 的布局方式定制等。
- 支持添加分隔线。

## 开始

在 Flutter 项目中的 `pubspec.yaml` 文件中添加如下依赖。

```yaml
dependencies:
  sticky_and_expandable_list: ^0.2.1
```

## 基础使用示例

```dart
    //sectionList是ExpandableListView的数据源，需要使用者自己定义。
    //每个Section类实现ExpandableListSection接口即可。
    List<ExampleSection> sectionList = MockData.getExampleSections();
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

[详细示例](https://github.com/tp7309/flutter_sticky_and_expandable_list/tree/master/example)

## 常见问题

### 如何切换列表的展开/拆叠状态?

```dart
setState(() {
  sectionList[i].setSectionExpanded(true);
});
```

[Example](https://github.com/tp7309/flutter_sticky_and_expandable_list/blob/master/example/lib/example_listview.dart)

### 如何监听当前粘性头部的滚动偏移量？如何得知哪个 Header 是粘性头部？

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

### 如何定制每一组数据的背景、阴影等信息?

使用[sectionBuilder](https://github.com/tp7309/flutter_sticky_and_expandable_list/blob/master/example/lib/example_custom_section_animation.dart)
返回自定义的 Widget.

### 自定义折叠动画

使用 Flutter 自带动画进行定制:
[Example](https://github.com/tp7309/flutter_sticky_and_expandable_list/blob/master/example/lib/example_custom_section_animation.dart)

## 更新日志

[CHANGELOG](https://github.com/tp7309/flutter_sticky_and_expandable_list/blob/master/CHANGELOG.md)
