part of '../main.dart';

String get _apiBaseUrl {
  const configured = String.fromEnvironment('API_BASE_URL');
  if (configured.isNotEmpty) return configured;
  // Android emulator can reach the host machine through 10.0.2.2.
  if (Platform.isAndroid) return 'http://10.0.2.2:3000/api/v1';
  return 'http://127.0.0.1:3000/api/v1';
}

class AuthSession {
  const AuthSession({
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.company,
    this.jobTitle,
    this.city,
    this.state,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
  });

  final String userId;
  final String name;
  final String email;
  final String? phone;
  final String? company;
  final String? jobTitle;
  final String? city;
  final String? state;
  final String role;
  final String accessToken;
  final String refreshToken;

  factory AuthSession.fromAuthResponse(Map<String, dynamic> json) {
    final user = json['user'];
    if (user is! Map<String, dynamic>) {
      throw const FormatException('Missing user in authentication response');
    }
    String requiredString(Map<String, dynamic> source, String key) {
      final value = source[key]?.toString().trim() ?? '';
      if (value.isEmpty) throw FormatException('Missing $key');
      return value;
    }

    return AuthSession(
      userId: requiredString(user, 'id'),
      name: requiredString(user, 'name'),
      email: requiredString(user, 'email'),
      phone: user['phone']?.toString().trim(),
      company: user['company']?.toString().trim(),
      jobTitle: user['jobTitle']?.toString().trim(),
      city: user['city']?.toString().trim(),
      state: user['state']?.toString().trim(),
      role: requiredString(user, 'role'),
      accessToken: requiredString(json, 'accessToken'),
      refreshToken: requiredString(json, 'refreshToken'),
    );
  }

  factory AuthSession.fromStored(StoredAuthSession stored) => AuthSession(
    userId: stored.userId,
    name: stored.name,
    email: stored.email,
    phone: stored.phone,
    company: stored.company,
    jobTitle: stored.jobTitle,
    city: stored.city,
    state: stored.state,
    role: stored.role,
    accessToken: stored.accessToken,
    refreshToken: stored.refreshToken,
  );

  StoredAuthSession toStored() => StoredAuthSession(
    userId: userId,
    name: name,
    email: email,
    phone: phone,
    company: company,
    jobTitle: jobTitle,
    city: city,
    state: state,
    role: role,
    accessToken: accessToken,
    refreshToken: refreshToken,
  );

  AuthSession withProfile(Map<String, dynamic> user) => AuthSession(
    userId: user['id']?.toString() ?? userId,
    name: user['name']?.toString() ?? name,
    email: user['email']?.toString() ?? email,
    phone: user['phone']?.toString().trim() ?? phone,
    company: user['company']?.toString().trim() ?? company,
    jobTitle: user['jobTitle']?.toString().trim() ?? jobTitle,
    city: user['city']?.toString().trim() ?? city,
    state: user['state']?.toString().trim() ?? state,
    role: user['role']?.toString() ?? role,
    accessToken: accessToken,
    refreshToken: refreshToken,
  );
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class HywayApi extends ChangeNotifier {
  HywayApi({http.Client? client, AuthSessionStore? sessionStore})
    : _client = client ?? http.Client(),
      _sessionStore = sessionStore ?? SecureAuthSessionStore();

  final http.Client _client;
  final AuthSessionStore _sessionStore;

  AuthSession? _session;
  Future<AuthSession>? _refreshInFlight;
  int _authRevision = 0;
  bool _restoring = true;
  bool _disposed = false;

  AuthSession? get session => _session;
  bool get restoring => _restoring;
  bool get isAuthenticated => _session != null;

  Future<void> restoreSession() async {
    try {
      final stored = await _sessionStore.read();
      _session = stored == null ? null : AuthSession.fromStored(stored);
    } catch (_) {
      _session = null;
      await _safeClearStore();
    } finally {
      _restoring = false;
      _notifySafely();
    }

    if (_session != null) unawaited(_validateRestoredSession());
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final json = await _post('/auth/login', {
      'email': email.trim(),
      'password': password,
    });
    return _acceptAuthResponse(json);
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String phone,
    required String company,
    required String jobTitle,
    required String city,
    required String state,
    required String password,
  }) async {
    final json = await _post('/auth/register', {
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'company': company.trim(),
      'jobTitle': jobTitle.trim(),
      'city': city.trim(),
      'state': state.trim(),
      'password': password,
    });
    return _acceptAuthResponse(json);
  }

  Future<void> logout() async {
    final refreshToken = _session?.refreshToken;
    await _invalidateLocalSession();
    if (refreshToken == null || refreshToken.isEmpty) return;
    try {
      await _post('/auth/logout', {'refreshToken': refreshToken});
    } catch (_) {
      // Local logout must always succeed, even when the server is unreachable.
    }
  }

  Future<Map<String, dynamic>> createServiceRequest({
    required Map<String, dynamic> body,
  }) => _post('/services/requests', body, authenticated: true);

  Future<Map<String, dynamic>> createMachineScan({
    required Map<String, dynamic> body,
  }) => _post('/services/scans', body, authenticated: true);

  Future<Map<String, dynamic>> createSpaceAssessment({
    required Map<String, dynamic> body,
  }) => _post('/services/space-assessments', body, authenticated: true);

  Future<AuthSession> _acceptAuthResponse(
    Map<String, dynamic> json, {
    int? expectedRevision,
  }) async {
    try {
      final value = AuthSession.fromAuthResponse(json);
      await _persistAndSetSession(value, expectedRevision: expectedRevision);
      return value;
    } on FormatException {
      throw const ApiException(
        'Server returned an incomplete authentication response.',
      );
    }
  }

  Future<void> _validateRestoredSession() async {
    try {
      final profile = await _get('/auth/me', authenticated: true);
      final current = _session;
      if (current != null) {
        await _persistAndSetSession(
          current.withProfile(profile),
          expectedRevision: _authRevision,
        );
      }
    } on ApiException catch (error) {
      if (error.statusCode == 401) await _invalidateLocalSession();
    } catch (_) {
      // A temporary network failure must not erase a valid saved session.
    }
  }

  Future<AuthSession> _refreshSession() {
    final activeRefresh = _refreshInFlight;
    if (activeRefresh != null) return activeRefresh;

    late final Future<AuthSession> refresh;
    refresh = _performRefresh().whenComplete(() {
      if (identical(_refreshInFlight, refresh)) _refreshInFlight = null;
    });
    _refreshInFlight = refresh;
    return refresh;
  }

  Future<AuthSession> _performRefresh() async {
    final current = _session;
    final expectedRevision = _authRevision;
    if (current == null || current.refreshToken.isEmpty) {
      await _invalidateLocalSession();
      throw const ApiException(
        'Your session has expired. Please log in again.',
        statusCode: 401,
      );
    }

    try {
      final json = await _post('/auth/refresh', {
        'refreshToken': current.refreshToken,
      });
      return await _acceptAuthResponse(
        json,
        expectedRevision: expectedRevision,
      );
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await _invalidateLocalSession();
        throw const ApiException(
          'Your session has expired. Please log in again.',
          statusCode: 401,
        );
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    bool authenticated = false,
    bool retryAfterRefresh = true,
  }) => _request(
    'GET',
    path,
    authenticated: authenticated,
    retryAfterRefresh: retryAfterRefresh,
  );

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    bool authenticated = false,
    bool retryAfterRefresh = true,
  }) => _request(
    'POST',
    path,
    body: body,
    authenticated: authenticated,
    retryAfterRefresh: retryAfterRefresh,
  );

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    required bool authenticated,
    required bool retryAfterRefresh,
  }) async {
    final token = _session?.accessToken;
    if (authenticated && (token == null || token.isEmpty)) {
      throw const ApiException('Please log in to continue.', statusCode: 401);
    }

    late final http.Response response;
    try {
      final uri = Uri.parse('$_apiBaseUrl$path');
      final headers = <String, String>{
        'Accept': 'application/json',
        if (body != null) 'Content-Type': 'application/json',
        if (authenticated) 'Authorization': 'Bearer $token',
      };
      response = await switch (method) {
        'GET' => _client.get(uri, headers: headers),
        'POST' => _client.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? const <String, dynamic>{}),
        ),
        _ => throw ArgumentError.value(method, 'method'),
      }.timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw const ApiException(
        'Server is taking too long to respond. Please try again.',
      );
    } on http.ClientException {
      throw const ApiException('Could not connect to the service server.');
    } catch (error, stackTrace) {
      if (error is ArgumentError ||
          error is FormatException ||
          error is StateError ||
          error is TypeError) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      debugPrint('HYWAY API $method $path failed: $error\n$stackTrace');
      throw const ApiException(
        'Could not connect to the HYWAY service server.',
      );
    }

    if (response.statusCode == 401 && authenticated) {
      if (retryAfterRefresh) {
        await _refreshSession();
        return _request(
          method,
          path,
          body: body,
          authenticated: true,
          retryAfterRefresh: false,
        );
      }
      await _invalidateLocalSession();
    }

    final decoded = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final rawMessage = decoded['message'];
      final message = rawMessage is List
          ? rawMessage.join('\n')
          : rawMessage?.toString() ?? 'Request failed (${response.statusCode})';
      throw ApiException(message, statusCode: response.statusCode);
    }
    return decoded;
  }

  Future<void> _persistAndSetSession(
    AuthSession value, {
    int? expectedRevision,
  }) async {
    if (expectedRevision != null && expectedRevision != _authRevision) {
      throw const ApiException(
        'Authentication state changed. Please try again.',
        statusCode: 409,
      );
    }
    try {
      await _sessionStore.write(value.toStored());
    } catch (_) {
      await _safeClearStore();
      _session = null;
      _notifySafely();
      throw const ApiException(
        'Your secure login session could not be saved. Please try again.',
      );
    }
    if (expectedRevision != null && expectedRevision != _authRevision) {
      await _safeClearStore();
      throw const ApiException(
        'Authentication state changed. Please try again.',
        statusCode: 409,
      );
    }
    _session = value;
    _authRevision++;
    _notifySafely();
  }

  Future<void> _invalidateLocalSession() async {
    _session = null;
    _authRevision++;
    _notifySafely();
    await _safeClearStore();
  }

  Future<void> _safeClearStore() async {
    try {
      await _sessionStore.clear();
    } catch (_) {
      // Storage cleanup is best effort when the platform keystore is unavailable.
    }
  }

  Map<String, dynamic> _decode(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{'data': decoded};
    } on FormatException {
      throw const ApiException('Server returned an unreadable response.');
    }
  }

  void _notifySafely() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _client.close();
    super.dispose();
  }
}

typedef _AuthSession = AuthSession;
typedef _ApiException = ApiException;
typedef _HywayApi = HywayApi;
