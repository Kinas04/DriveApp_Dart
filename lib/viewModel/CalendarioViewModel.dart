import 'package:flutter/material.dart';
import '../model/Lezione.dart';
import '../model/Esame.dart';
import '../model/SlotGuida.dart';
import '../repository/RepositoryInterface.dart';

class CalendarioViewModel extends ChangeNotifier {
  final RepositoryInterface repository;

  CalendarioViewModel({required this.repository});

  //carica le lezioni, gli esami o le guide in base alla data e al tab selezionato
  Future<void> caricaEventiCalendario(
      DateTime data,
      int tab,
      Function(List<Lezione>, List<Esame>, List<SlotGuida>, bool) onRisultato
  ) async {
    try {
      final inizio = DateTime(data.year, data.month, data.day);
      //Arrivo con add e Duration alla mezzanotte del giorno successivo
      //es da 4 giugno 00:00 a 5 giugno 00:00
      final fine = inizio.add(const Duration(days: 1));

      //Prelevo le info necessarie dai vari getter
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
      //restituisco nulla se false
      onRisultato([], [], [], true);
    }
  }
}
