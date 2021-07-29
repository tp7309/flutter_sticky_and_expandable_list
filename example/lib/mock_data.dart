import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';

///
/// create some example data.
///
class MockData {
  ///return a example list, by default, we have 4 sections,
  ///each section has 5 items.
  static List<ExampleSection> getExampleSections(
      [int sectionSize = 10, int itemSize = 5]) {
    var sections = List<ExampleSection>.empty(growable: true);
    for (int i = 0; i < sectionSize; i++) {
      var section = ExampleSection()
        ..header = "Header#$i"
        ..items = List.generate(itemSize, (index) => "ListTile #$index")
        ..expanded = true;
      sections.add(section);
    }
    return sections;
  }
}

///Section model example
///
///Section model must implements ExpandableListSection<T>, each section has
///expand state, sublist. "T" is the model of each item in the sublist.
class ExampleSection implements ExpandableListSection<String> {
  //store expand state.
  late bool expanded;

  //return item model list.
  late List<String> items;

  //example header, optional
  late String header;

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
