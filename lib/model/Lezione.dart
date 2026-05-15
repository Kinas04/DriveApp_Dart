import 'package:cloud_firestore/cloud_firestore.dart';


class Lezione {

  String idLezione;
  DateTime dataLezione;
  String oraInizio;
  String oraFine;
  String aula;
  String argomento;

  Lezione({
    required this.idLezione,
    required this.dataLezione,
    required this.oraInizio,
    required this.oraFine,
    required this.aula,
    required this.argomento,
  });

  factory Lezione.fromMap(Map<String, dynamic> map, String id) {
    return Lezione(
      idLezione: id,
      dataLezione: (map['dataLezione'] as Timestamp).toDate(),
      oraInizio: map['oraInizio'] ?? '',
      oraFine: map['oraFine'] ?? '',
      aula: map['aula'] ?? '',
      argomento: map['argomento'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dataLezione': dataLezione,
      'oraInizio': oraInizio,
      'oraFine': oraFine,
      'aula': aula,
      'argomento': argomento,
    };
  }
}

