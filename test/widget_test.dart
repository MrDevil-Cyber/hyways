import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyways/main.dart';
import 'package:hyways/services/auth_session_store.dart';

void main() {
  testWidgets('industrial landing page renders', (tester) async {
    tester.view.physicalSize = const Size(740, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final servicesApi = HywayApi(sessionStore: _EmptyAuthSessionStore());
    addTearDown(servicesApi.dispose);
    await tester.pumpWidget(Hyway(servicesApi: servicesApi));
    await tester.pumpAndSettle();

    expect(find.text('SMART SOLUTIONS FOR'), findsOneWidget);
    expect(find.text('Get a Quote'), findsOneWidget);
    expect(find.text('Conveyors'), findsOneWidget);
  });

  testWidgets('services auth gate keeps bottom navigation visible', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 1400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final servicesApi = HywayApi(sessionStore: _EmptyAuthSessionStore());
    addTearDown(servicesApi.dispose);
    await tester.pumpWidget(Hyway(servicesApi: servicesApi));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Services'));
    await tester.pumpAndSettle();

    expect(find.text('SERVICE HUB'), findsOneWidget);
    expect(find.text('Keep your machines moving.'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('every product category becomes visibly available', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(740, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const Hyway());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Products').last);
    await tester.pumpAndSettle();

    Future<void> expectVisibleProduct(String category, String product) async {
      await tester.tap(find.text(category).last);
      await tester.pumpAndSettle();
      final productFinder = find.text(product);
      expect(productFinder, findsOneWidget);
      final opacityWidgets = tester.widgetList<Opacity>(
        find.ancestor(of: productFinder, matching: find.byType(Opacity)),
      );
      expect(opacityWidgets.every((widget) => widget.opacity > .99), isTrue);
      final animatedOpacityWidgets = tester.widgetList<AnimatedOpacity>(
        find.ancestor(
          of: productFinder,
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(
        animatedOpacityWidgets.every((widget) => widget.opacity > .99),
        isTrue,
      );
    }

    await expectVisibleProduct('Mixer', 'Cone Blender');
    await expectVisibleProduct('Washer', 'Crate Washer');
    await expectVisibleProduct('Snacks Machines', 'Flavoring Drum');
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _EmptyAuthSessionStore implements AuthSessionStore {
  @override
  Future<void> clear() async {}

  @override
  Future<StoredAuthSession?> read() async => null;

  @override
  Future<void> write(StoredAuthSession session) async {}
}
