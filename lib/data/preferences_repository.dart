import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/utente.dart';

//Classe dedicata alla gestione dei dati persistenti sul dispositivo (Memoria locale)
class PreferencesRepository {
  //Chiavi statiche per identificare i dati salvati
  static const String userKey = "utente_loggato";
  static const String userDataKey = "dati_utente";

  //salva il codice fiscale dell'utente per mantenere la sessione attiva al riavvio
  Future<void> salvaUtenteLoggato(String codiceFiscale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, codiceFiscale);
  }

  //salva l'intero oggetto utente in formato JSON per permettere la visualizzazione offline (RNF5)
  Future<void> salvaDatiUtente(Utente utente) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(utente.toMap());
    await prefs.setString(userDataKey, jsonString);
  }

  //recupera i dati dell'utente salvati localmente se presenti
  Future<Utente?> getDatiUtente() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(userDataKey);
    if (jsonString != null) {
      //Decodifico la stringa JSON per ricreare l'oggetto Utente
      return Utente.fromMap(jsonDecode(jsonString));
    }
    return null;
  }

  //restituisce il codice fiscale salvato dell'utente loggato
  Future<String?> getUtenteLoggato() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userKey);
  }

  //pulisce tutti i dati locali durante la procedura di logout o eliminazione account
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userKey);
    await prefs.remove(userDataKey);
  }
}
