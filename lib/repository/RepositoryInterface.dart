import '../model/Utente.dart';
import '../model/Lezione.dart';
import '../model/Esame.dart';
import '../model/SlotGuida.dart';
import '../model/EsitoEsame.dart';

abstract class RepositoryInterface {
  Future<Utente?> eseguiLogin(String codiceFiscale, String password);
  
  Future<void> registraUtente(Utente utente, String password);
  
  Future<Utente?> getUtente(String codiceFiscale);

  Future<List<Lezione>> getLezioni(DateTime inizio, DateTime fine);
  
  Future<List<Esame>> getEsami(DateTime inizio, DateTime fine);
  
  Future<List<SlotGuida>> getGuide(DateTime inizio, DateTime fine);

  Future<List<EsitoEsame>> getEsiti(String codiceFiscale);

  Future<List<Esame>> getEsamiPerId(List<String> ids);

  Future<List<Esame>> getEsamiFuturi(String categoria, DateTime data);

  Future<List<String>> getPrenotazioniEsamiUtente(String codiceFiscale);

  Future<List<SlotGuida>> getGuideFuture(String categoria, DateTime data);

  Future<void> prenotaEsame(String idEsame, String codiceFiscale);

  Future<void> prenotaGuida(String idGuida, String codiceFiscale);

  Future<void> cambiaPassword(String nuovaPassword);

  Future<void> eliminaUtente(String codiceFiscale);

  Future<void> signOut();
}
