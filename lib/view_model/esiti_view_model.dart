import 'package:flutter/material.dart';
import '../model/esito_esame.dart';
import '../model/esame.dart';
import '../repository/repository_interface.dart';

//ViewModel responsabile della gestione e visualizzazione degli esiti degli esami sostenuti
class EsitiViewModel extends ChangeNotifier {
  //Dipendenza dalla repository per l'interazione con i dati su Firestore
  final RepositoryInterface repository;

  EsitiViewModel({required this.repository});

  //recupera lo storico degli esiti per l'utente loggato, inclusi i dettagli dell'esame correlato
  Future<void> caricaEsiti(String cf, Function(List<EsitoEsame>, Map<String, Esame>, bool) onRisultato) async {
    try {
      //preleva la lista degli esiti grezzi (ID esame, CF, risultato) dal database
      final esiti = await repository.getEsiti(cf);
      
      //estrae gli identificativi univoci degli esami per caricarne i dettagli (data, luogo, tipologia)
      final ids = esiti.map((e) => e.idEsame).toList();

      //se ci sono troppi esiti (oltre 10), mostriamo solo quelli grezzi per limitazioni del database
      if (ids.length > 10) {
        onRisultato(esiti, {}, false);
        return;
      }

      //recupera i dettagli completi degli esami coinvolti in un'unica chiamata
      final dettagli = await repository.getEsamiPerId(ids);
      
      //crea una mappa (ID -> Oggetto Esame) per associare velocemente ogni esito al suo esame corrispondente nella UI
      final mappaDettagli = { for (var e in dettagli) e.idEsame : e };
      
      //invia i dati processati alla schermata segnalando il successo del caricamento
      onRisultato(esiti, mappaDettagli, false);
    } catch (e) {
      //in caso di errore nel recupero, restituisce strutture vuote e notifica lo stato di errore alla UI
      onRisultato([], {}, true);
    }
  }
}
