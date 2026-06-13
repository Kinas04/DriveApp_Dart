import 'package:cloud_firestore/cloud_firestore.dart';

//Classe che rappresenta l'utente del sistema con i suoi dati anagrafici e la patente richiesta
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

  //trasforma un documento proveniente da Firestore in un oggetto Utente
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

  //converte l'oggetto in una mappa per facilitare il salvataggio in locale o su JSON
  Map<String, dynamic> toMap() {
    return {
      "nome": nome,
      "cognome": cognome,
      "eta": eta,
      "codiceFiscale": codiceFiscale,
      "categoriaRichiesta": categoriaRichiesta,
    };
  }

  //crea un'istanza di Utente a partire da una mappa (usato per il recupero dati offline)
  factory Utente.fromMap(Map<String, dynamic> map) {
    return Utente(
      map['nome'] ?? '',
      map['cognome'] ?? '',
      map['eta'] ?? 0,
      map['codiceFiscale'] ?? '',
      map['categoriaRichiesta'] ?? '',
    );
  }

  //mappa i dati per l'invio al database Firestore
  Map<String, dynamic> toFirestore() {
    return toMap();
  }
}
