import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/Utente.dart';
import '../model/Lezione.dart';
import '../model/Esame.dart';
import '../model/SlotGuida.dart';
import '../model/EsitoEsame.dart';
import 'RepositoryInterface.dart';

class UtenteRepository implements RepositoryInterface {
  //Istanzio Firebase e FirebaseAuth per l'autenticazione
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  //Definisco una funzione di tipo Utente per il login che prende come parametri CF e PW
  @override
  Future<Utente?> eseguiLogin(String codiceFiscale, String password) async {
    final String email = "${codiceFiscale.toLowerCase()}@driveapp.it";
    final credenziali = await auth.signInWithEmailAndPassword(email: email, password: password);
    if (credenziali.user != null) {
      return getUtente(codiceFiscale);
    }
    return null;
  }

  //Funzione richiamata dall'interfaccia per registrare l'utente
  @override
  //Passo l'istanza di Utente e la password
  Future<void> registraUtente(Utente utente, String password) async {
    //Creo la mail fittizia richiesta aggiungendo @.... come testo
    //Conta solo il codice fiscale come dato intrinseco
    final String email = "${utente.codiceFiscale.toLowerCase()}@driveapp.it";

    //Uso la classe di default messa a diposizione da Firebase per le credenziali
    UserCredential? credenziali;

    //Per evitare eccezioni indesiderate, racchiudo tutto in un try catch
    try {
      //Creo le credenziali con il metodo di default della classe UserCredential
      credenziali = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      /*Aspetto che firebase, dopo aver associato correttamente
      * il codice fiscale, salvi il tutto*/
      await firestore
          .collection("utenti")
          .doc(utente.codiceFiscale)
          .set(utente.toFirestore());

    } catch (e) {

      try {
        await credenziali?.user?.delete();
      } catch (_) {}

      rethrow;
    }
  }

  /*Definisco una serie di getter per prelevare i dati necessari da Firestore
  Per le liste. per ogni funzione, ne uso un'altra .map per trasformare ogni documento in oggetto
  Per gli elementi singoli, verifico l'effettiva esistenza del documento prima di restituire l'oggetto mappato. */
  @override
  Future<Utente?> getUtente(String codiceFiscale) async {
    final doc = await firestore.collection("utenti").doc(codiceFiscale).get();
    if (doc.exists) {
      return Utente.fromFirestore(doc, null);
    }
    return null;
  }

  @override
  Future<List<Lezione>> getLezioni(DateTime inizio, DateTime fine) async {
    final query = await firestore.collection("lezioni")
        .where("dataLezione", isGreaterThanOrEqualTo: inizio)
        .where("dataLezione", isLessThanOrEqualTo: fine)
        .get();
    return query.docs.map((doc) => Lezione.fromFirestore(doc, null)).toList();
  }

  @override
  Future<List<Esame>> getEsami(DateTime inizio, DateTime fine) async {
    final query = await firestore.collection("esami")
        .where("data", isGreaterThanOrEqualTo: inizio)
        .where("data", isLessThanOrEqualTo: fine)
        .get();
    return query.docs.map((doc) => Esame.fromFirestore(doc, null)).toList();
  }

  @override
  Future<List<SlotGuida>> getGuide(DateTime inizio, DateTime fine) async {
    final query = await firestore.collection("slot_guide")
        .where("data", isGreaterThanOrEqualTo: inizio)
        .where("data", isLessThanOrEqualTo: fine)
        .get();
    return query.docs.map((doc) => SlotGuida.fromFirestore(doc, null)).toList();
  }

  @override
  Future<List<EsitoEsame>> getEsiti(String codiceFiscale) async {
    final query = await firestore.collection("esiti_esami")
        .where("codiceFiscale", isEqualTo: codiceFiscale)
        .get();
    return query.docs.map((doc) => EsitoEsame.fromFirestore(doc, null)).toList();
  }

  @override
  Future<List<Esame>> getEsamiPerId(List<String> ids) async {
    if (ids.isEmpty) return [];
    final query = await firestore.collection("esami")
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return query.docs.map((doc) => Esame.fromFirestore(doc, null)).toList();
  }

  @override
  Future<List<Esame>> getEsamiFuturi(String categoria, DateTime data) async {
    final query = await firestore.collection("esami")
        .where("data", isGreaterThan: data)
        .get();
    return query.docs
        .map((doc) => Esame.fromFirestore(doc, null))
        .where((e) => e.categoriaPatente == categoria)
        .toList();
  }

  @override
  Future<List<String>> getPrenotazioniEsamiUtente(String codiceFiscale) async {
    final query = await firestore.collection("prenotazioni_esami")
        .where("codiceFiscale", isEqualTo: codiceFiscale)
        .get();
    return query.docs.map((doc) => doc.data()["idEsame"] as String).toList();
  }

  @override
  Future<List<SlotGuida>> getGuideFuture(String categoria, DateTime data) async {
    final query = await firestore.collection("slot_guide")
        .where("data", isGreaterThan: data)
        .get();
    return query.docs
        .map((doc) => SlotGuida.fromFirestore(doc, null))
        .where((g) => g.categoriaPatente == categoria)
        .toList();
  }

  //Funzione per permettere all'Utente di prenotare un esame dalla lista di quelli disponibili
  @override
  Future<void> prenotaEsame(String idEsame, String codiceFiscale) async {
    await firestore.collection("prenotazioni_esami").doc("${idEsame}_$codiceFiscale").set({
      "idEsame": idEsame,
      "codiceFiscale": codiceFiscale,
    });
  }

  //Stesso ragionamento per le guide
  @override
  Future<void> prenotaGuida(String idGuida, String codiceFiscale) async {
    await firestore.collection("slot_guide").doc(idGuida).update({
      "utentePrenotato": codiceFiscale,
    });
  }

  //Rimuove la prenotazione dell'esame dal database per l'utente specifico
  @override
  Future<void> annullaEsame(String idEsame, String codiceFiscale) async {
    await firestore.collection("prenotazioni_esami").doc("${idEsame}_$codiceFiscale").delete();
  }

  //Annulla la prenotazione della guida liberando lo slot (imposta l'utente a null)
  @override
  Future<void> annullaGuida(String idGuida) async {
    await firestore.collection("slot_guide").doc(idGuida).update({
      "utentePrenotato": null,
    });
  }

  @override
  Future<void> cambiaPassword(String nuovaPassword) async {
    await auth.currentUser?.updatePassword(nuovaPassword);
  }

  @override
  Future<void> eliminaUtente(String codiceFiscale) async {

    //Utilizzo una funzione batch per scritture multiple
    final batch = firestore.batch();

    final prenotazioni = await firestore
        .collection("prenotazioni_esami")
        //Prelevo le prenotazioni associate all'utente da eliminare
        .where("codiceFiscale", isEqualTo: codiceFiscale)
        .get();

    //Cancello
    for (final doc in prenotazioni.docs) {
      batch.delete(doc.reference);
    }

    //Stessa cosa con esiti e guide
    final esiti = await firestore
        .collection("esiti_esami")
        .where("codiceFiscale", isEqualTo: codiceFiscale)
        .get();

    for (final doc in esiti.docs) {
      batch.delete(doc.reference);
    }

    final guide = await firestore
        .collection("slot_guide")
        .where("utentePrenotato", isEqualTo: codiceFiscale)
        .get();

    for (final doc in guide.docs) {
      batch.update(doc.reference, {
        "utentePrenotato": null,
      });
    }

    //Alla fine, elimino definitivamente l'utente dal DB
    batch.delete(
      firestore.collection("utenti").doc(codiceFiscale),
    );

    await batch.commit();

    await auth.currentUser?.delete();
  }

  @override
  Future<void> signOut() async {
    await auth.signOut();
  }
}
