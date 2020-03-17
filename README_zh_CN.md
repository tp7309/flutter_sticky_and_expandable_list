# sticky_and_expandable_list

可拆叠列表的 Flutter 实现，支持固定组标题，可以与 Sliver 家族控件配合使用。

[![Pub](https://img.shields.io/pub/v/sticky_and_expandable_list.svg)](https://pub.dartlang.org/packages/sticky_and_expandable_list)

![Screenshot](https://raw.githubusercontent.com/tp7309/flutter_sticky_and_expandable_list/master/doc/images/sliverlist.gif)

## 特性

- 支持构建可切换拆叠/展开状态的 ListView，支持粘性头部。
- 可以与 Sliver 家族控件配合使用，用在如 CustomScrollView、NestedScrollView 中。
- 支持监听当前粘性头部的滚动偏移量，可获取当前粘性头部信息。

## 开始

在 Flutter 项目中的 `pubspec.yaml` 文件中添加如下依赖。

```yaml
dependencies:
  sticky_and_expandable_list: '^0.1.0'
```

## 使用示例

```dart
    //sectionList是ExpandableListView的数据源，需要使用者自己定义。
    //每个Section类实现ExpandableListSection接口即可。
    List<ExampleSection> sectionList = MockData.getExampleSections();
    return ExpandableListView(
      builder: SliverExpandableChildDelegate<String, ExampleSection>(
          sectionList: sectionList,
          headerBuilder: (context, section, index) => Text("Header #$index"),
          itemBuilder: (context, section, item, index) => ListTile(
                leading: CircleAvatar(
                  child: Text("$index"),
                ),
                title: Text(item),
              )),
    );
```

[详细示例](https://github.com/tp7309/flutter_sticky_and_expandable_list/tree/master/example)

## 常见问题

### 如何切换列表的展开/拆叠状态?

```dart
section.setSectionExpanded(true)
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
    var controller = ExpandableListHeaderController();
    controller.addListener(() {
      print("switchingSectionIndex:${controller.switchingSectionIndex}, stickySectionIndex:" +
          "${controller.stickySectionIndex},scrollPercent:${controller.percent}");
    });
    return controller;
  }
```
