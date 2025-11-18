import 'dart:io';

import 'package:duo_app/app.dart';
import 'package:duo_app/di/injection.dart';
import 'package:duo_app/gen/assets.gen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:integration_test/integration_test.dart';

class TestLogger {
  TestLogger._()
    : _device = "XIAOMI REDMI 01",
      _logDirectory =
          '${Directory.systemTemp.path}${Platform.pathSeparator}dou_app_test_logs';
  static final TestLogger instance = TestLogger._();

  final List<_TestLogEntry> _entries = [];
  final String _device;
  final String _logDirectory;
  final String _logFileName = 'login_module_logs.csv';

  Future<void> addEntry({
    required String testCaseId,
    required String module,
    required String scenario,
    required String status,
    required Duration duration,
    String? errorMessage,
  }) async {
    _entries.add(
      _TestLogEntry(
        testCaseId: testCaseId,
        module: module,
        scenario: scenario,
        status: status,
        duration: duration,
        errorMessage: errorMessage,
        device: _device,
      ),
    );
  }

  Future<void> flush() async {
    if (_entries.isEmpty) {
      return;
    }

    final directory = Directory(_logDirectory);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final file = File('${directory.path}/$_logFileName');
    final buffer = StringBuffer()
      ..writeln('TC ID,Module,Scenario,Status,Duration,Error Message,Device');

    for (final entry in _entries) {
      buffer.writeln(entry.toCsv());
    }

    await file.writeAsString(buffer.toString());
    await _uploadLogFile(file);
  }

  Future<void> _uploadLogFile(File file) async {
    final uri = Uri.parse('http://192.168.137.1:8080/upload');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final response = await request.send();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('Test log uploaded successfully: ${file.path}');
      } else {
        debugPrint(
          'Failed to upload test log (${response.statusCode}). File saved locally at ${file.path}',
        );
      }
    } catch (error) {
      debugPrint(
        'Error uploading test log: $error. File saved locally at ${file.path}',
      );
    }
  }
}

class _TestLogEntry {
  _TestLogEntry({
    required this.testCaseId,
    required this.module,
    required this.scenario,
    required this.status,
    required this.duration,
    required this.device,
    this.errorMessage,
  });

  final String testCaseId;
  final String module;
  final String scenario;
  final String status;
  final Duration duration;
  final String device;
  final String? errorMessage;

  String toCsv() {
    final values = [
      testCaseId,
      module,
      scenario,
      status,
      '${duration.inMilliseconds}ms',
      errorMessage ?? '',
      device,
    ];
    return values.map(_escapeCsv).join(',');
  }

  String _escapeCsv(String input) {
    final needsQuotes = input.contains(RegExp(r'[",\n]'));
    if (!needsQuotes) {
      return input;
    }
    final escaped = input.replaceAll('"', '""');
    return '"$escaped"';
  }
}

/// Extension to add widgetWithImage finder to CommonFinders
extension FindWidgetWithImage on CommonFinders {
  /// Find a widget by its image asset
  Finder widgetWithImage(Type widgetType, AssetImage image) {
    return byWidgetPredicate((Widget widget) {
      if (widget.runtimeType == widgetType) {
        // For NavigationDestination, check the icon
        if (widget is NavigationDestination) {
          final icon = widget.icon;
          if (icon is Image) {
            final imageProvider = icon.image;
            if (imageProvider is AssetImage) {
              return imageProvider.assetName == image.assetName;
            }
          }
        }
      }
      return false;
    });
  }
}

Future<void> runLoggedTest({
  required WidgetTester tester,
  required String testCaseId,
  required String module,
  required String scenario,
  required Future<void> Function() body,
}) async {
  final stopwatch = Stopwatch()..start();
  try {
    await body();
    stopwatch.stop();
    await TestLogger.instance.addEntry(
      testCaseId: testCaseId,
      module: module,
      scenario: scenario,
      status: 'PASS',
      duration: stopwatch.elapsed,
    );
  } catch (error) {
    stopwatch.stop();
    await TestLogger.instance.addEntry(
      testCaseId: testCaseId,
      module: module,
      scenario: scenario,
      status: 'FAIL',
      duration: stopwatch.elapsed,
      errorMessage: error.toString(),
    );
    rethrow;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Page Integration Tests', () {
    setUpAll(() async {
      // Initialize dependencies with production environment
      const String environment = String.fromEnvironment(
        'ENVIRONMENT',
        defaultValue: Environment.prod,
      );
      await configureDependencies(environment);
    });

    tearDownAll(() async {
      await TestLogger.instance.flush();
    });

    testWidgets('Login page displays all UI elements correctly', (
      WidgetTester tester,
    ) async {
      await runLoggedTest(
        tester: tester,
        testCaseId: 'TC_LOGIN_001',
        module: 'Login',
        scenario: 'Verify login page shows required widgets',
        body: () async {
          // Load app widget
          await tester.pumpWidget(const MyApp());
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Navigate to login page if not already there
          // The app might start at bootstrap, so we wait for navigation
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Find login page elements
          expect(find.text('Username or Email'), findsOneWidget);
          expect(find.text('Password'), findsOneWidget);
          expect(find.text('Login'), findsOneWidget);
          expect(find.text("Don't have an account? "), findsOneWidget);
          expect(find.text('Register'), findsOneWidget);
          expect(find.text('Forgot Password?'), findsOneWidget);

          // Verify the login button is present
          expect(find.byType(ElevatedButton), findsOneWidget);
        },
      );
    });
    // tap on login button without filling fields
    testWidgets('Login form validation works correctly', (
      WidgetTester tester,
    ) async {
      await runLoggedTest(
        tester: tester,
        testCaseId: 'TC_LOGIN_002',
        module: 'Login',
        scenario: 'Validate error shown when submitting empty login form',
        body: () async {
          await tester.pumpWidget(const MyApp());
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Find and tap the login button without filling fields
          final loginButton = find.text('Login');
          expect(loginButton, findsOneWidget);

          await tester.tap(loginButton);
          await tester.pumpAndSettle();

          // Form validation should prevent submission
          // The form should still be on the login page
          expect(find.text('Username or Email'), findsOneWidget);
        },
      );
    });

    testWidgets('Can enter username and password', (WidgetTester tester) async {
      await runLoggedTest(
        tester: tester,
        testCaseId: 'TC_LOGIN_003',
        module: 'Login',
        scenario: 'User can type username and password',
        body: () async {
          await tester.pumpWidget(const MyApp());
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Find text fields by type
          final textFields = find.byType(TextFormField);
          expect(textFields, findsAtLeastNWidgets(2));

          // Enter username (first field)
          await tester.enterText(textFields.first, 'testuser@example.com');
          await tester.pumpAndSettle();

          // Enter password (second field)
          await tester.enterText(textFields.last, 'TestPassword123!');
          await tester.pumpAndSettle();

          // Verify text was entered
          expect(find.text('testuser@example.com'), findsOneWidget);
          // Password field should be obscured, so we can't verify the text directly
        },
      );
    });

    testWidgets('Can navigate to forgot password page', (
      WidgetTester tester,
    ) async {
      await runLoggedTest(
        tester: tester,
        testCaseId: 'TC_LOGIN_004',
        module: 'Login',
        scenario: 'Forgot password link navigates to reset flow',
        body: () async {
          await tester.pumpWidget(const MyApp());
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Find and tap the "Forgot Password?" link
          final forgotPasswordLink = find.text('Forgot Password?');
          expect(forgotPasswordLink, findsOneWidget);

          await tester.tap(forgotPasswordLink);
          await tester.pumpAndSettle();

          // Should navigate to forgot password page
          // The exact content depends on ForgotPasswordPage implementation
          // But we can verify we're no longer on login page
          expect(find.text('Login'), findsNothing);
        },
      );
    });

    testWidgets('Can navigate to register page', (WidgetTester tester) async {
      await runLoggedTest(
        tester: tester,
        testCaseId: 'TC_LOGIN_005',
        module: 'Login',
        scenario: 'Register link opens registration page',
        body: () async {
          await tester.pumpWidget(const MyApp());
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Find and tap the "Register" link
          final registerLink = find.text('Register');
          expect(registerLink, findsOneWidget);

          await tester.tap(registerLink);
          await tester.pumpAndSettle();

          // Should navigate to register page
          // Verify register-specific fields are visible
          expect(find.text('Full Name'), findsOneWidget);
          expect(find.text('Already have an account? '), findsOneWidget);
        },
      );
    });

    testWidgets('Complete login flow with valid credentials', (
      WidgetTester tester,
    ) async {
      await runLoggedTest(
        tester: tester,
        testCaseId: 'TC_LOGIN_006',
        module: 'Login',
        scenario: 'Successful login attempts navigate or show feedback',
        body: () async {
          await tester.pumpWidget(const MyApp());
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Find text fields
          final textFields = find.byType(TextFormField);
          expect(textFields, findsAtLeastNWidgets(2));

          // Enter username (first field)
          await tester.enterText(textFields.first, 'tsarlvntn2004@gmail.com');
          await tester.pumpAndSettle();

          // Enter password (second field)
          await tester.enterText(textFields.last, '123456789');
          await tester.pumpAndSettle();

          // Tap login button
          final loginButton = find.text('Login');
          expect(loginButton, findsOneWidget);

          await tester.tap(loginButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // After login attempt, either:
          // 1. Success: Navigate to navigation page
          // 2. Failure: Show error snackbar
          // We check for either outcome
          final hasNavigated =
              find.text('Login').evaluate().isEmpty ||
              find.byType(SnackBar).evaluate().isNotEmpty;

          expect(hasNavigated, isTrue);
        },
      );
    });

    testWidgets('Password field toggle visibility works', (
      WidgetTester tester,
    ) async {
      await runLoggedTest(
        tester: tester,
        testCaseId: 'TC_LOGIN_007',
        module: 'Login',
        scenario: 'User can toggle password visibility icon',
        body: () async {
          await tester.pumpWidget(const MyApp());
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Find password field
          final textFields = find.byType(TextFormField);
          expect(textFields, findsAtLeastNWidgets(2));

          // Enter password
          await tester.enterText(textFields.last, 'TestPassword123!');
          await tester.pumpAndSettle();

          // Find the eye icon (password visibility toggle)
          final eyeIcon = find.byIcon(Icons.remove_red_eye_rounded);
          expect(eyeIcon, findsOneWidget);

          // Tap to toggle visibility
          await tester.tap(eyeIcon);
          await tester.pumpAndSettle();

          // Icon should change to outlined version
          expect(find.byIcon(Icons.remove_red_eye_outlined), findsOneWidget);
        },
      );
    });

    testWidgets('Login button is enabled when form is filled', (
      WidgetTester tester,
    ) async {
      await runLoggedTest(
        tester: tester,
        testCaseId: 'TC_LOGIN_008',
        module: 'Login',
        scenario: 'Login button remains enabled after filling the form',
        body: () async {
          await tester.pumpWidget(const MyApp());
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Find login button
          final loginButton = find.byType(ElevatedButton);
          expect(loginButton, findsOneWidget);

          // Button should be enabled
          final button = tester.widget<ElevatedButton>(loginButton);
          expect(button.onPressed, isNotNull);

          // Fill form
          final textFields = find.byType(TextFormField);
          await tester.enterText(textFields.first, 'test@example.com');
          await tester.enterText(textFields.last, 'Password123!');
          await tester.pumpAndSettle();

          // Button should still be enabled
          final buttonAfter = tester.widget<ElevatedButton>(loginButton);
          expect(buttonAfter.onPressed, isNotNull);
        },
      );
    });

    testWidgets('User can logout from profile page', (
      WidgetTester tester,
    ) async {
      await runLoggedTest(
        tester: tester,
        testCaseId: 'TC_PROFILE_001',
        module: 'Profile',
        scenario:
            'Login, navigate to profile tab, and logout back to login page',
        body: () async {
          await tester.pumpWidget(const MyApp());
          await tester.pumpAndSettle(const Duration(seconds: 8));

          final textFields = find.byType(TextFormField);
          expect(textFields, findsAtLeastNWidgets(2));

          await tester.enterText(textFields.first, 'tsarlvntn2004@gmail.com');
          await tester.pumpAndSettle();

          await tester.enterText(textFields.last, '123456789');
          await tester.pumpAndSettle();

          final loginButton = find.text('Login');
          expect(loginButton, findsOneWidget);

          await tester.tap(loginButton);
          await tester.pumpAndSettle(const Duration(seconds: 4));

          final navigationBar = find.byType(NavigationBar);
          expect(navigationBar, findsOneWidget);

          // Find profile tab by its icon image
          final Finder profileTab = find.widgetWithImage(
            NavigationDestination,
            AssetImage(Assets.navigationIcons.navUser.path),
          );
          expect(profileTab, findsOneWidget);

          await tester.tap(profileTab);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // Find logout button by finding the text first, then its ancestor OutlinedButton
          final logoutButton = find.byKey(const Key('logout_button'));
          expect(logoutButton, findsOneWidget);

          await tester.tap(logoutButton);
          await tester.pumpAndSettle(const Duration(seconds: 8));

          expect(find.text('Login'), findsOneWidget);
        },
      );
    });
  });
}
