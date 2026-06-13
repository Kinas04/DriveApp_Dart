import 'package:cloud_firestore/cloud_firestore.dart';


class Utente {
  String nome;
  String cognome;
  int eta;
  String codiceFiscale;
  String categoriaRichiesta;

  Utente(
    this.nome,
    this.cognome,
    this.eta,
    this.codiceFiscale,
    this.categoriaRichiesta,
  );

  factory Utente.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Utente(
      data?['nome'] ?? '',
      data?['cognome'] ?? '',
      data?['eta'] ?? 0,
      data?['codiceFiscale'] ?? '',
      data?['categoriaRichiesta'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "nome": nome,
      "cognome": cognome,
      "eta": eta,
      "codiceFiscale": codiceFiscale,
      "categoriaRichiesta": categoriaRichiesta,
    };
  }
}