import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';

class MockData {
  static List<ExampleSection> getExampleSections(
      [sectionSize = 10, itemSize = 5]) {
    var sections = List<ExampleSection>();
    for (int i = 0; i < sectionSize; i++) {
      var section = ExampleSection()
        ..header = "Header #$i"
        ..items = List.generate(itemSize, (index) => "List tile #$index")
        ..expanded = true;
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
