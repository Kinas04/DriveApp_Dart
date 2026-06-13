import 'package:cloud_firestore/cloud_firestore.dart';


class PrenotazioneEsame {

  String idEsame;
  String codiceFiscale;

  PrenotazioneEsame(
    this.idEsame,
    this.codiceFiscale,
  );

  factory PrenotazioneEsame.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return PrenotazioneEsame(
      data?['idEsame'] ?? '',
      data?['codiceFiscale'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "idEsame": idEsame,
      "codiceFiscale": codiceFiscale,
    };
  }
}