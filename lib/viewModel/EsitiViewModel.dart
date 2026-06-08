import 'package:flutter/material.dart';
import '../model/EsitoEsame.dart';
import '../model/Esame.dart';
import '../repository/RepositoryInterface.dart';

class EsitiViewModel extends ChangeNotifier {
  final RepositoryInterface repository;

  EsitiViewModel({required this.repository});

  //recupera lo storico degli esiti per l'utente loggato
  Future<void> caricaEsiti(String cf, Function(List<EsitoEsame>, Map<String, Esame>, bool) onRisultato) async {
    try {
      //preleva la lista degli esiti dal repository
      final esiti = await repository.getEsiti(cf);
      //estrae gli id degli esami per caricarne i dettagli
      final ids = esiti.map((e) => e.idEsame).toList();

      final dettagli = await repository.getEsamiPerId(ids);
      //crea una mappa per associare esito e dettaglio dell'esito
      final mappaDettagli = { for (var e in dettagli) e.idEsame : e };
      //invia i dati alla schermata senza errori
      onRisultato(esiti, mappaDettagli, false);
    } catch (e) {
      //se fail, ci restituisce liste vuote
      onRisultato([], {}, true);
    }
  }
}
