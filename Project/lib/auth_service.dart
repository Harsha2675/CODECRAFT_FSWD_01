import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _usersKey = 'users';
  static const String _tokenKey = 'auth_token';

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<bool> register(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList(_usersKey) ?? [];
    
    if (users.any((user) => jsonDecode(user)['email'] == email)) {
      return false;
    }
    
    users.add(jsonEncode({
      'email': email,
      'password': _hashPassword(password),
    }));
    
    await prefs.setStringList(_usersKey, users);
    return true;
  }

  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList(_usersKey) ?? [];
    
    final hashedPassword = _hashPassword(password);
    final userExists = users.any((user) {
      final userData = jsonDecode(user);
      return userData['email'] == email && userData['password'] == hashedPassword;
    });
    
    if (userExists) {
      await prefs.setString(_tokenKey, email);
      return true;
    }
    return false;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}