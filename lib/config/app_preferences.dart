import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static SharedPreferences _preferences;

  static initPreferences() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static SharedPreferences get preferences => _preferences;
}
