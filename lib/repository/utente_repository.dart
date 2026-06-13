import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/utente.dart';
import '../model/lezione.dart';
import '../model/esame.dart';
import '../model/slot_guida.dart';
import '../model/esito_esame.dart';
import 'repository_interface.dart';

//Implementazione concreta della Repository che comunica direttamente con Firebase (Auth e Firestore)
class UtenteRepository implements RepositoryInterface {
  //Istanzio Firebase e FirebaseAuth per l'autenticazione e la gestione del database
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  //Definisco una funzione di tipo Utente per il login che prende come parametri CF e PW
  @override
  Future<Utente?> eseguiLogin(String codiceFiscale, String password) async {
    //Genero una mail fittizia basata sul codice fiscale per l'autenticazione Firebase
    final String email = "${codiceFiscale.toLowerCase()}@driveapp.it";
    final credenziali = await auth.signInWithEmailAndPassword(email: email, password: password);
    if (credenziali.user != null) {
      //Se il login ha successo, recupero i dati anagrafici completi da Firestore
      return getUtente(codiceFiscale);
    }
    return null;
  }

  //Funzione richiamata dall'interfaccia per registrare l'utente
  @override
  //Passo l'istanza di Utente e la password inserita
  Future<void> registraUtente(Utente utente, String password) async {
    //Creo la mail fittizia richiesta aggiungendo il dominio dell'app
    //Conta solo il codice fiscale come dato intrinseco per identificare l'utente
    final String email = "${utente.codiceFiscale.toLowerCase()}@driveapp.it";

    //Uso la classe di default messa a diposizione da Firebase per gestire le credenziali
    UserCredential? credenziali;

    //Per evitare eccezioni indesiderate durante la comunicazione con il server, racchiudo tutto in un try catch
    try {
      //Creo le credenziali con il metodo di default della classe UserCredential su Firebase Auth
      credenziali = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      /*Aspetto che firebase, dopo aver associato correttamente
      * il codice fiscale, salvi il tutto nella collezione 'utenti'*/
      await firestore
          .collection("utenti")
          .doc(utente.codiceFiscale)
          .set(utente.toFirestore());

    } on FirebaseAuthException catch (e) {
      //Gestisco il caso specifico in cui l'utente stia provando a registrarsi con un CF già esistente
      if (e.code == 'email-already-in-use') {
        throw Exception("Il Codice Fiscale inserito è già associato a un account.");
      }
      rethrow;
    } catch (e) {
      //In caso di altri errori durante la creazione del record su Firestore, rimuovo l'utente appena creato su Auth per coerenza
      try {
        await credenziali?.user?.delete();
      } catch (_) {}
      rethrow;
    }
  }

  /*Definisco una serie di getter per prelevare i dati necessari da Firestore
  Per le liste, per ogni funzione, ne uso un'altra .map per trasformare ogni documento in oggetto Dart
  Per gli elementi singoli, verifico l'effettiva esistenza del documento prima di restituire l'oggetto mappato. */
  @override
  Future<Utente?> getUtente(String codiceFiscale) async {
    final doc = await firestore.collection("utenti").doc(codiceFiscale).get();
    if (doc.exists) {
      return Utente.fromFirestore(doc, null);
    }
    return null;
  }

  //recupera le lezioni di teoria dal database filtrandole per data
  @override
  Future<List<Lezione>> getLezioni(DateTime inizio, DateTime fine) async {
    final query = await firestore.collection("lezioni")
        .where("dataLezione", isGreaterThanOrEqualTo: inizio)
        .where("dataLezione", isLessThanOrEqualTo: fine)
        .get();
    return query.docs.map((doc) => Lezione.fromFirestore(doc, null)).toList();
  }

  //preleva gli appelli d'esame filtrati per l'intervallo temporale selezionato
  @override
  Future<List<Esame>> getEsami(DateTime inizio, DateTime fine) async {
    final query = await firestore.collection("esami")
        .where("data", isGreaterThanOrEqualTo: inizio)
        .where("data", isLessThanOrEqualTo: fine)
        .get();
    return query.docs.map((doc) => Esame.fromFirestore(doc, null)).toList();
  }

  //ottiene gli slot di guida pratica per un determinato periodo
  @override
  Future<List<SlotGuida>> getGuide(DateTime inizio, DateTime fine) async {
    final query = await firestore.collection("slot_guide")
        .where("data", isGreaterThanOrEqualTo: inizio)
        .where("data", isLessThanOrEqualTo: fine)
        .get();
    return query.docs.map((doc) => SlotGuida.fromFirestore(doc, null)).toList();
  }

  //recupera lo storico degli esiti degli esami per lo specifico utente loggato
  @override
  Future<List<EsitoEsame>> getEsiti(String codiceFiscale) async {
    final query = await firestore.collection("esiti_esami")
        .where("codiceFiscale", isEqualTo: codiceFiscale)
        .get();
    return query.docs.map((doc) => EsitoEsame.fromFirestore(doc, null)).toList();
  }

  //restituisce i dettagli di un set di esami partendo dai loro identificativi
  @override
  Future<List<Esame>> getEsamiPerId(List<String> ids) async {
    if (ids.isEmpty) return [];
    final query = await firestore.collection("esami")
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return query.docs.map((doc) => Esame.fromFirestore(doc, null)).toList();
  }

  //filtra gli esami futuri che corrispondono alla categoria di patente dell'utente
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

  //restituisce gli ID degli esami già prenotati dall'utente per gestire lo stato della UI
  @override
  Future<List<String>> getPrenotazioniEsamiUtente(String codiceFiscale) async {
    final query = await firestore.collection("prenotazioni_esami")
        .where("codiceFiscale", isEqualTo: codiceFiscale)
        .get();
    return query.docs.map((doc) => doc.data()["idEsame"] as String).toList();
  }

  //recupera gli slot guida futuri filtrando per categoria di patente
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

  //Funzione per permettere all'Utente di prenotare un esame salvando il record sul DB
  @override
  Future<void> prenotaEsame(String idEsame, String codiceFiscale) async {
    await firestore.collection("prenotazioni_esami").doc("${idEsame}_$codiceFiscale").set({
      "idEsame": idEsame,
      "codiceFiscale": codiceFiscale,
    });
  }

  //Stesso ragionamento per le guide: aggiorno lo slot inserendo il CF dell'utente
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

  //aggiorna la password dell'utente corrente su Firebase Authentication
  @override
  Future<void> cambiaPassword(String nuovaPassword) async {
    await auth.currentUser?.updatePassword(nuovaPassword);
  }

  //elimina definitivamente l'account e pulisce a cascata tutti i dati associati (esiti, guide, prenotazioni)
  @override
  Future<void> eliminaUtente(String codiceFiscale) async {

    //Utilizzo una funzione batch per eseguire scritture multiple in un'unica operazione atomica
    final batch = firestore.batch();

    final prenotazioni = await firestore
        .collection("prenotazioni_esami")
        //Prelevo le prenotazioni associate all'utente da eliminare
        .where("codiceFiscale", isEqualTo: codiceFiscale)
        .get();

    //Aggiungo la cancellazione di ogni prenotazione al batch
    for (final doc in prenotazioni.docs) {
      batch.delete(doc.reference);
    }

    //Stessa cosa con gli esiti degli esami
    final esiti = await firestore
        .collection("esiti_esami")
        .where("codiceFiscale", isEqualTo: codiceFiscale)
        .get();

    for (final doc in esiti.docs) {
      batch.delete(doc.reference);
    }

    //E con gli slot di guida prenotati: li libero invece di cancellarli
    final guide = await firestore
        .collection("slot_guide")
        .where("utentePrenotato", isEqualTo: codiceFiscale)
        .get();

    for (final doc in guide.docs) {
      batch.update(doc.reference, {
        "utentePrenotato": null,
      });
    }

    //Alla fine, elimino definitivamente il profilo utente dalla collezione Firestore
    batch.delete(
      firestore.collection("utenti").doc(codiceFiscale),
    );

    //Eseguo tutte le operazioni pianificate
    await batch.commit();

    //Infine rimuovo l'account da Firebase Authentication
    await auth.currentUser?.delete();
  }

  //effettua la disconnessione della sessione utente da Firebase
  @override
  Future<void> signOut() async {
    await auth.signOut();
  }

  //restituisce true se esiste un utente Firebase correntemente loggato
  @override
  bool isAutenticato() {
    return auth.currentUser != null;
  }
}
