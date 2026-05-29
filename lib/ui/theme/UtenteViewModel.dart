import 'package:flutter/material.dart';
import '../../model/Utente.dart';
import '../../model/Lezione.dart';
import '../../model/Esame.dart';
import '../../model/SlotGuida.dart';
import '../../model/EsitoEsame.dart';
import '../../repository/RepositoryInterface.dart';
import '../../repository/ConnectivityChecker.dart';
import '../../data/PreferenzeUtente.dart';

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

  //blocco eseguito automaticamente al lancio per recuperare l'utente loggato
  Future<void> _inizializza() async {
    final cfSalvato = await userPrefs.getUtenteLoggato();
    if (cfSalvato != null) {
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
    required String etaString,
    required String categoria,
    required Function(bool, String) onRisultato,
  }) async {
    if (nome.isEmpty || cognome.isEmpty || etaString.isEmpty || cf.isEmpty || password.isEmpty || categoria.isEmpty) {
      onRisultato(false, "Compila tutti i campi");
      return;
    }

    final validation = validaDatiRegistrazione(nome, cognome, cf, password, etaString, categoria);
    if (!validation.item1) {
      onRisultato(false, validation.item2);
      return;
    }

    final nuovoUtente = Utente(
      nome.trim(),
      cognome.trim(),
      int.tryParse(etaString) ?? 0,
      cf.trim().toUpperCase(),
      password,
      categoria,
    );

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
      final utente = await repository.getUtente(cf);
      _utenteLoggato = utente;
    } catch (e) {
      _utenteLoggato = null;
    } finally {
      _caricamentoIniziale = false;
      notifyListeners();
    }
  }

  //effettua il logout eliminando la sessione corrente
  void logout() async {
    _utenteLoggato = null;
    await userPrefs.logout();
    await repository.signOut();
    notifyListeners();
  }

  //carica le lezioni, gli esami o le guide in base alla data e al tab selezionato
  Future<void> caricaEventiCalendario(
      DateTime data,
      int tab,
      Function(List<Lezione>, List<Esame>, List<SlotGuida>, bool) onRisultato
  ) async {
    try {
      final inizio = DateTime(data.year, data.month, data.day);
      final fine = inizio.add(const Duration(days: 1));
      
      if (tab == 0) {
        final lezioni = await repository.getLezioni(inizio, fine);
        onRisultato(lezioni, [], [], false);
      } else if (tab == 1) {
        final esami = await repository.getEsami(inizio, fine);
        onRisultato([], esami, [], false);
      } else {
        final guide = await repository.getGuide(inizio, fine);
        onRisultato([], [], guide, false);
      }
    } catch (e) {
      onRisultato([], [], [], true);
    }
  }

  //recupera tutti gli esiti degli esami sostenuti dall'utente loggato
  Future<void> caricaEsiti(Function(List<EsitoEsame>, Map<String, Esame>, bool) onRisultato) async {
    if (_utenteLoggato == null) return;
    try {
      final esiti = await repository.getEsiti(_utenteLoggato!.codiceFiscale);
      final ids = esiti.map((e) => e.idEsame).toList();
      final dettagli = await repository.getEsamiPerId(ids);
      final mappaDettagli = { for (var e in dettagli) e.idEsame : e };
      onRisultato(esiti, mappaDettagli, false);
    } catch (e) {
      onRisultato([], {}, true);
    }
  }

  //recupera la lista degli elementi che l'utente può ancora prenotare dal sistema
  Future<void> caricaElementiPrenotabili(int tab, Function(List<Esame>, List<SlotGuida>, Set<String>, bool) onRisultato) async {
    if (_utenteLoggato == null) return;
    try {
      final adesso = DateTime.now();
      if (tab == 0) {
        final esami = await repository.getEsamiFuturi(_utenteLoggato!.categoriaRichiesta, adesso);
        final prenotati = await repository.getPrenotazioniEsamiUtente(_utenteLoggato!.codiceFiscale);
        onRisultato(esami, [], prenotati.toSet(), false);
      } else {
        final guide = await repository.getGuideFuture(_utenteLoggato!.categoriaRichiesta, adesso);
        final prenotati = guide.where((g) => g.utentePrenotato == _utenteLoggato!.codiceFiscale).map((g) => g.idGuida).toSet();
        onRisultato([], guide, prenotati, false);
      }
    } catch (e) {
      onRisultato([], [], {}, true);
    }
  }

  //salva la prenotazione per un esame o una guida specifica dell'utente
  Future<void> prenotaElemento(int tab, String id, Function(bool, String) onRisultato) async {
    if (_utenteLoggato == null) return;
    try {
      if (tab == 0) {
        await repository.prenotaEsame(id, _utenteLoggato!.codiceFiscale);
      } else {
        await repository.prenotaGuida(id, _utenteLoggato!.codiceFiscale);
      }
      onRisultato(true, "Prenotazione effettuata");
    } catch (e) {
      onRisultato(false, "Errore durante la prenotazione");
    }
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
  Tuple2<bool, String> validaDatiRegistrazione(
    String nome,
    String cognome,
    String cf,
    String password,
    String etaString,
    String categoria,
  ) {
    final regexNomeCognome = RegExp(r"^[a-zA-ZÀ-ÿ\s']+$");
    if (!regexNomeCognome.hasMatch(nome)) return const Tuple2(false, "Nome non valido");
    if (!regexNomeCognome.hasMatch(cognome)) return const Tuple2(false, "Cognome non valido");

    final regexCF = RegExp(r"^[A-Z]{6}\d{2}[A-Z]\d{2}[A-Z]\d{3}[A-Z]$");
    if (!regexCF.hasMatch(cf.toUpperCase())) return const Tuple2(false, "Codice Fiscale non valido");

    if (password.length < 6) return const Tuple2(false, "Password troppo corta (min 6)");

    final eta = int.tryParse(etaString) ?? 0;
    int etaMinima = 18;
    //utilizzo uno switch case per includere tutte le categorie di patente ministeriali
    switch (categoria) {
      case "AM": etaMinima = 14; break;
      case "A1": case "B1": etaMinima = 16; break;
      case "A2": case "B": case "B96": case "BE": case "C1": case "C1E": etaMinima = 18; break;
      case "C": case "CE": case "D1": case "D1E": etaMinima = 21; break;
      case "A": case "D": case "DE": etaMinima = 24; break;
    }

    if (eta < etaMinima) return Tuple2(false, "Età minima per $categoria è $etaMinima");

    return const Tuple2(true, "");
  }
}

class Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;
  const Tuple2(this.item1, this.item2);
}
