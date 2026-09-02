// 登录态和启动配置的本地缓存。
// 这里只负责存取，不承载业务逻辑判断。
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 基于 `SharedPreferences` 的轻量会话存储。
class SessionStore {
  SessionStore._(this._preferences);

  static const String _tokenKey = 'session.token';
  static const String _launchSessionKey = 'session.launch';
  static const String _userProfileKey = 'session.user';
  static const String _baseUrlKey = 'settings.base_url';
  static const String _initialFlowCompletedKey = 'app.initial_flow_completed';
  static const String _startupAgreementAcceptedKey =
      'app.startup_agreement_accepted';
  static const String _defaultBaseUrl = 'https://chatest.beiyinapp.com/';

  final SharedPreferences _preferences;

  static Future<SessionStore> create() async {
    final preferences = await SharedPreferences.getInstance();
    return SessionStore._(preferences);
  }

  String get token => _preferences.getString(_tokenKey) ?? '';
  String get baseUrl => _preferences.getString(_baseUrlKey) ?? _defaultBaseUrl;
  String? get launchSessionJson => _preferences.getString(_launchSessionKey);
  String? get userProfileJson => _preferences.getString(_userProfileKey);
  bool get initialFlowCompleted =>
      _preferences.getBool(_initialFlowCompletedKey) ?? false;
  bool get startupAgreementAccepted =>
      _preferences.getBool(_startupAgreementAcceptedKey) ?? false;

  Future<void> saveToken(String value) async {
    await _preferences.setString(_tokenKey, value);
  }

  Future<void> saveBaseUrl(String value) async {
    await _preferences.setString(_baseUrlKey, value.trim());
  }

  Future<void> saveInitialFlowCompleted(bool value) async {
    await _preferences.setBool(_initialFlowCompletedKey, value);
  }

  Future<void> saveStartupAgreementAccepted(bool value) async {
    await _preferences.setBool(_startupAgreementAcceptedKey, value);
  }

  Future<void> saveLaunchSession(Map<String, dynamic> value) async {
    await _preferences.setString(_launchSessionKey, jsonEncode(value));
  }

  Future<void> saveUserProfile(Map<String, dynamic> value) async {
    await _preferences.setString(_userProfileKey, jsonEncode(value));
  }

  Future<void> clearUserProfile() async {
    await _preferences.remove(_userProfileKey);
  }

  Future<void> clearLaunchSession() async {
    await _preferences.remove(_launchSessionKey);
  }

  Future<void> clearSession() async {
    await _preferences.remove(_tokenKey);
    await _preferences.remove(_launchSessionKey);
    await _preferences.remove(_userProfileKey);
  }
}
