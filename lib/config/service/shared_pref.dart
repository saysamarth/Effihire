import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static SharedPreferences? _prefs;

  // Keys for different stored values
  static const String _keyUserUid = 'user_uid';
  static const String _keyRegistrationStatus = 'registration_status';
  static const String _keyUserName = 'user_name';
  static const String _keyReferralCode = 'referral_code';

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Private method to ensure prefs is initialized
  static SharedPreferences get _instance {
    if (_prefs == null) {
      throw Exception('SharedPrefsService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // ==================== USER UID ====================

  static Future<void> setUserUid(String uid) async {
    await _instance.setString(_keyUserUid, uid);
  }

  static String? getUserUid() {
    return _instance.getString(_keyUserUid);
  }

  static Future<void> clearUserUid() async {
    await _instance.remove(_keyUserUid);
  }

  // ==================== REGISTRATION STATUS ====================

  static Future<void> setRegistrationStatus(int status) async {
    await _instance.setInt(_keyRegistrationStatus, status);
  }

  static int getRegistrationStatus() {
    return _instance.getInt(_keyRegistrationStatus) ?? 0;
  }

  static Future<void> clearRegistrationStatus() async {
    await _instance.remove(_keyRegistrationStatus);
  }

  // ==================== USER NAME ====================

  static Future<void> setUserName(String name) async {
    await _instance.setString(_keyUserName, name);
  }

  static String? getUserName() {
    return _instance.getString(_keyUserName);
  }

  static Future<void> clearUserName() async {
    await _instance.remove(_keyUserName);
  }

  // ==================== Refferal Code ====================

  static Future<void> setReferralCode(String code) async {
    await _instance.setString(_keyReferralCode, code);
  }

  static String? getReferralCode() {
    return _instance.getString(_keyReferralCode);
  }

  static Future<void> clearReferralCode() async {
    await _instance.remove(_keyReferralCode);
  }

  // Clear all user data (logout)
  static Future<void> clearAllUserData() async {
    await Future.wait([
      clearUserUid(),
      clearRegistrationStatus(),
      clearUserName(),
      clearReferralCode(),
    ]);
  }

  // Debug method to print all stored values
  static void debugPrintAllData() {
    print('=== SharedPrefs Debug Info ===');
    print('User UID: ${getUserUid()}');
    print('Registration Status: ${getRegistrationStatus()}');
    print('User Name: ${getUserName()}');
    print('Referral Code: ${getReferralCode()}');
    print('==============================');
  }
}
