import 'package:example/route_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:example/main.dart' as app;
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("example_listivew_test", () {
    testWidgets("sticky", (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey(RoutePath.listView)));

      await tester.pumpAndSettle();
      var listView = find.byType(ExpandableListView);
      var header0 = find.text("Header#0");
      var header1 = find.text("Header#1");
      var header2 = find.text("Header#2");

      //initial position.
      expect(header1, findsOneWidget);
      expect(header2, findsOneWidget);

      //Header#1 sticky
      await scrollTo(tester, listView, Offset(0, -200));
      expect(header1, findsOneWidget);
      expect(header2, findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 1));

      // //Header#2 sticky
      await scrollTo(tester, listView, Offset(0, -300));
      expect(header0, findsNothing);
      expect(header1, findsNothing);
      expect(header2, findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 30));
    });
  });
}

Future<void> scrollTo(WidgetTester tester, Finder finder, Offset offset) async {
  await tester.timedDrag(finder, offset, Duration(milliseconds: 300));
}

// Future<void> scrollTo(WidgetTester tester, Finder finder, String text,
//     {Type widgetType = CircleAvatar, Offset offset = Offset.zero}) async {
//   var widget = find.widgetWithText(widgetType, text);
//   var finderOffset = tester.getTopLeft(finder);
//   var itemOffset = tester.getTopLeft(widget);
//   var finalOffset = Offset(finderOffset.dx - itemOffset.dx + offset.dx,
//       finderOffset.dy - itemOffset.dy + offset.dy);
//   await tester.timedDrag(finder, finalOffset, Duration(milliseconds: 300));
// }
