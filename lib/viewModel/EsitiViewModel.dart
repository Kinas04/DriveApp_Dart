import 'package:flutter/material.dart';
import '../model/EsitoEsame.dart';
import '../model/Esame.dart';
import '../repository/RepositoryInterface.dart';

class EsitiViewModel extends ChangeNotifier {
  final RepositoryInterface repository;

  EsitiViewModel({required this.repository});

  //recupera tutti gli esiti degli esami sostenuti dall'utente loggato
  Future<void> caricaEsiti(String cf, Function(List<EsitoEsame>, Map<String, Esame>, bool) onRisultato) async {
    try {
      final esiti = await repository.getEsiti(cf);
      final ids = esiti.map((e) => e.idEsame).toList();
      final dettagli = await repository.getEsamiPerId(ids);
      final mappaDettagli = { for (var e in dettagli) e.idEsame : e };
      onRisultato(esiti, mappaDettagli, false);
    } catch (e) {
      onRisultato([], {}, true);
    }
  }
}
