import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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

    // Controlliamo innanzitutto lo stato della connessione
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // Se non c'è connessione, restituiamo subito liste vuote e flag di errore a 'true'
      onRisultato([], [], [], true);
      return;
    }

    try {
      //Definizione dell'intervallo temporale per la query
      final inizio = DateTime(data.year, data.month, data.day);
      final fine = inizio.add(const Duration(days: 1));

      // info necessarie dai vari getter della repository in base al tab
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
      //In caso di errore durante il recupero restituisce liste vuote
      onRisultato([], [], [], true);
    }
  }
}