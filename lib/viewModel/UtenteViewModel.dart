import 'package:flutter/material.dart';
import '../model/Utente.dart';
import '../repository/RepositoryInterface.dart';
import '../repository/ConnectivityChecker.dart';
import '../data/PreferenzeUtente.dart';

class UtenteViewModel extends ChangeNotifier {
  //richiamo dalla repository le interfacce e il check per la connessione
  final RepositoryInterface repository;
  final PreferencesRepository userPrefs;
  final ConnectivityChecker networkChecker;

  UtenteViewModel({
    required this.repository,
    required this.userPrefs,
    required this.networkChecker,
  }) {
    _inizializza();
  }

  bool _caricamentoIniziale = true;
  bool get caricamentoIniziale => _caricamentoIniziale;

  Utente? _utenteLoggato;
  Utente? get utenteLoggato => _utenteLoggato;

  bool _erroreConnessione = false;
  bool get erroreConnessione => _erroreConnessione;

  //blocco eseguito automaticamente al lancio per recuperare l'utente loggato
  Future<void> _inizializza() async {
    final cfSalvato = await userPrefs.getUtenteLoggato();
    if (cfSalvato != null) {
      //Verifico la connessione prima di provare a recuperare i dati da Firebase
      if (!await networkChecker.isInternetAvailable()) {
        _erroreConnessione = true;
        _caricamentoIniziale = false;
        notifyListeners();
        return;
      }
      await recuperaDatiUtenteDaFirebase(cfSalvato);
    } else {
      _caricamentoIniziale = false;
      notifyListeners();
    }
  }

  //forza la scrittura in upper case del codice fiscale
  String formattaCodiceFiscale(String input) {
    return input.replaceAll(RegExp(r'[\n\t\r\s]'), '').toUpperCase();
  }

  //pulisce la password da caratteri strani
  String formattaPassword(String input) {
    return input.replaceAll(RegExp(r'[\n\t\r]'), '');
  }

  //rende maiuscola la prima lettera di ogni parola nel nome
  String formattaNome(String testo) {
    if (testo.isEmpty) return "";
    return testo.split(" ").map((parola) {
      if (parola.isEmpty) return "";
      return parola[0].toUpperCase() + parola.substring(1).toLowerCase();
    }).join(" ");
  }

  //gestisce la procedura di login verificando le credenziali su Firebase
  Future<void> eseguiLogin(String cfInserito, String passwordInserita, Function(bool, String) onRisultato) async {
    //Verifico subito se c'è connessione ad internet
    if (!await networkChecker.isInternetAvailable()) {
      onRisultato(false, "Connessione assente. Impossibile accedere.");
      return;
    }

    if (cfInserito.trim().isEmpty || passwordInserita.trim().isEmpty) {
      onRisultato(false, "Campi vuoti");
      return;
    }

    try {
      final utente = await repository.eseguiLogin(cfInserito.trim(), passwordInserita.trim());
      if (utente != null) {
        _utenteLoggato = utente;
        await userPrefs.salvaUtenteLoggato(cfInserito.trim());
        notifyListeners();
        onRisultato(true, "Login eseguito con successo");
      } else {
        onRisultato(false, "Utente non trovato");
      }
    } catch (e) {
      onRisultato(false, "Password errata o errore connessione");
    }
  }

  //procedura di registrazione con salvataggio dati su Firestore e Auth
  Future<void> avviaRegistrazione({
    required String nome,
    required String cognome,
    required String cf,
    required String password,
    required String eta,
    required String categoria,
    required Function(bool, String) onRisultato,
  }) async {
    //Controllo la connessione anche in fase di registrazione per garantire l'allineamento dei dati
    if (!await networkChecker.isInternetAvailable()) {
      onRisultato(false, "Connessione assente. Registrazione non possibile.");
      return;
    }

    if (nome.isEmpty || cognome.isEmpty || eta.isEmpty || cf.isEmpty || password.isEmpty || categoria.isEmpty) {
      onRisultato(false, "Compila tutti i campi");
      return;
    }

    final validation = validaDatiRegistrazione(nome, cognome, cf, password, eta, categoria);
    if (!validation.item1) { //è boolean, quini se non true
      //Invio alla UI il segnale di fail e il motivo grazie a item2 (String)
      onRisultato(false, validation.item2);
      return;
    }

    final nuovoUtente = Utente(
      nome.trim(),
      cognome.trim(),
      int.tryParse(eta) ?? 0,
      cf.trim().toUpperCase(),
      categoria,
    );

    //Chiamo la funzione registraUtente dal repository per salvare la registrazione su Firebase
    try {
      await repository.registraUtente(nuovoUtente, password);
      _utenteLoggato = nuovoUtente;
      await userPrefs.salvaUtenteLoggato(nuovoUtente.codiceFiscale);
      notifyListeners();
      onRisultato(true, "Registrazione completata");
    } catch (e) {
      onRisultato(false, "Errore registrazione: ${e.toString()}");
    }
  }

  //recupera i dati completi dell'utente una volta loggato
  Future<void> recuperaDatiUtenteDaFirebase(String cf) async {
    try {
      _erroreConnessione = false;
      final utente = await repository.getUtente(cf);
      _utenteLoggato = utente;
    } catch (e) {
      _utenteLoggato = null;
    } finally {
      _caricamentoIniziale = false;
      notifyListeners();
    }
  }

  //Permette di riprovare il caricamento iniziale se era fallito per mancanza di internet
  Future<void> riprovaConnessione() async {
    setStateCaricamento(true);
    await _inizializza();
  }

  //metodo di utilità per settare il caricamento
  void setStateCaricamento(bool valore) {
    _caricamentoIniziale = valore;
    _erroreConnessione = false;
    notifyListeners();
  }

  //effettua il logout eliminando la sessione corrente
  Future<void> logout() async {
    _utenteLoggato = null;
    await userPrefs.logout();
    await repository.signOut();
    notifyListeners();
  }

  //procedura per cambiare la password verificando prima quella attualmente in uso
  Future<void> avviaCambioPassword(String vecchiaPassword, String nuovaPassword, Function(bool, String) onRisultato) async {
    final cf = _utenteLoggato?.codiceFiscale;
    if (cf == null) return;

    if (vecchiaPassword.trim().isEmpty || nuovaPassword.trim().isEmpty) {
      onRisultato(false, "Campi vuoti");
      return;
    }

    if (vecchiaPassword == nuovaPassword) {
      onRisultato(false, "Le password sono uguali");
      return;
    }

    try {
      final check = await repository.eseguiLogin(cf, vecchiaPassword);
      if (check != null) {
        await repository.cambiaPassword(nuovaPassword);
        onRisultato(true, "Password cambiata con successo");
      } else {
        onRisultato(false, "Vecchia password errata");
      }
    } catch (e) {
      onRisultato(false, "Errore durante il cambio password");
    }
  }

  //elimina definitivamente l'account e tutti i dati correlati presenti nel database
  Future<void> eliminaAccount(Function(bool, String) onRisultato) async {
    final cf = _utenteLoggato?.codiceFiscale;
    if (cf == null) return;

    try {
      await repository.eliminaUtente(cf);
      logout();
      onRisultato(true, "Account eliminato");
    } catch (e) {
      onRisultato(false, "Errore eliminazione account");
    }
  }

  //effettua la validazione dei dati inseriti in fase di registrazione iniziale
  Oggetti2<bool, String> validaDatiRegistrazione(
    String nome,
    String cognome,
    String cf,
    String password,
    String eta,
    String categoria,
  ) {
    final regexNomeCognome = RegExp(r"^[a-zA-ZÀ-ÿ\s']+$");
    if (!regexNomeCognome.hasMatch(nome)) return const Oggetti2(false, "Nome non valido");
    if (!regexNomeCognome.hasMatch(cognome)) return const Oggetti2(false, "Cognome non valido");

    final regexCF = RegExp(r"^[A-Z]{6}\d{2}[A-Z]\d{2}[A-Z]\d{3}[A-Z]$");
    if (!regexCF.hasMatch(cf.toUpperCase())) return const Oggetti2(false, "Codice Fiscale non valido");

    if (password.length < 6) return const Oggetti2(false, "Password troppo corta (min 6)");

    final etaVal = int.tryParse(eta) ?? 0;
    int etaMinima = 18;
    //utilizzo uno switch case per includere tutte le categorie di patente ministeriali
    switch (categoria) {
      case "AM": etaMinima = 14; break;
      case "A1": case "B1": etaMinima = 16; break;
      case "A2": case "B": case "B96": case "BE": case "C1": case "C1E": etaMinima = 18; break;
      case "C": case "CE": case "D1": case "D1E": etaMinima = 21; break;
      case "A": case "D": case "DE": etaMinima = 24; break;
    }

    if (etaVal < etaMinima) return Oggetti2(false, "Età minima per $categoria è $etaMinima");

    return const Oggetti2(true, "");
  }
}

class Oggetti2<T1, T2> {
  final T1 item1;
  final T2 item2;
  const Oggetti2(this.item1, this.item2);
}
