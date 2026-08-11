import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:hyways/main.dart';
import 'package:hyways/services/auth_session_store.dart';

void main() {
  test('login persists and a new API instance restores the session', () async {
    final store = _MemoryAuthSessionStore();
    final firstApi = HywayApi(
      sessionStore: store,
      client: MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/login');
        return _jsonResponse(_authPayload('access-1', 'refresh-1'));
      }),
    );

    await firstApi.login(
      email: 'customer@example.com',
      password: 'Password123!',
    );
    expect(store.value?.refreshToken, 'refresh-1');
    firstApi.dispose();

    final restoredApi = HywayApi(
      sessionStore: store,
      client: MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/me');
        return _jsonResponse(_userPayload());
      }),
    );
    addTearDown(restoredApi.dispose);

    await restoredApi.restoreSession();

    expect(restoredApi.isAuthenticated, isTrue);
    expect(restoredApi.session?.email, 'customer@example.com');
    expect(restoredApi.session?.refreshToken, 'refresh-1');
  });

  test(
    '401 refreshes once, persists rotation, and retries the request',
    () async {
      final store = _MemoryAuthSessionStore();
      var refreshCalls = 0;
      var serviceCalls = 0;
      final api = HywayApi(
        sessionStore: store,
        client: MockClient((request) async {
          switch (request.url.path) {
            case '/api/v1/auth/login':
              return _jsonResponse(_authPayload('old-access', 'old-refresh'));
            case '/api/v1/auth/refresh':
              refreshCalls++;
              expect(jsonDecode(request.body)['refreshToken'], 'old-refresh');
              return _jsonResponse(_authPayload('new-access', 'new-refresh'));
            case '/api/v1/services/requests':
              serviceCalls++;
              if (request.headers['Authorization'] == 'Bearer old-access') {
                return _jsonResponse({'message': 'Expired'}, statusCode: 401);
              }
              expect(request.headers['Authorization'], 'Bearer new-access');
              return _jsonResponse({'id': 'request-1'}, statusCode: 201);
            default:
              return _jsonResponse({'message': 'Not found'}, statusCode: 404);
          }
        }),
      );
      addTearDown(api.dispose);

      await api.login(email: 'customer@example.com', password: 'Password123!');
      final result = await api.createServiceRequest(body: _serviceBody());

      expect(result['id'], 'request-1');
      expect(refreshCalls, 1);
      expect(serviceCalls, 2);
      expect(store.value?.accessToken, 'new-access');
      expect(store.value?.refreshToken, 'new-refresh');
    },
  );

  test('simultaneous 401 responses share one refresh operation', () async {
    final store = _MemoryAuthSessionStore();
    var refreshCalls = 0;
    final api = HywayApi(
      sessionStore: store,
      client: MockClient((request) async {
        if (request.url.path == '/api/v1/auth/login') {
          return _jsonResponse(_authPayload('old-access', 'old-refresh'));
        }
        if (request.url.path == '/api/v1/auth/refresh') {
          refreshCalls++;
          await Future<void>.delayed(const Duration(milliseconds: 15));
          return _jsonResponse(_authPayload('new-access', 'new-refresh'));
        }
        final authorization = request.headers['Authorization'];
        if (authorization == 'Bearer old-access') {
          return _jsonResponse({'message': 'Expired'}, statusCode: 401);
        }
        expect(authorization, 'Bearer new-access');
        return _jsonResponse({'id': 'created'}, statusCode: 201);
      }),
    );
    addTearDown(api.dispose);

    await api.login(email: 'customer@example.com', password: 'Password123!');
    await Future.wait([
      api.createServiceRequest(body: _serviceBody()),
      api.createMachineScan(body: {'serialNumber': 'HY-101'}),
    ]);

    expect(refreshCalls, 1);
  });

  test('revoked refresh token clears the saved session', () async {
    final store = _MemoryAuthSessionStore();
    final api = HywayApi(
      sessionStore: store,
      client: MockClient((request) async {
        if (request.url.path == '/api/v1/auth/login') {
          return _jsonResponse(_authPayload('old-access', 'old-refresh'));
        }
        if (request.url.path == '/api/v1/auth/refresh') {
          return _jsonResponse({'message': 'Revoked'}, statusCode: 401);
        }
        return _jsonResponse({'message': 'Expired'}, statusCode: 401);
      }),
    );
    addTearDown(api.dispose);

    await api.login(email: 'customer@example.com', password: 'Password123!');

    await expectLater(
      api.createServiceRequest(body: _serviceBody()),
      throwsA(
        isA<ApiException>().having(
          (error) => error.statusCode,
          'statusCode',
          401,
        ),
      ),
    );
    expect(api.session, isNull);
    expect(store.value, isNull);
  });

  test('offline logout still clears the local secure session', () async {
    final store = _MemoryAuthSessionStore();
    final api = HywayApi(
      sessionStore: store,
      client: MockClient((request) async {
        if (request.url.path == '/api/v1/auth/login') {
          return _jsonResponse(_authPayload('access-1', 'refresh-1'));
        }
        throw http.ClientException('offline');
      }),
    );
    addTearDown(api.dispose);

    await api.login(email: 'customer@example.com', password: 'Password123!');
    await api.logout();

    expect(api.session, isNull);
    expect(store.value, isNull);
  });

  test('logout cannot be undone by an in-flight token refresh', () async {
    final store = _MemoryAuthSessionStore();
    final refreshStarted = Completer<void>();
    final releaseRefresh = Completer<void>();
    final api = HywayApi(
      sessionStore: store,
      client: MockClient((request) async {
        switch (request.url.path) {
          case '/api/v1/auth/login':
            return _jsonResponse(_authPayload('old-access', 'old-refresh'));
          case '/api/v1/services/requests':
            return _jsonResponse({'message': 'Expired'}, statusCode: 401);
          case '/api/v1/auth/refresh':
            refreshStarted.complete();
            await releaseRefresh.future;
            return _jsonResponse(_authPayload('new-access', 'new-refresh'));
          case '/api/v1/auth/logout':
            return _jsonResponse({'message': 'Logged out successfully'});
          default:
            return _jsonResponse({'message': 'Not found'}, statusCode: 404);
        }
      }),
    );
    addTearDown(api.dispose);

    await api.login(email: 'customer@example.com', password: 'Password123!');
    final requestExpectation = expectLater(
      api.createServiceRequest(body: _serviceBody()),
      throwsA(
        isA<ApiException>().having(
          (error) => error.statusCode,
          'statusCode',
          409,
        ),
      ),
    );
    await refreshStarted.future;
    await api.logout();
    releaseRefresh.complete();
    await requestExpectation;

    expect(api.session, isNull);
    expect(store.value, isNull);
  });

  testWidgets('saved session opens Services dashboard without login', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 1400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = _MemoryAuthSessionStore()
      ..value = const StoredAuthSession(
        userId: 'user-1',
        name: 'HYWAY Customer',
        email: 'customer@example.com',
        role: 'CUSTOMER',
        accessToken: 'saved-access',
        refreshToken: 'saved-refresh',
      );
    final api = HywayApi(
      sessionStore: store,
      client: MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/me');
        return _jsonResponse(_userPayload());
      }),
    );
    addTearDown(api.dispose);

    await tester.pumpWidget(Hyway(servicesApi: api));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Services'));
    await tester.pumpAndSettle();

    expect(find.text('How can HYWAY help?'), findsOneWidget);
    expect(find.text('Log in'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class _MemoryAuthSessionStore implements AuthSessionStore {
  StoredAuthSession? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<StoredAuthSession?> read() async => value;

  @override
  Future<void> write(StoredAuthSession session) async => value = session;
}

http.Response _jsonResponse(
  Map<String, dynamic> body, {
  int statusCode = 200,
}) => http.Response(
  jsonEncode(body),
  statusCode,
  headers: const {'content-type': 'application/json'},
);

Map<String, dynamic> _authPayload(String accessToken, String refreshToken) => {
  'user': _userPayload(),
  'accessToken': accessToken,
  'refreshToken': refreshToken,
};

Map<String, dynamic> _userPayload() => {
  'id': 'user-1',
  'name': 'HYWAY Customer',
  'email': 'customer@example.com',
  'role': 'CUSTOMER',
};

Map<String, dynamic> _serviceBody() => {
  'machineName': 'Spiral Conveyor',
  'machineCategory': 'Conveyors',
  'serviceType': 'REPAIR',
  'issueDescription': 'Unexpected vibration during operation',
  'urgency': 'NORMAL',
};
