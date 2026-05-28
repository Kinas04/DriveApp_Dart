import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/Utente.dart';
import '../model/Lezione.dart';
import '../model/Esame.dart';
import '../model/SlotGuida.dart';
import '../model/EsitoEsame.dart';
import 'RepositoryInterface.dart';

class UtenteRepository implements RepositoryInterface {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Future<Utente?> eseguiLogin(String codiceFiscale, String password) async {
    final String email = "${codiceFiscale.toLowerCase()}@driveapp.it";
    final credentials = await auth.signInWithEmailAndPassword(email: email, password: password);
    
    if (credentials.user != null) {
      return getUtente(codiceFiscale);
    }
    return null;
  }

  @override
  Future<void> registraUtente(Utente utente, String password) async {
    final String email = "${utente.codiceFiscale.toLowerCase()}@driveapp.it";
    await auth.createUserWithEmailAndPassword(email: email, password: password);
    await firestore.collection("utenti").doc(utente.codiceFiscale).set(utente.toFirestore());
  }

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
        .where("categoriaPatente", isEqualTo: categoria)
        .where("data", isGreaterThan: data)
        .get();
    return query.docs.map((doc) => Esame.fromFirestore(doc, null)).toList();
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
        .where("categoriaPatente", isEqualTo: categoria)
        .where("data", isGreaterThan: data)
        .get();
    return query.docs.map((doc) => SlotGuida.fromFirestore(doc, null)).toList();
  }

  @override
  Future<void> prenotaEsame(String idEsame, String codiceFiscale) async {
    await firestore.collection("prenotazioni_esami").doc("${idEsame}_$codiceFiscale").set({
      "idEsame": idEsame,
      "codiceFiscale": codiceFiscale,
    });
  }

  @override
  Future<void> prenotaGuida(String idGuida, String codiceFiscale) async {
    await firestore.collection("slot_guide").doc(idGuida).update({
      "utentePrenotato": codiceFiscale,
    });
  }

  @override
  Future<void> cambiaPassword(String nuovaPassword) async {
    await auth.currentUser?.updatePassword(nuovaPassword);
  }

  @override
  Future<void> eliminaUtente(String codiceFiscale) async {
    await firestore.collection("utenti").doc(codiceFiscale).delete();
    await auth.currentUser?.delete();
  }

  @override
  Future<void> signOut() async {
    await auth.signOut();
  }
}
