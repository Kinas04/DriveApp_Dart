import 'package:cloud_firestore/cloud_firestore.dart';

//Classe che rappresenta una lezione di teoria programmata nell'autoscuola
class Lezione {

  String idLezione;
  DateTime dataLezione;
  String oraInizio;
  String oraFine;
  String aula;
  String argomento;

  Lezione(
    this.idLezione,
    this.dataLezione,
    this.oraInizio,
    this.oraFine,
    this.aula,
    this.argomento,
  );

  /*Per ogni classe, uso un metodo "factory" di Dart per convertire i campi
  provenienti dal DB Firebase in campi utilizzabili dal codice Dart*/
  factory Lezione.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    /*Facciamo riferimento ai dati mappati attraverso la variabile final data
    Viene catturato uno snapshot dei dati del documento*/
    final data = snapshot.data();
    return Lezione(
      snapshot.id,
      //Convertiamo il Timestamp di Firebase in un oggetto DateTime di Dart
      (data?['dataLezione'] as Timestamp).toDate(),
      data?['oraInizio'] ?? '',
      data?['oraFine'] ?? '',
      data?['aula'] ?? '',
      data?['argomento'] ?? '',
    );
  }

  /*Poi, quando devo fare scritture sul DB, poichè i dati su Firebase
  sono mappati (chiave,valore), rimappo nuovamente tutti parametri del costruttore
  con un metodo di tipo Map per l'invio al database*/
  Map<String, dynamic> toFirestore() {
    return {
      'dataLezione': Timestamp.fromDate(dataLezione),
      'oraInizio': oraInizio,
      'oraFine': oraFine,
      'aula': aula,
      'argomento': argomento,
    };
  }
}
