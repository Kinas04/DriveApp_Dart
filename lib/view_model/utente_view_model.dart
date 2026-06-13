import 'dart:async';
import 'package:flutter/material.dart';
import '../model/utente.dart';
import '../repository/repository_interface.dart';
import '../repository/connectivity_checker.dart';
import '../data/preferences_repository.dart';

//ViewModel che gestisce lo stato dell'utente, l'autenticazione e la persistenza dei dati
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

  //indica se l'app sta ancora caricando i dati iniziali all'avvio
  bool _caricamentoIniziale = true;
  bool get caricamentoIniziale => _caricamentoIniziale;

  //contiene i dati dell'utente attualmente autenticato
  Utente? _utenteLoggato;
  Utente? get utenteLoggato => _utenteLoggato;

  //indica se c'è stato un errore di rete durante il caricamento critico
  bool _erroreConnessione = false;
  bool get erroreConnessione => _erroreConnessione;

  //blocco eseguito automaticamente al lancio per recuperare l'utente loggato e gestire la persistenza offline
  Future<void> _inizializza() async {
    final cfSalvato = await userPrefs.getUtenteLoggato();
    
    //Verifico se l'utente ha una sessione attiva sia localmente che su Firebase Auth
    if (cfSalvato != null && repository.isAutenticato()) {
      //Provo a recuperare i dati aggiornati da Firebase con logica di retry
      await _eseguiConRetry(() async {
        if (await networkChecker.isInternetAvailable()) {
          await recuperaDatiUtenteDaFirebase(cfSalvato);
        } else {
          //Se sono offline, carico i dati dalla memoria locale per rispettare il requisito RNF5
          final utenteLocale = await userPrefs.getDatiUtente();
          if (utenteLocale != null && utenteLocale.codiceFiscale == cfSalvato) {
            _utenteLoggato = utenteLocale;
            _caricamentoIniziale = false;
            notifyListeners();
          } else {
            throw Exception("Offline e nessuna cache disponibile");
          }
        }
      }, onFallimentoDefinitivo: () {
        _erroreConnessione = true;
        _caricamentoIniziale = false;
        notifyListeners();
      });
    } else {
      //Nessun utente salvato o sessione Firebase scaduta, vado direttamente al login
      _caricamentoIniziale = false;
      notifyListeners();
    }
  }

  //Logica di retry per operazioni critiche di rete
  Future<void> _eseguiConRetry(Future<void> Function() operazione, {required VoidCallback onFallimentoDefinitivo}) async {
    int tentativi = 0;
    const maxTentativi = 2; //Riprovo una volta dopo il primo fallimento
    
    while (tentativi < maxTentativi) {
      try {
        await operazione().timeout(const Duration(seconds: 8)); //Timeout di 8 secondi per singola richiesta
        return; //Successo
      } catch (e) {
        tentativi++;
        if (tentativi < maxTentativi) {
          //Attesa di 10 secondi prima del prossimo tentativo per permettere il ripristino del segnale
          await Future.delayed(const Duration(seconds: 10));
        }
      }
    }
    onFallimentoDefinitivo();
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

  //gestisce la procedura di login verificando le credenziali su Firebase e salvando i dati per l'offline
  Future<void> eseguiLogin(String cfInserito, String passwordInserita, Function(bool, String) onRisultato) async {
    //Validazione CF locale tramite regex prima di chiamare Firebase
    final regexCF = RegExp(r"^[A-Z]{6}\d{2}[A-Z]\d{2}[A-Z]\d{3}[A-Z]$");
    if (!regexCF.hasMatch(cfInserito.trim().toUpperCase())) {
      onRisultato(false, "Codice Fiscale non valido formalmente");
      return;
    }

    //Verifico subito se c'è connessione ad internet prima di procedere
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
        //Salvo sia la sessione che i dati dell'utente per la persistenza (RNF5)
        await userPrefs.salvaUtenteLoggato(cfInserito.trim());
        await userPrefs.salvaDatiUtente(utente); 
        notifyListeners();
        onRisultato(true, "Login eseguito con successo");
      } else {
        onRisultato(false, "Utente non trovato");
      }
    } catch (e) {
      onRisultato(false, "Password errata o errore connessione");
    }
  }

  //procedura di registrazione con salvataggio dati su Firestore e attivazione persistenza offline
  Future<void> avviaRegistrazione({
    required String nome,
    required String cognome,
    required String cf,
    required String password,
    required String eta,
    required String categoria,
    required Function(bool, String) onRisultato,
  }) async {
    //Controllo la connessione anche in fase di registrazione
    if (!await networkChecker.isInternetAvailable()) {
      onRisultato(false, "Connessione assente. Registrazione non possibile.");
      return;
    }

    if (nome.isEmpty || cognome.isEmpty || eta.isEmpty || cf.isEmpty || password.isEmpty || categoria.isEmpty) {
      onRisultato(false, "Compila tutti i campi");
      return;
    }

    //Validazione dei dati tramite Record di Dart
    final (bool successoValidazione, String msgValidazione) = validaDatiRegistrazione(nome, cognome, cf, password, eta, categoria);
    if (!successoValidazione) {
      onRisultato(false, msgValidazione);
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
      //Salvo i dati localmente per il funzionamento offline successivo
      await userPrefs.salvaUtenteLoggato(nuovoUtente.codiceFiscale);
      await userPrefs.salvaDatiUtente(nuovoUtente);
      notifyListeners();
      onRisultato(true, "Registrazione completata");
    } catch (e) {
      //Catturo il messaggio specifico se l'utente esiste già
      onRisultato(false, e.toString().replaceAll("Exception: ", ""));
    }
  }

  //recupera i dati completi dell'utente da Firebase e aggiorna la cache locale
  Future<void> recuperaDatiUtenteDaFirebase(String cf) async {
    try {
      _erroreConnessione = false;
      final utente = await repository.getUtente(cf);
      if (utente != null) {
        _utenteLoggato = utente;
        //Aggiorno la cache locale con i dati più recenti dal server (RNF5)
        await userPrefs.salvaDatiUtente(utente);
      }
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

  //metodo di utilità per gestire lo stato di caricamento e pulire errori precedenti
  void setStateCaricamento(bool valore) {
    _caricamentoIniziale = valore;
    _erroreConnessione = false;
    notifyListeners();
  }

  //effettua il logout eliminando la sessione corrente sia su Firebase che in locale
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

    //Controllo lunghezza minima password durante la fase di cambio
    if (nuovaPassword.length < 6) {
      onRisultato(false, "La nuova password deve essere di almeno 6 caratteri");
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

  //elimina definitivamente l'account e tutti i dati correlati, poi esegue il logout locale
  Future<void> eliminaAccount(Function(bool, String) onRisultato) async {
    final cf = _utenteLoggato?.codiceFiscale;
    if (cf == null) return;

    try {
      await repository.eliminaUtente(cf);
      await logout(); //Uso await per garantire la pulizia prima del risultato
      onRisultato(true, "Account eliminato");
    } catch (e) {
      onRisultato(false, "Errore eliminazione account");
    }
  }

  //effettua la validazione dei dati inseriti in fase di registrazione tramite Record
  (bool, String) validaDatiRegistrazione(
    String nome,
    String cognome,
    String cf,
    String password,
    String eta,
    String categoria,
  ) {
    final regexNomeCognome = RegExp(r"^[a-zA-ZÀ-ÿ\s']+$");
    if (!regexNomeCognome.hasMatch(nome)) return (false, "Nome non valido");
    if (!regexNomeCognome.hasMatch(cognome)) return (false, "Cognome non valido");

    final regexCF = RegExp(r"^[A-Z]{6}\d{2}[A-Z]\d{2}[A-Z]\d{3}[A-Z]$");
    if (!regexCF.hasMatch(cf.toUpperCase())) return (false, "Codice Fiscale non valido");

    if (password.length < 6) return (false, "Password troppo corta (min 6)");

    final etaVal = int.tryParse(eta) ?? 0;
    int etaMinima = 18;
    //utilizzo uno switch case per includere tutte le categorie di patente ministeriali e le età minime
    switch (categoria) {
      case "AM": etaMinima = 14; break;
      case "A1": case "B1": etaMinima = 16; break;
      case "A2": case "B": case "B96": case "BE": case "C1": case "C1E": etaMinima = 18; break;
      case "C": case "CE": case "D1": case "D1E": etaMinima = 21; break;
      case "A": case "D": case "DE": etaMinima = 24; break;
    }

    if (etaVal < etaMinima) return (false, "Età minima per $categoria è $etaMinima");

    return (true, "");
  }
}
