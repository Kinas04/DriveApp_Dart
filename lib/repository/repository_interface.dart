import '../model/utente.dart';
import '../model/lezione.dart';
import '../model/esame.dart';
import '../model/slot_guida.dart';
import '../model/esito_esame.dart';

//Interfaccia che definisce il contratto per tutte le operazioni di recupero e salvataggio dati (Repository Pattern)
abstract class RepositoryInterface {
  //verifica le credenziali e restituisce l'utente se il login ha successo
  Future<Utente?> eseguiLogin(String codiceFiscale, String password);
  
  //crea un nuovo profilo utente sia su Firebase Authentication che su Firestore
  Future<void> registraUtente(Utente utente, String password);
  
  //preleva i dati anagrafici completi di un singolo utente dal database
  Future<Utente?> getUtente(String codiceFiscale);

  //restituisce la lista delle lezioni di teoria comprese in un intervallo di date
  Future<List<Lezione>> getLezioni(DateTime inizio, DateTime fine);
  
  //restituisce la lista degli appelli d'esame compresi in un intervallo di date
  Future<List<Esame>> getEsami(DateTime inizio, DateTime fine);
  
  //restituisce tutti gli slot guida disponibili (o già occupati) in un intervallo di date
  Future<List<SlotGuida>> getGuide(DateTime inizio, DateTime fine);

  //recupera lo storico degli esiti degli esami per uno specifico utente
  Future<List<EsitoEsame>> getEsiti(String codiceFiscale);

  //preleva una lista di esami filtrando per un elenco di identificativi univoci
  Future<List<Esame>> getEsamiPerId(List<String> ids);

  //filtra gli esami futuri in base alla categoria di patente richiesta
  Future<List<Esame>> getEsamiFuturi(String categoria, DateTime data);

  //ottiene gli ID degli esami per i quali l'utente ha già effettuato una prenotazione
  Future<List<String>> getPrenotazioniEsamiUtente(String codiceFiscale);

  //restituisce gli slot di guida futuri filtrati per la categoria di patente
  Future<List<SlotGuida>> getGuideFuture(String categoria, DateTime data);

  //salva una nuova prenotazione d'esame associando l'ID dell'esame al codice fiscale dell'utente
  Future<void> prenotaEsame(String idEsame, String codiceFiscale);

  //aggiorna uno slot di guida inserendo il codice fiscale dell'utente che lo ha prenotato
  Future<void> prenotaGuida(String idGuida, String codiceFiscale);

  //rimuove definitivamente la prenotazione di un esame dal database
  Future<void> annullaEsame(String idEsame, String codiceFiscale);

  //libera uno slot di guida precedentemente occupato impostando l'utente a null
  Future<void> annullaGuida(String idGuida);

  //permette l'aggiornamento della password per l'utente attualmente loggato
  Future<void> cambiaPassword(String nuovaPassword);

  //cancella l'utente e tutti i suoi dati correlati (esiti, prenotazioni) dal sistema
  Future<void> eliminaUtente(String codiceFiscale);

  //effettua la disconnessione della sessione corrente da Firebase Auth
  Future<void> signOut();
}
