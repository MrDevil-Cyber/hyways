import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoredAuthSession {
  const StoredAuthSession({
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

  static const version = 2;

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

  Map<String, dynamic> toJson() => {
    'version': version,
    'userId': userId,
    'name': name,
    'email': email,
    'phone': phone,
    'company': company,
    'jobTitle': jobTitle,
    'city': city,
    'state': state,
    'role': role,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
  };

  factory StoredAuthSession.fromJson(Map<String, dynamic> json) {
    if (json['version'] != version) {
      throw const FormatException('Unsupported auth session version');
    }
    String requiredString(String key) {
      final value = json[key]?.toString().trim() ?? '';
      if (value.isEmpty) throw FormatException('Missing $key');
      return value;
    }

    return StoredAuthSession(
      userId: requiredString('userId'),
      name: requiredString('name'),
      email: requiredString('email'),
      phone: json['phone']?.toString().trim(),
      company: json['company']?.toString().trim(),
      jobTitle: json['jobTitle']?.toString().trim(),
      city: json['city']?.toString().trim(),
      state: json['state']?.toString().trim(),
      role: requiredString('role'),
      accessToken: requiredString('accessToken'),
      refreshToken: requiredString('refreshToken'),
    );
  }
}

abstract interface class AuthSessionStore {
  Future<StoredAuthSession?> read();

  Future<void> write(StoredAuthSession session);

  Future<void> clear();
}

class SecureAuthSessionStore implements AuthSessionStore {
  SecureAuthSessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _sessionKey = 'hyway.auth.session.v1';

  final FlutterSecureStorage _storage;

  @override
  Future<StoredAuthSession?> read() async {
    final raw = await _storage.read(key: _sessionKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      return StoredAuthSession.fromJson(decoded);
    } on FormatException {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(StoredAuthSession session) =>
      _storage.write(key: _sessionKey, value: jsonEncode(session.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _sessionKey);
}
