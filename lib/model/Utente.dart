import 'package:cloud_firestore/cloud_firestore.dart';


class Utente {
  String nome;
  String cognome;
  int eta;
  String codiceFiscale;
  String password;
  String categoriaRichiesta;

  Utente(
    this.nome,
    this.cognome,
    this.eta,
    this.codiceFiscale,
    this.password,
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
      data?['password'] ?? '',
      data?['categoriaRichiesta'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "nome": nome,
      "cognome": cognome,
      "eta": eta,
      "codiceFiscale": codiceFiscale,
      "password": password,
      "categoriaRichiesta": categoriaRichiesta,
    };
  }
}