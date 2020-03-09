import 'package:sticky_and_expandable_list/expandable_list.dart';

class MockData {
  static List<Section> getExampleSections() {
    var sections = List<Section>();
    for (int i = 0; i < 5; i++) {
      var section = Section()
        ..expanded = true
        ..header = "Header #$i"
        ..items = List.generate(6, (index) => "List tile #$index");
      sections.add(section);
    }
    return sections;
  }
}

class Section implements ExpandableListSection<String> {
  bool expanded;
  String header;
  List<String> items;

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
