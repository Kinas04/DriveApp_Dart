import 'package:flutter/material.dart';
import '../model/Esame.dart';
import '../model/SlotGuida.dart';
import '../repository/RepositoryInterface.dart';

class PrenotaViewModel extends ChangeNotifier {
  final RepositoryInterface repository;

  PrenotaViewModel({required this.repository});

  //recupera la lista degli elementi che l'utente può ancora prenotare dal sistema
  Future<void> caricaElementiPrenotabili(
      String categoria, 
      String cf, 
      int tab, 
      Function(List<Esame>, List<SlotGuida>, Set<String>, bool) onRisultato
  ) async {
    try {
      final adesso = DateTime.now();
      if (tab == 0) {
        final esami = await repository.getEsamiFuturi(categoria, adesso);
        final prenotati = await repository.getPrenotazioniEsamiUtente(cf);
        onRisultato(esami, [], prenotati.toSet(), false);
      } else {
        final tutteLeGuide = await repository.getGuideFuture(categoria, adesso);
        final guideVisibili = tutteLeGuide.where((g) =>
        g.utentePrenotato == null || g.utentePrenotato == cf
        ).toList();
        final prenotati = guideVisibili
            .where((g) => g.utentePrenotato == cf)
            .map((g) => g.idGuida)
            .toSet();
        onRisultato([], guideVisibili, prenotati, false);
      }
    } catch (e) {
      onRisultato([], [], {}, true);
    }
  }

  //salva la prenotazione per un esame o una guida specifica dell'utente
  Future<void> prenotaElemento(int tab, String id, String cf, Function(bool, String) onRisultato) async {
    try {
      if (tab == 0) {
        //Chiamo le funzioni prenotaEsame e prenotaGuida dalla repository per applicare il salvataggio
        await repository.prenotaEsame(id, cf);
      } else {
        await repository.prenotaGuida(id, cf);
      }
      onRisultato(true, "Prenotazione effettuata");
    } catch (e) {
      onRisultato(false, "Errore durante la prenotazione");
    }
  }

  //annulla la prenotazione per un esame o una guida specifica dell'utente
  Future<void> annullaPrenotazione(int tab, String id, String cf, Function(bool, String) onRisultato) async {
    try {
      if (tab == 0) {
        await repository.annullaEsame(id, cf);
      } else {
        await repository.annullaGuida(id);
      }
      onRisultato(true, "Prenotazione annullata");
    } catch (e) {
      onRisultato(false, "Errore durante l'annullamento");
    }
  }
}
