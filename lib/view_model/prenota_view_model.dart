import 'package:flutter/material.dart';
import '../model/esame.dart';
import '../model/slot_guida.dart';
import '../repository/repository_interface.dart';

//ViewModel dedicato alla gestione delle prenotazioni di esami e guide da parte dell'utente
class PrenotaViewModel extends ChangeNotifier {
  //Dipendenza dalla repository per le operazioni di lettura e scrittura su Firestore
  final RepositoryInterface repository;

  PrenotaViewModel({required this.repository});

  //recupera la lista degli elementi (esami o guide) che l'utente può visualizzare e prenotare
  Future<void> caricaElementiPrenotabili(
      String categoria, 
      String cf, 
      int tab, 
      Function(List<Esame>, List<SlotGuida>, Set<String>, bool) onRisultato
  ) async {
    try {
      final adesso = DateTime.now();
      //Tab 0: Gestione Esami
      if (tab == 0) {
        //Recupero tutti gli esami futuri per la categoria dell'utente
        final esami = await repository.getEsamiFuturi(categoria, adesso);
        //Ottengo l'elenco di quelli già prenotati per evidenziarli nella UI
        final prenotati = await repository.getPrenotazioniEsamiUtente(cf);
        onRisultato(esami, [], prenotati.toSet(), false);
      } 
      //Tab 1: Gestione Guide
      else {
        //Recupero tutti gli slot guida futuri filtrati per categoria
        final tutteLeGuide = await repository.getGuideFuture(categoria, adesso);
        //Filtro per mostrare solo le guide libere o quelle già prenotate dall'utente loggato
        final guideVisibili = tutteLeGuide.where((g) =>
          g.utentePrenotato == null || g.utentePrenotato == cf
        ).toList();
        //Identifico quali di queste guide sono già state prenotate dall'utente
        final prenotati = guideVisibili
            .where((g) => g.utentePrenotato == cf)
            .map((g) => g.idGuida)
            .toSet();
        onRisultato([], guideVisibili, prenotati, false);
      }
    } catch (e) {
      //In caso di fail, restituisco dati vuoti e attivo il flag di errore per la UI
      onRisultato([], [], {}, true);
    }
  }

  //salva la prenotazione per un esame o una guida specifica dell'utente loggato
  Future<void> prenotaElemento(int tab, String id, String cf, Function(bool, String) onRisultato) async {
    try {
      if (tab == 0) {
        //Richiamo la funzione prenotaEsame per aggiungere il record nella collezione dedicata
        await repository.prenotaEsame(id, cf);
      } else {
        //Aggiorno lo slot guida associandogli il codice fiscale dell'utente
        await repository.prenotaGuida(id, cf);
      }
      onRisultato(true, "Prenotazione effettuata con successo");
    } catch (e) {
      onRisultato(false, "Errore durante la procedura di prenotazione");
    }
  }

  //annulla una prenotazione esistente restituendo l'elemento allo stato disponibile
  Future<void> annullaPrenotazione(int tab, String id, String cf, Function(bool, String) onRisultato) async {
    try {
      if (tab == 0) {
        //Rimuovo il record della prenotazione dell'esame dal database
        await repository.annullaEsame(id, cf);
      } else {
        //Libero lo slot della guida impostando l'utente prenotato a null
        await repository.annullaGuida(id);
      }
      onRisultato(true, "Prenotazione annullata correttamente");
    } catch (e) {
      onRisultato(false, "Errore durante l'annullamento della prenotazione");
    }
  }
}
