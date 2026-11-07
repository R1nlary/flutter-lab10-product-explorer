import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lab10_product_explorer/main.dart';
import 'package:flutter_lab10_product_explorer/services/product_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final _body = jsonEncode([
  {
    'id': 7,
    'title': 'Gold Ring',
    'price': 168,
    'description': 'A very shiny ring',
    'category': 'jewelery',
    'image': 'https://example.com/7.png',
    'rating': {'rate': 3.9, 'count': 70},
  },
]);

/// Answers each request with the next handler in [steps].
ProductService scripted(List<http.Response Function()> steps) {
  var call = 0;
  return ProductService(client: MockClient((_) async => steps[call++]()));
}

http.Response ok() => http.Response(_body, 200);
http.Response offline() => throw http.ClientException('offline');

Future<void> openDetails(WidgetTester tester) async {
  await tester.pumpWidget(ProductExplorerApp(service: scripted([ok])));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Gold Ring'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('spinner, then the feed', (tester) async {
    await tester.pumpWidget(ProductExplorerApp(service: scripted([ok])));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Gold Ring'), findsOneWidget);
    expect(find.text('\$168.00'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('offline error recovers through Retry Connection', (
    tester,
  ) async {
    final retryResponse = Completer<http.Response>();
    var calls = 0;
    final service = ProductService(
      client: MockClient((_) {
        calls++;
        if (calls == 1) throw http.ClientException('offline');
        return retryResponse.future;
      }),
    );

    await tester.pumpWidget(ProductExplorerApp(service: service));
    await tester.pumpAndSettle();

    expect(find.text('Retry Connection'), findsOneWidget);
    expect(find.textContaining('No internet'), findsOneWidget);

    await tester.tap(find.text('Retry Connection'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Retry Connection'), findsNothing);

    retryResponse.complete(ok());
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('Gold Ring'), findsOneWidget);
    expect(find.text('Retry Connection'), findsNothing);
  });

  testWidgets('failed pull-to-refresh keeps the list', (tester) async {
    await tester.pumpWidget(
      ProductExplorerApp(service: scripted([ok, offline])),
    );
    await tester.pumpAndSettle();

    await tester.fling(find.text('Gold Ring'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Gold Ring'), findsOneWidget);
    expect(find.textContaining('No internet'), findsOneWidget);
  });

  testWidgets('a mouse can drag the carousel', (tester) async {
    await openDetails(tester);

    await tester.drag(
      find.byType(PageView),
      const Offset(-500, 0),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();

    expect(find.text('2 / 3'), findsOneWidget);
  });

  testWidgets('detail screen shares the hero tag and full content', (
    tester,
  ) async {
    await openDetails(tester);

    final tags = tester
        .widgetList<Hero>(find.byType(Hero))
        .map((hero) => hero.tag)
        .toList();
    expect(tags, contains('product_image_7'));
    expect(find.text('A very shiny ring'), findsOneWidget);
    expect(find.text('jewelery'), findsOneWidget);
    expect(find.text('Add to Cart'), findsOneWidget);
  });

  testWidgets('swiping updates the counter and the active dot', (tester) async {
    await openDetails(tester);

    double dotWidth(int i) =>
        tester.getSize(find.byKey(ValueKey('carousel_dot_$i'))).width;

    expect(find.text('1 / 3'), findsOneWidget);
    expect(dotWidth(0), greaterThan(dotWidth(1)));

    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('2 / 3'), findsOneWidget);
    expect(dotWidth(1), greaterThan(dotWidth(0)));
  });

  testWidgets('share sheet shows and copies the deep link', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    await openDetails(tester);

    await tester.tap(find.byTooltip('Share'));
    await tester.pumpAndSettle();
    expect(find.text('narxoz://store/product/7'), findsOneWidget);

    await tester.tap(find.text('Copy Link'));
    await tester.pumpAndSettle();

    expect(copied, 'narxoz://store/product/7');
    expect(find.text('Copied'), findsOneWidget);
  });
}
