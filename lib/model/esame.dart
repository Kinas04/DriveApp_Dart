import 'package:cloud_firestore/cloud_firestore.dart';

//Classe che rappresenta un appello d'esame (teorico o pratico) nel sistema
class Esame {

  String idEsame;
  DateTime data;
  String oraInizio;
  String oraFine;
  String luogo;
  String categoriaPatente;
  String tipologia;

  Esame(
    this.idEsame,
    this.data,
    this.oraInizio,
    this.oraFine,
    this.luogo,
    this.categoriaPatente,
    this.tipologia,
  );

  //trasforma un documento Firestore in un oggetto Esame mappando i vari campi
  factory Esame.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Esame(
      snapshot.id,
      (data?['data'] as Timestamp).toDate(),
      data?['oraInizio'] ?? '',
      data?['oraFine'] ?? '',
      data?['luogo'] ?? '',
      data?['categoriaPatente'] ?? '',
      data?['tipologia'] ?? '',
    );
  }

  //converte l'oggetto Esame in una mappa compatibile con il salvataggio su Firestore
  Map<String, dynamic> toFirestore() {
    return {
      "data": Timestamp.fromDate(data),
      "oraInizio": oraInizio,
      "oraFine": oraFine,
      "luogo": luogo,
      "categoriaPatente": categoriaPatente,
      "tipologia": tipologia,
    };
  }

}
