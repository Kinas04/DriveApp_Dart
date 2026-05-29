import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory SlotGuida.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return SlotGuida(
      snapshot.id,
      (data?['data'] as Timestamp).toDate(),
      data?['oraInizio'] ?? '',
      data?['oraFine'] ?? '',
      data?['istruttore'] ?? '',
      data?['categoriaPatente'] ?? '',
      data?['utentePrenotato'],
    );
  }

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