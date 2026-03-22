import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:file_zen/features/dashboard/presentation/widgets/auto_sorter_status.dart';
import 'package:file_zen/features/dashboard/presentation/widgets/storage_overview_widget.dart';

void main() {
  testWidgets('Dashboard widgets render key labels', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              StorageOverviewWidget(),
              AutoSorterStatus(),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Vault Storage'), findsOneWidget);
    expect(find.text('Auto-Sorter Active'), findsOneWidget);
  });
}
