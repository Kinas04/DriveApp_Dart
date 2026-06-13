import 'package:flutter/material.dart';
import '../model/lezione.dart';
import '../model/esame.dart';
import '../model/slot_guida.dart';
import '../repository/repository_interface.dart';

//ViewModel che gestisce la logica del calendario recuperando lezioni, esami e guide
class CalendarioViewModel extends ChangeNotifier {
  //Riferimento alla repository per l'accesso ai dati su Firebase
  final RepositoryInterface repository;

  CalendarioViewModel({required this.repository});

  //carica le lezioni, gli esami o le guide in base alla data e al tab selezionato nella UI
  Future<void> caricaEventiCalendario(
      DateTime data,
      int tab,
      Function(List<Lezione>, List<Esame>, List<SlotGuida>, bool) onRisultato
  ) async {
    try {
      //Definisco l'intervallo temporale per la query: dalla mezzanotte del giorno selezionato...
      final inizio = DateTime(data.year, data.month, data.day);
      //...fino alla mezzanotte del giorno successivo per coprire l'intera giornata
      final fine = inizio.add(const Duration(days: 1));

      //Prelevo le info necessarie dai vari getter della repository in base al tab (0:Lezioni, 1:Esami, 2:Guide)
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
      //In caso di errore durante il recupero, restituisco liste vuote e segnalo l'errore alla UI
      onRisultato([], [], [], true);
    }
  }
}
