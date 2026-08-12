import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:priora/core/widgets/shimmer.dart';

void main() {
  testWidgets('Shimmer renders its child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Shimmer(child: Text('Cargando')),
        ),
      ),
    );

    expect(find.byType(Shimmer), findsOneWidget);
    expect(find.text('Cargando'), findsOneWidget);
  });
}
