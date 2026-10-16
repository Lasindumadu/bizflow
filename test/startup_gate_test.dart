import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bizflow/core/widgets/app_shell.dart';
import 'package:bizflow/core/widgets/startup_gate.dart';

/// Tests for the Phase B startup gate.
///
/// The initializer and child are injected so these tests never touch the
/// global database singleton, SharedPreferences platform channels, or the
/// real AppShell.
void main() {
  const readyKey = Key('ready-child');

  Widget host(Future<void> Function() initializer) {
    return MaterialApp(
      home: StartupGate(
        initializer: initializer,
        child: const SizedBox(key: readyKey),
      ),
    );
  }

  testWidgets('shows branded loading state while initialization is pending', (
    tester,
  ) async {
    final completer = Completer<void>();

    await tester.pumpWidget(host(() => completer.future));

    expect(find.text('BizFlow'), findsOneWidget);
    expect(find.text('Starting your workspace…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(readyKey), findsNothing);

    completer.complete();
    await tester.pump();
  });

  testWidgets('reveals the child after initialization succeeds', (
    tester,
  ) async {
    final completer = Completer<void>();

    await tester.pumpWidget(host(() => completer.future));
    expect(find.byKey(readyKey), findsNothing);

    completer.complete();
    await tester.pump();

    expect(find.byKey(readyKey), findsOneWidget);
    expect(
      find.byType(CircularProgressIndicator),
      findsNothing,
      reason: 'loading UI must only show while init is in progress',
    );
    expect(find.text('BizFlow'), findsNothing);
  });

  testWidgets('shows a recoverable error state when initialization fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(() => Future<void>.error(StateError('disk unavailable'))),
    );
    await tester.pump();

    expect(find.text("BizFlow couldn't start"), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.textContaining('disk unavailable'), findsOneWidget);
    expect(find.byKey(readyKey), findsNothing);
  });

  testWidgets('retry re-runs initialization and recovers to the child', (
    tester,
  ) async {
    var attempts = 0;

    Future<void> initializer() {
      attempts += 1;
      if (attempts == 1) {
        return Future<void>.error(StateError('temporary failure'));
      }
      return Future<void>.value();
    }

    await tester.pumpWidget(host(initializer));
    await tester.pump();

    expect(attempts, 1);
    expect(find.text("BizFlow couldn't start"), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump();

    expect(attempts, 2);
    expect(find.byKey(readyKey), findsOneWidget);
    expect(find.text("BizFlow couldn't start"), findsNothing);
  });

  testWidgets('retry remains recoverable after repeated failures', (
    tester,
  ) async {
    var attempts = 0;

    Future<void> initializer() {
      attempts += 1;
      if (attempts < 3) {
        return Future<void>.error(StateError('failure $attempts'));
      }
      return Future<void>.value();
    }

    await tester.pumpWidget(host(initializer));
    await tester.pump();
    expect(attempts, 1);
    expect(find.text("BizFlow couldn't start"), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump();

    expect(attempts, 2);
    expect(
      find.text("BizFlow couldn't start"),
      findsOneWidget,
      reason: 'a second failure must stay recoverable, not freeze or crash',
    );
    expect(find.textContaining('failure 2'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump();

    expect(attempts, 3);
    expect(find.byKey(readyKey), findsOneWidget);
    expect(find.text("BizFlow couldn't start"), findsNothing);
  });

  testWidgets('initialization runs exactly once — no duplicate startup work', (
    tester,
  ) async {
    var calls = 0;
    final completer = Completer<void>();

    Future<void> initializer() {
      calls += 1;
      return completer.future;
    }

    await tester.pumpWidget(host(initializer));
    await tester.pump();
    expect(calls, 1);

    // Rebuilds with a fresh initializer closure must not restart startup work.
    await tester.pumpWidget(host(initializer));
    await tester.pump();
    expect(calls, 1);

    completer.complete();
    await tester.pump();

    expect(calls, 1, reason: 'completing must not trigger a second run');
    expect(find.byKey(readyKey), findsOneWidget);
  });

  testWidgets('defaults to the existing app shell as its child', (
    tester,
  ) async {
    // Construct only — never build AppShell here (building it would touch
    // the global database singleton; the production default is what we assert).
    expect(const StartupGate().child, isA<AppShell>());
  });

  testWidgets(
    'error state fits a narrow phone-sized viewport without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        host(() => Future<void>.error(StateError('disk unavailable'))),
      );
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text("BizFlow couldn't start"), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    },
  );
}
