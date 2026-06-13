import 'package:cloud_firestore/cloud_firestore.dart';

//Classe che modella l'esito finale di un esame sostenuto dall'utente (es. Idoneo/Respinto)
class EsitoEsame {

  String idEsame;
  String codiceFiscale;
  String esito;

  EsitoEsame(
    this.idEsame,
    this.codiceFiscale,
    this.esito,
  );

  //mappa i dati grezzi di Firestore in un oggetto EsitoEsame
  factory EsitoEsame.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return EsitoEsame(
      data?['idEsame'] ?? '',
      data?['codiceFiscale'] ?? '',
      data?['esito'] ?? '',
    );
  }

  //restituisce una mappa dell'oggetto per l'eventuale salvataggio su database
  Map<String, dynamic> toFirestore() {
    return {
      "idEsame": idEsame,
      "codiceFiscale": codiceFiscale,
      "esito": esito,
    };
  }

}
