import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String isLogin = "isLogin";
  static const String isToken = "isToken";
  static const String userName = "userName";

  //Save data login pada saat login
  static saveLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(isLogin, value);
  }

  static saveToken(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(isToken, value);
  }

  //Ambil data login pada saat mau login / ke dashboard
  static getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLogin);
  }

  static getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(isToken);
  }

  //Hapus data login pada saat logout
  static removeLogin() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(isLogin);
  }

  static saveName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(userName, value);
  }

  static getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userName);
  }
}
