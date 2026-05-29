import 'package:cloud_firestore/cloud_firestore.dart';

class EsitoEsame {

  String idEsame;
  String codiceFiscale;
  String esito;

  EsitoEsame(
    this.idEsame,
    this.codiceFiscale,
    this.esito,
  );

  factory EsitoEsame.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return EsitoEsame(
      snapshot.id,
      data?['codiceFiscale'] ?? '',
      data?['esito'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "codiceFiscale": codiceFiscale,
      "esito": esito,
    };
  }

}