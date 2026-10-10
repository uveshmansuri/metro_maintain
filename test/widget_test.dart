import 'package:flutter_test/flutter_test.dart';
import 'package:metro_maintain/main.dart';
import 'package:metro_maintain/services/metro_database.dart';

void main() {
  testWidgets('MetroFix full workflow test', (WidgetTester tester) async {
    MetroDatabase.instance.resetDemoData();

    await tester.pumpWidget(const MetroFixApp());
    await tester.pumpAndSettle();

    // Verify Screen 1 (Passenger Scan) branding and demo buttons
    expect(find.text('METROFIX'), findsOneWidget);
    expect(find.text('🚪 Gate A-102'), findsOneWidget);
    expect(find.text('🛗 Lift L-05'), findsOneWidget);
    expect(find.text('⚡ Escalator E-12'), findsOneWidget);

    // Tap on Lift L-05 to enter Screen 2 (Report Problem)
    await tester.tap(find.text('🛗 Lift L-05'));
    await tester.pumpAndSettle();

    expect(find.text('Report Problem'), findsOneWidget);
    expect(find.text("What's wrong?"), findsOneWidget);
    expect(find.text('SUBMIT TO CONTROL ROOM'), findsOneWidget);

    // Switch to Control Room (Mode 1)
    await tester.tap(find.text('Control Room'));
    await tester.pumpAndSettle();

    expect(find.text('METROFIX CONTROL ROOM'), findsOneWidget);
    expect(find.text('HIGH'), findsOneWidget);
    expect(find.text('MEDIUM'), findsOneWidget);
    expect(find.text('LOW'), findsOneWidget);

    // Switch to Technician View (Mode 2)
    await tester.tap(find.text('Technician View'));
    await tester.pumpAndSettle();

    expect(find.text('TECHNICIAN CONSOLE'), findsOneWidget);
    expect(find.text('MAINTENANCE HISTORY'), findsOneWidget);
    expect(find.text('MARK AS RESOLVED'), findsOneWidget);

    // Resolve open issues
    await tester.tap(find.text('MARK AS RESOLVED'));
    await tester.pumpAndSettle();

    expect(find.text('OPERATIONAL / ALL CLEAR'), findsOneWidget);
  });
}
