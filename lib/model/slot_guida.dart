import 'package:cloud_firestore/cloud_firestore.dart';

//Classe che rappresenta una singola disponibilità (slot) per una lezione di guida pratica
class SlotGuida {

  String idGuida;
  DateTime data;
  String oraInizio;
  String oraFine;
  String istruttore;
  String categoriaPatente;
  String? utentePrenotato;

  SlotGuida(
    this.idGuida,
    this.data,
    this.oraInizio,
    this.oraFine,
    this.istruttore,
    this.categoriaPatente,
    this.utentePrenotato,
  );

  //trasforma il documento prelevato da Firestore in un'istanza della classe SlotGuida
  factory SlotGuida.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return SlotGuida(
      snapshot.id,
      //Conversione della data da Timestamp (Firebase) a DateTime (Dart)
      (data?['data'] as Timestamp).toDate(),
      data?['oraInizio'] ?? '',
      data?['oraFine'] ?? '',
      data?['istruttore'] ?? '',
      data?['categoriaPatente'] ?? '',
      data?['utentePrenotato'],
    );
  }

  //mappa i campi dell'oggetto per permettere l'aggiornamento o il salvataggio sul database
  Map<String, dynamic> toFirestore() {
    return {
      "data": Timestamp.fromDate(data),
      "oraInizio": oraInizio,
      "oraFine": oraFine,
      "istruttore": istruttore,
      "categoriaPatente": categoriaPatente,
      "utentePrenotato": utentePrenotato,
    };
  }
}
