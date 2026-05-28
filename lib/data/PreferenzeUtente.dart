import 'package:shared_preferences/shared_preferences.dart';

class PreferencesRepository {

  static const String
  userKey =
      "utente_loggato";

  Future<void>
  salvaUtenteLoggato(
      String codiceFiscale)
  async {

    final prefs =
    await SharedPreferences
        .getInstance();

    await prefs.setString(
      userKey,
      codiceFiscale,
    );
  }

  Future<String?>
  getUtenteLoggato()
  async {

    final prefs =
    await SharedPreferences
        .getInstance();

    return prefs.getString(
      userKey,
    );
  }

  Future<void> logout()
  async {

    final prefs =
    await SharedPreferences
        .getInstance();

    await prefs.remove(
      userKey,
    );
  }
}
