import 'package:flutter/widgets.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';

class MockData {
  static List<ExampleSection> getExampleSections() {
    var sections = List<ExampleSection>();
    for (int i = 0; i < 10; i++) {
      var section = ExampleSection()
        ..header = "Header #$i"
        ..items = List.generate(6, (index) => "List tile #$index")
        ..expanded = true
        ..sectionIndex = i;
      sections.add(section);
    }
    return sections;
  }
}

class ExampleSection implements ExpandableListSection<String> {
  bool expanded;
  List<String> items;

  //optional
  String header;
  int sectionIndex;

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

class Section implements ExpandableListSection<Widget> {
  bool expanded;
  String header;
  List<Widget> items;

  @override
  List<Widget> getItems() {
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
