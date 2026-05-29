import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drive_app_dart/model/Esame.dart';
import 'package:drive_app_dart/model/EsitoEsame.dart';
import 'package:drive_app_dart/model/Lezione.dart';
import 'package:drive_app_dart/model/PrenotazioneEsame.dart';
import 'package:drive_app_dart/model/SlotGuida.dart';
import 'package:drive_app_dart/model/Utente.dart';

class UtenteSeed {
  final String nome;
  final String cognome;
  final int eta;
  final String cf;
  final String pass;
  final String categoria;

  UtenteSeed(this.nome, this.cognome, this.eta, this.cf, this.pass, this.categoria);
}

class DatabaseSeeder {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  DateTime creaData(String dataStringa) {
    return DateTime.parse(dataStringa);
  }

  Future<void> popolaUtenti() async {
    final utentiIniziali = [
      UtenteSeed("Lorenzo", "Rossi", 14, "RSSLNZ12A01H501A", "Pass123!", "AM"),
      UtenteSeed("Giulia", "Bianchi", 14, "BNCGLI12B14F205C", "Guidare2026", "AM"),
      UtenteSeed("Matteo", "Ferrari", 15, "FRRMTT11C22D332K", "Moto15!!", "AM"),
      UtenteSeed("Sofia", "Esposito", 14, "SPSSFO12D10G444X", "CiaoCiao1", "AM"),
      UtenteSeed("Leonardo", "Ricci", 15, "RCCLND11E05H501B", "Pass123!", "AM"),
      UtenteSeed("Aurora", "Marino", 14, "MRNRRA12F18L219Y", "Password00", "AM"),
      UtenteSeed("Riccardo", "Greco", 15, "GRCRCR11G30F839Z", "Scooter99", "AM"),
      UtenteSeed("Alice", "Bruno", 14, "BRNLCA12H12A345J", "Alice2012", "AM"),
      UtenteSeed("Tommaso", "Gallo", 15, "GLLTMS11M25B111Q", "TommyGallo", "AM"),
      UtenteSeed("Ginevra", "Conti", 14, "CNTGVR12P04C222W", "Pass123!", "AM"),
      UtenteSeed("Alessandro", "De Luca", 16, "DLCLSN10A15H501R", "AleMoto16", "A1"),
      UtenteSeed("Chiara", "Mancini", 17, "MNCCHR09B28F205S", "Chiara09!", "A1"),
      UtenteSeed("Andrea", "Costa", 16, "CSTNDR10C10D332T", "CostaAndr", "AM"),
      UtenteSeed("Martina", "Giordano", 17, "GRDMTN09D05G444U", "Marty099", "A1"),
      UtenteSeed("Gabriele", "Rizzo", 16, "RZZGRL10E20H501V", "Pass123!", "A1"),
      UtenteSeed("Sara", "Lombardi", 17, "LMBSRA09F14L219W", "SaraLomb", "A1"),
      UtenteSeed("Edoardo", "Moretti", 16, "MRTDDR10G02F839X", "Edo12345", "AM"),
      UtenteSeed("Elena", "Barbieri", 17, "BRBLNE09H11A345Y", "Pass123!", "A1"),
      UtenteSeed("Filippo", "Fontana", 16, "FNTFPP10M22B111Z", "PippoFnt", "A1"),
      UtenteSeed("Emma", "Santoro", 17, "SNTMME09P07C222A", "EmmaSant", "A1"),
      UtenteSeed("Christian", "Caruso", 16, "CRSCHR10A03H501B", "Chris10!", "AM"),
      UtenteSeed("Vittoria", "Mariani", 17, "MRNVTR09B16F205C", "VittoriaA1", "A1"),
      UtenteSeed("Diego", "Rinaldi", 16, "RNLDGI10C29D332D", "Pass123!", "A1"),
      UtenteSeed("Anna", "Ferrara", 17, "FRRNNA09D18G444E", "AnnaAnna9", "AM"),
      UtenteSeed("Niccolò", "Galli", 16, "GLLNCL10E09H501F", "NickGalli", "A1"),
      UtenteSeed("Marco", "Rossi", 18, "RSSMRC08A12H501A", "Marco18!", "B"),
      UtenteSeed("Francesca", "Bianchi", 18, "BNCFNC08B25F205B", "Pass123!", "B"),
      UtenteSeed("Luca", "Colombo", 19, "CLMLCU07C04D332C", "LucaColo", "B"),
      UtenteSeed("Alessia", "Romano", 19, "RMNLSS07D15G444D", "Alessia1", "B"),
      UtenteSeed("Simone", "Russo", 18, "RSSSMN08E30H501E", "SimRusso", "A2"),
      UtenteSeed("Beatrice", "Galli", 20, "GLLBRC06F12L219F", "BeaBeaBea", "B"),
      UtenteSeed("Pietro", "Martini", 18, "MRTPTR08G22F839G", "Pietro08", "B"),
      UtenteSeed("Giorgia", "Leone", 19, "LNEGRG07H05A345H", "Pass123!", "B"),
      UtenteSeed("Jacopo", "Longo", 20, "LNGJCP06M19B111I", "JacopoB", "A2"),
      UtenteSeed("Noemi", "Gentile", 18, "GNTNMI08P08C222J", "Noemi18!", "B"),
      UtenteSeed("Samuele", "Conte", 19, "CNTSML07A27H501K", "SamueleC", "B"),
      UtenteSeed("Arianna", "Serra", 20, "SRRRNN06B10F205L", "ArySerra", "B"),
      UtenteSeed("Davide", "Coppola", 18, "CPPDVD08C21D332M", "Pass123!", "B"),
      UtenteSeed("Mia", "De Angelis", 19, "DNGMIA07D03G444N", "MiaMia19", "A2"),
      UtenteSeed("Michele", "Ferri", 20, "FRRMHL06E14H501O", "MikFerri", "B"),
      UtenteSeed("Alessio", "Fabbri", 21, "FBBLSS05F26L219P", "Pass123!", "B"),
      UtenteSeed("Marta", "Bianco", 22, "BNCMRT04G07F839Q", "MartaBia", "B"),
      UtenteSeed("Daniele", "Marchetti", 23, "MRCDNL03H18A345R", "DaniMar", "B"),
      UtenteSeed("Giada", "Parisi", 24, "PRSGDI02M29B111S", "Giada002", "B"),
      UtenteSeed("Mirko", "Villa", 25, "VLLMRK01P11C222T", "Pass123!", "B"),
      UtenteSeed("Ludovica", "Valentini", 21, "VLNLVC05A20H501U", "LudoVal", "A"),
      UtenteSeed("Federico", "Gatti", 26, "GTTFRC00B02F205V", "FedeGatt", "B"),
      UtenteSeed("Ilaria", "Pellegrini", 27, "PLLLRI99C15D332W", "IlaPelle", "B"),
      UtenteSeed("Christian", "Palumbo", 28, "PLMCRS98D28G444X", "Pass123!", "A"),
      UtenteSeed("Serena", "Sanna", 29, "SNNSNR97E09H501Y", "SereSanna", "B"),
      UtenteSeed("Luigi", "Farina", 30, "FRNLGU96F22L219Z", "LuigiC12", "C"),
      UtenteSeed("Roberta", "D'Amico", 32, "DMCRRT94G04F839A", "RobyDam", "C"),
      UtenteSeed("Antonio", "Riva", 35, "RVINNT91H15A345B", "AntoRiva", "D"),
      UtenteSeed("Valeria", "Monti", 28, "MNTVLR98M27B111C", "Pass123!", "CE"),
      UtenteSeed("Enrico", "Miceli", 40, "MCLNRC86P08C222D", "Enrico86", "DE"),
      UtenteSeed("Paola", "Fiore", 33, "FRIPLA93A19H501E", "PaolaFio", "C"),
      UtenteSeed("Stefano", "De Santis", 38, "DSNSFN88B01F205F", "Pass123!", "CE"),
      UtenteSeed("Elisa", "Ruggiero", 29, "RGGLSE97C14D332G", "ElisaRug", "D"),
      UtenteSeed("Roberto", "Carbone", 45, "CRBRRT81D25G444H", "RobyCar", "DE"),
      UtenteSeed("Silvia", "Martino", 31, "MRTSLV95E06H501I", "SilviaM", "C"),
      UtenteSeed("Gianluca", "Neri", 25, "NREGLC01F17L219J", "Gianlu01", "A"),
      UtenteSeed("Valentina", "Pugliese", 18, "PGLVNT08G28F839K", "Vale18", "B"),
      UtenteSeed("Mattia", "Filippi", 20, "FLPMTT06H09A345L", "MattiFil", "B"),
      UtenteSeed("Giorgio", "Basso", 22, "BSSGRG04M20B111M", "Pass123!", "A"),
      UtenteSeed("Irene", "Testa", 24, "TSTRNI02P02C222N", "IreneTes", "B"),
      UtenteSeed("Carmine", "Grasso", 27, "GRSCMN99A13H501O", "CarGrasso", "A"),
      UtenteSeed("Monica", "Lombardo", 30, "LMBMNC96B24F205P", "MonLomb", "B"),
      UtenteSeed("Vincenzo", "D'Angelo", 19, "DNGVCN07C05D332Q", "VincDan", "B"),
      UtenteSeed("Federica", "Silvestri", 21, "SLVFRC05D16G444R", "FedeSil", "B"),
      UtenteSeed("Claudio", "Guerra", 35, "GRRCLD91E29H501S", "Pass123!", "A"),
      UtenteSeed("Alessandra", "Mazza", 18, "MZZLSN08F10L219T", "Aless08", "B"),
      UtenteSeed("Giuseppe", "Vitale", 26, "VTLGPP00G21F839U", "GiusVit", "A"),
      UtenteSeed("Cristina", "Piras", 22, "PRSCST04H03A345V", "CrisPiras", "B"),
      UtenteSeed("Fabio", "Gargiulo", 29, "GRGFBA97M14B111W", "Pass123!", "A"),
      UtenteSeed("Eleonora", "Bellini", 20, "BLLLNR06P25C222X", "EleBelli", "B")
    ];

    for (var seed in utentiIniziali) {
      final String fintaEmail = "${seed.cf.toLowerCase()}@driveapp.it";

      try {
        // Crea l'utente su Firebase Authentication
        await auth.createUserWithEmailAndPassword(email: fintaEmail, password: seed.pass);

        // Crea l'oggetto Utente standard (includendo la password se il modello la richiede)
        final utente = Utente(
          seed.nome,
          seed.cognome,
          seed.eta,
          seed.cf,
          seed.pass,
          seed.categoria,
        );

        // Salvataggio su Firestore
        await db.collection("utenti").doc(seed.cf).set(utente.toFirestore());

        // Delay per non attivare il filtro spam (facoltativo in Dart)
        await Future.delayed(const Duration(milliseconds: 500));

      } catch (e) {
        // Se l'utente esiste già si prosegue col prossimo
        print("Errore o utente già esistente: ${seed.cf} - ${e.toString()}");
      }
    }

    await auth.signOut();
    print("Popolamento utenti completato!");
  }

  Future<void> popolaTutto() async {
    // Prima popoliamo gli utenti con Auth
    await popolaUtenti();

    final lezioniIniziali = [
      Lezione("L01", creaData("2026-05-04"), "09:00", "11:00", "Aula A", "Capitolo 1 - Definizioni stradali e di traffico"),
      Lezione("L02", creaData("2026-05-04"), "15:00", "17:00", "Aula B", "Capitolo 2 - Segnaletica di pericolo e precedenza"),
      Lezione("L03", creaData("2026-05-05"), "10:00", "12:00", "Aula Magna", "Capitolo 3 - Segnali di divieto e obbligo"),
      Lezione("L04", creaData("2026-05-05"), "16:00", "18:00", "Aula A", "Capitolo 4 - Segnaletica orizzontale e semafori"),
      Lezione("L05", creaData("2026-05-06"), "09:00", "11:00", "Aula B", "Capitolo 5 - Limiti di velocità e pericolo"),
      Lezione("L06", creaData("2026-05-06"), "17:00", "19:00", "Aula Magna", "Capitolo 6 - Distanza di sicurezza"),
      Lezione("L07", creaData("2026-05-07"), "10:00", "12:00", "Aula A", "Capitolo 7 - Norme di circolazione e posizione dei veicoli"),
      Lezione("L08", creaData("2026-05-07"), "15:00", "17:00", "Aula B", "Capitolo 8 - Precedenza"),
      Lezione("L09", creaData("2026-05-08"), "09:00", "11:00", "Aula Magna", "Capitolo 9 - Sorpasso"),
      Lezione("L10", creaData("2026-05-08"), "16:00", "18:00", "Aula A", "Capitolo 10 - Arresto, sosta e fermata"),
      Lezione("L11", creaData("2026-05-11"), "10:00", "12:00", "Aula B", "Capitolo 11 - Ingombro della carreggiata e traino"),
      Lezione("L12", creaData("2026-05-11"), "17:00", "19:00", "Aula Magna", "Capitolo 12 - Dispositivi visivi e di illuminazione"),
      Lezione("L13", creaData("2026-05-12"), "09:00", "11:00", "Aula A", "Capitolo 13 - Dispositivi di sicurezza (cinture e caschi)"),
      Lezione("L14", creaData("2026-05-12"), "15:00", "17:00", "Aula B", "Capitolo 14 - Patenti e documenti di circolazione"),
      Lezione("L15", creaData("2026-05-13"), "10:00", "12:00", "Aula Magna", "Capitolo 15 - Responsabilità civile, penale e assicurazione"),
      Lezione("L16", creaData("2026-05-13"), "16:00", "18:00", "Aula A", "Capitolo 16 - Inquinamento e rispetto dell'ambiente"),
      Lezione("L17", creaData("2026-05-14"), "09:00", "11:00", "Aula B", "Capitolo 17 - Condizioni psicofisiche del conducente"),
      Lezione("L18", creaData("2026-05-14"), "17:00", "19:00", "Aula Magna", "Capitolo 18 - Primo soccorso"),
      Lezione("L19", creaData("2026-05-15"), "10:00", "12:00", "Aula A", "Capitolo 19 - Elementi del veicolo e manutenzione"),
      Lezione("L20", creaData("2026-05-15"), "15:00", "17:00", "Aula B", "Capitolo 20 - Conduzione del veicolo in autostrada"),
      Lezione("L21", creaData("2026-05-18"), "09:00", "11:00", "Aula Magna", "Capitolo 1 - Definizioni stradali e di traffico"),
      Lezione("L22", creaData("2026-05-18"), "16:00", "18:00", "Aula A", "Capitolo 2 - Segnaletica di pericolo e precedenza"),
      Lezione("L23", creaData("2026-05-19"), "10:00", "12:00", "Aula B", "Capitolo 3 - Segnali di divieto e obbligo"),
      Lezione("L24", creaData("2026-05-19"), "17:00", "19:00", "Aula Magna", "Capitolo 4 - Segnaletica orizzontale e semafori"),
      Lezione("L25", creaData("2026-05-20"), "09:00", "11:00", "Aula A", "Capitolo 5 - Limiti di velocità e pericolo"),
      Lezione("L26", creaData("2026-05-20"), "15:00", "17:00", "Aula B", "Capitolo 6 - Distanza di sicurezza"),
      Lezione("L27", creaData("2026-05-21"), "10:00", "12:00", "Aula Magna", "Capitolo 7 - Norme di circolazione e posizione dei veicoli"),
      Lezione("L28", creaData("2026-05-21"), "16:00", "18:00", "Aula A", "Capitolo 8 - Precedenza"),
      Lezione("L29", creaData("2026-05-22"), "09:00", "11:00", "Aula B", "Capitolo 9 - Sorpasso"),
      Lezione("L30", creaData("2026-05-22"), "17:00", "19:00", "Aula Magna", "Capitolo 10 - Arresto, sosta e fermata"),
      Lezione("L31", creaData("2026-05-25"), "10:00", "12:00", "Aula A", "Capitolo 11 - Ingombro della carreggiata e traino"),
      Lezione("L32", creaData("2026-05-25"), "15:00", "17:00", "Aula B", "Capitolo 12 - Dispositivi visivi e di illuminazione"),
      Lezione("L33", creaData("2026-05-26"), "09:00", "11:00", "Aula Magna", "Capitolo 13 - Dispositivi di sicurezza (cinture e caschi)"),
      Lezione("L34", creaData("2026-05-26"), "16:00", "18:00", "Aula A", "Capitolo 14 - Patenti e documenti di circolazione"),
      Lezione("L35", creaData("2026-05-27"), "10:00", "12:00", "Aula B", "Capitolo 15 - Responsabilità civile, penale e assicurazione"),
      Lezione("L36", creaData("2026-05-27"), "17:00", "19:00", "Aula Magna", "Capitolo 16 - Inquinamento e rispetto dell'ambiente"),
      Lezione("L37", creaData("2026-05-28"), "09:00", "11:00", "Aula A", "Capitolo 17 - Condizioni psicofisiche del conducente"),
      Lezione("L38", creaData("2026-05-28"), "15:00", "17:00", "Aula B", "Capitolo 18 - Primo soccorso"),
      Lezione("L39", creaData("2026-05-29"), "10:00", "12:00", "Aula Magna", "Capitolo 19 - Elementi del veicolo e manutenzione"),
      Lezione("L40", creaData("2026-05-29"), "16:00", "18:00", "Aula A", "Capitolo 20 - Conduzione del veicolo in autostrada"),
      Lezione("L41", creaData("2026-06-01"), "09:00", "11:00", "Aula B", "Capitolo 1 - Definizioni stradali e di traffico"),
      Lezione("L42", creaData("2026-06-01"), "17:00", "19:00", "Aula Magna", "Capitolo 2 - Segnaletica di pericolo e precedenza"),
      Lezione("L43", creaData("2026-06-02"), "10:00", "12:00", "Aula A", "Capitolo 3 - Segnali di divieto e obbligo"),
      Lezione("L44", creaData("2026-06-02"), "15:00", "17:00", "Aula B", "Capitolo 4 - Segnaletica orizzontale e semafori"),
      Lezione("L45", creaData("2026-06-03"), "09:00", "11:00", "Aula Magna", "Capitolo 5 - Limiti di velocità e pericolo"),
      Lezione("L46", creaData("2026-06-03"), "16:00", "18:00", "Aula A", "Capitolo 6 - Distanza di sicurezza"),
      Lezione("L47", creaData("2026-06-04"), "10:00", "12:00", "Aula B", "Capitolo 7 - Norme di circolazione e posizione dei veicoli"),
      Lezione("L48", creaData("2026-06-04"), "17:00", "19:00", "Aula Magna", "Capitolo 8 - Precedenza"),
      Lezione("L49", creaData("2026-06-05"), "09:00", "11:00", "Aula A", "Capitolo 9 - Sorpasso"),
      Lezione("L50", creaData("2026-06-05"), "15:00", "17:00", "Aula B", "Capitolo 10 - Arresto, sosta e fermata")
    ];

    final esamiIniziali = [
      Esame("E01", creaData("2026-05-04"), "09:00", "11:00", "Motorizzazione Civile di Roma", "B", "Teorico"),
      Esame("E02", creaData("2026-05-04"), "15:00", "17:00", "Motorizzazione Civile di Milano", "B", "Pratico"),
      Esame("E03", creaData("2026-05-05"), "10:00", "12:00", "Motorizzazione Civile di Napoli", "AM", "Teorico"),
      Esame("E04", creaData("2026-05-05"), "16:00", "18:00", "Motorizzazione Civile di Torino", "AM", "Pratico"),
      Esame("E05", creaData("2026-05-06"), "09:00", "11:00", "Motorizzazione Civile di Palermo", "C", "Teorico"),
      Esame("E06", creaData("2026-05-06"), "14:30", "16:30", "Motorizzazione Civile di Genova", "C", "Pratico"),
      Esame("E07", creaData("2026-05-07"), "10:30", "12:30", "Motorizzazione Civile di Bologna", "A1", "Teorico"),
      Esame("E08", creaData("2026-05-08"), "15:30", "17:30", "Motorizzazione Civile di Firenze", "A1", "Pratico"),
      Esame("E09", creaData("2026-05-11"), "08:30", "10:30", "Motorizzazione Civile di Bari", "A2", "Teorico"),
      Esame("E10", creaData("2026-05-11"), "16:00", "18:00", "Motorizzazione Civile di Catania", "A2", "Pratico"),
      Esame("E11", creaData("2026-05-12"), "09:00", "11:00", "Motorizzazione Civile di Venezia", "B", "Teorico"),
      Esame("E12", creaData("2026-05-12"), "15:00", "17:00", "Motorizzazione Civile di Verona", "B", "Pratico"),
      Esame("E13", creaData("2026-05-13"), "10:00", "12:00", "Motorizzazione Civile di Messina", "D", "Teorico"),
      Esame("E14", creaData("2026-05-13"), "14:00", "16:00", "Motorizzazione Civile di Padova", "D", "Pratico"),
      Esame("E15", creaData("2026-05-14"), "09:30", "11:30", "Motorizzazione Civile di Trieste", "A", "Teorico"),
      Esame("E16", creaData("2026-05-15"), "15:30", "17:30", "Motorizzazione Civile di Brescia", "A", "Pratico"),
      Esame("E17", creaData("2026-05-18"), "09:00", "11:00", "Motorizzazione Civile di Parma", "CE", "Teorico"),
      Esame("E18", creaData("2026-05-18"), "16:30", "18:30", "Motorizzazione Civile di Taranto", "CE", "Pratico"),
      Esame("E19", creaData("2026-05-19"), "10:00", "12:00", "Motorizzazione Civile di Prato", "B", "Teorico"),
      Esame("E20", creaData("2026-05-19"), "15:00", "17:00", "Motorizzazione Civile di Modena", "B", "Pratico"),
      Esame("E21", creaData("2026-05-20"), "08:30", "10:30", "Motorizzazione Civile di Reggio Calabria", "AM", "Teorico"),
      Esame("E22", creaData("2026-05-20"), "14:30", "16:30", "Motorizzazione Civile di Reggio Emilia", "AM", "Pratico"),
      Esame("E23", creaData("2026-05-21"), "09:00", "11:00", "Motorizzazione Civile di Perugia", "DE", "Teorico"),
      Esame("E24", creaData("2026-05-22"), "16:00", "18:00", "Motorizzazione Civile di Ravenna", "DE", "Pratico"),
      Esame("E25", creaData("2026-05-25"), "09:30", "11:30", "Motorizzazione Civile di Livorno", "A1", "Teorico"),
      Esame("E26", creaData("2026-05-25"), "15:30", "17:30", "Motorizzazione Civile di Cagliari", "A1", "Pratico"),
      Esame("E27", creaData("2026-05-26"), "10:00", "12:00", "Motorizzazione Civile di Foggia", "C", "Teorico"),
      Esame("E28", creaData("2026-05-26"), "14:00", "16:00", "Motorizzazione Civile di Rimini", "C", "Pratico"),
      Esame("E29", creaData("2026-05-27"), "09:00", "11:00", "Motorizzazione Civile di Salerno", "B", "Teorico"),
      Esame("E30", creaData("2026-05-27"), "16:00", "18:00", "Motorizzazione Civile di Ferrara", "B", "Pratico"),
      Esame("E31", creaData("2026-05-28"), "08:30", "10:30", "Motorizzazione Civile di Sassari", "A2", "Teorico"),
      Esame("E32", creaData("2026-05-29"), "15:00", "17:00", "Motorizzazione Civile di Latina", "A2", "Pratico"),
      Esame("E33", creaData("2026-06-01"), "09:00", "11:00", "Motorizzazione Civile di Monza", "A", "Teorico"),
      Esame("E34", creaData("2026-06-01"), "16:30", "18:30", "Motorizzazione Civile di Siracusa", "A", "Pratico"),
      Esame("E35", creaData("2026-06-02"), "10:00", "12:00", "Motorizzazione Civile di Pescara", "D", "Teorico"),
      Esame("E36", creaData("2026-06-02"), "15:30", "17:30", "Motorizzazione Civile di Bergamo", "D", "Pratico"),
      Esame("E37", creaData("2026-06-03"), "09:30", "11:30", "Motorizzazione Civile di Forlì", "B", "Teorico"),
      Esame("E38", creaData("2026-06-03"), "14:00", "16:00", "Motorizzazione Civile di Trento", "B", "Pratico"),
      Esame("E39", creaData("2026-06-04"), "09:00", "11:00", "Motorizzazione Civile di Vicenza", "AM", "Teorico"),
      Esame("E40", creaData("2026-06-05"), "16:00", "18:00", "Motorizzazione Civile di Terni", "AM", "Pratico"),
      Esame("E41", creaData("2026-06-08"), "08:30", "10:30", "Motorizzazione Civile di Bolzano", "CE", "Teorico"),
      Esame("E42", creaData("2026-06-08"), "15:00", "17:00", "Motorizzazione Civile di Novara", "CE", "Pratico"),
      Esame("E43", creaData("2026-06-09"), "10:00", "12:00", "Motorizzazione Civile di Piacenza", "A1", "Teorico"),
      Esame("E44", creaData("2026-06-09"), "16:30", "18:30", "Motorizzazione Civile di Ancona", "A1", "Pratico"),
      Esame("E45", creaData("2026-06-10"), "09:00", "11:00", "Motorizzazione Civile di Andria", "B", "Teorico"),
      Esame("E46", creaData("2026-06-10"), "14:30", "16:30", "Motorizzazione Civile di Arezzo", "B", "Pratico"),
      Esame("E47", creaData("2026-06-11"), "09:30", "11:30", "Motorizzazione Civile di Udine", "DE", "Teorico"),
      Esame("E48", creaData("2026-06-12"), "15:30", "17:30", "Motorizzazione Civile di Cesena", "DE", "Pratico"),
      Esame("E49", creaData("2026-06-15"), "10:00", "12:00", "Motorizzazione Civile di Lecce", "A2", "Teorico"),
      Esame("E50", creaData("2026-06-16"), "15:00", "17:00", "Motorizzazione Civile di Varese", "A2", "Pratico")
    ];

    final esitiIniziali = [
      EsitoEsame("E03", "RSSLNZ12A01H501A", "Idoneo"),
      EsitoEsame("E04", "RSSLNZ12A01H501A", "Idoneo"),
      EsitoEsame("E03", "BNCGLI12B14F205C", "Respinto"),
      EsitoEsame("E03", "FRRMTT11C22D332K", "Idoneo"),
      EsitoEsame("E22", "FRRMTT11C22D332K", "Assente"),
      EsitoEsame("E07", "DLCLSN10A15H501R", "Idoneo"),
      EsitoEsame("E08", "DLCLSN10A15H501R", "Idoneo"),
      EsitoEsame("E07", "MNCCHR09B28F205S", "Idoneo"),
      EsitoEsame("E26", "MNCCHR09B28F205S", "Respinto"),
      EsitoEsame("E01", "RSSMRC08A12H501A", "Idoneo"),
      EsitoEsame("E02", "RSSMRC08A12H501A", "Idoneo"),
      EsitoEsame("E01", "BNCFNC08B25F205B", "Idoneo"),
      EsitoEsame("E12", "BNCFNC08B25F205B", "Respinto"),
      EsitoEsame("E11", "CLMLCU07C04D332C", "Idoneo"),
      EsitoEsame("E20", "CLMLCU07C04D332C", "Idoneo"),
      EsitoEsame("E09", "RSSSMN08E30H501E", "Respinto"),
      EsitoEsame("E11", "RMNLSS07D15G444D", "Idoneo"),
      EsitoEsame("E20", "RMNLSS07D15G444D", "Idoneo"),
      EsitoEsame("E19", "GLLBRC06F12L219F", "Idoneo"),
      EsitoEsame("E05", "FRNLGU96F22L219Z", "Idoneo"),
      EsitoEsame("E06", "FRNLGU96F22L219Z", "Idoneo"),
      EsitoEsame("E13", "RVINNT91H15A345B", "Idoneo"),
      EsitoEsame("E14", "RVINNT91H15A345B", "Respinto"),
      EsitoEsame("E17", "MNTVLR98M27B111C", "Idoneo"),
      EsitoEsame("E18", "MNTVLR98M27B111C", "Idoneo"),
      EsitoEsame("E23", "MCLNRC86P08C222D", "Idoneo"),
      EsitoEsame("E24", "MCLNRC86P08C222D", "Idoneo"),
      EsitoEsame("E27", "DMCRRT94G04F839A", "Respinto"),
      EsitoEsame("E41", "DSNSFN88B01F205F", "Idoneo"),
      EsitoEsame("E29", "FBBLSS05F26L219P", "Idoneo"),
      EsitoEsame("E30", "FBBLSS05F26L219P", "Idoneo"),
      EsitoEsame("E29", "BNCMRT04G07F839Q", "Respinto"),
      EsitoEsame("E31", "VLNLVC05A20H501U", "Idoneo"),
      EsitoEsame("E34", "VLNLVC05A20H501U", "Idoneo"),
      EsitoEsame("E37", "GTTFRC00B02F205V", "Idoneo"),
      EsitoEsame("E39", "VSSGRG04M20B111M", "Idoneo"),
      EsitoEsame("E40", "VSSGRG04M20B111M", "Assente"),
      EsitoEsame("E45", "PRSCST04H03A345V", "Idoneo"),
      EsitoEsame("E46", "PRSCST04H03A345V", "Idoneo")
    ];

    final prenotazioniIniziali = [
      PrenotazioneEsame("E03", "BNCGLI12B14F205C"),
      PrenotazioneEsame("E21", "SPSSFO12D10G444X"),
      PrenotazioneEsame("E21", "RCCLND11E05H501B"),
      PrenotazioneEsame("E39", "MRNRRA12F18L219Y"),
      PrenotazioneEsame("E07", "GRDMTN09D05G444U"),
      PrenotazioneEsame("E25", "RZZGRL10E20H501V"),
      PrenotazioneEsame("E25", "LMBSRA09F14L219W"),
      PrenotazioneEsame("E43", "FNTFPP10M22B111Z"),
      PrenotazioneEsame("E09", "RSSSMN08E30H501E"),
      PrenotazioneEsame("E31", "LNGJCP06M19B111I"),
      PrenotazioneEsame("E15", "VLNLVC05A20H501U"),
      PrenotazioneEsame("E33", "PLMCRS98D28G444X"),
      PrenotazioneEsame("E11", "CPPDVD08C21D332M"),
      PrenotazioneEsame("E19", "FRRMHL06E14H501O"),
      PrenotazioneEsame("E29", "BNCMRT04G07F839Q"),
      PrenotazioneEsame("E37", "MRCDNL03H18A345R"),
      PrenotazioneEsame("E05", "DMCRRT94G04F839A"),
      PrenotazioneEsame("E27", "FRIPLA93A19H501E"),
      PrenotazioneEsame("E13", "RGGLSE97C14D332G"),
      PrenotazioneEsame("E47", "CRBRRT81D25G444H"),
      PrenotazioneEsame("E04", "RSSLNZ12A01H501A"),
      PrenotazioneEsame("E22", "FRRMTT11C22D332K"),
      PrenotazioneEsame("E40", "CSTNDR10C10D332T"),
      PrenotazioneEsame("E08", "DLCLSN10A15H501R"),
      PrenotazioneEsame("E26", "MNCCHR09B28F205S"),
      PrenotazioneEsame("E44", "BRBLNE09H11A345Y"),
      PrenotazioneEsame("E10", "DNGMIA07D03G444N"),
      PrenotazioneEsame("E50", "SRRRNN06B10F205L"),
      PrenotazioneEsame("E16", "NREGLC01F17L219J"),
      PrenotazioneEsame("E34", "BSSGRG04M20B111M"),
      PrenotazioneEsame("E34", "GRSCMN99A13H501O"),
      PrenotazioneEsame("E02", "RSSMRC08A12H501A"),
      PrenotazioneEsame("E12", "BNCFNC08B25F205B"),
      PrenotazioneEsame("E20", "CLMLCU07C04D332C"),
      PrenotazioneEsame("E30", "RMNLSS07D15G444D"),
      PrenotazioneEsame("E38", "GLLBRC06F12L219F"),
      PrenotazioneEsame("E46", "FBBLSS05F26L219P"),
      PrenotazioneEsame("E02", "GTTFRC00B02F205V"),
      PrenotazioneEsame("E12", "PRSCST04H03A345V"),
      PrenotazioneEsame("E20", "PLLLRI99C15D332W"),
      PrenotazioneEsame("E30", "SNNSNR97E09H501Y"),
      PrenotazioneEsame("E38", "PGLVNT08G28F839K"),
      PrenotazioneEsame("E46", "FLPMTT06H09A345L"),
      PrenotazioneEsame("E20", "LMBMNC96B24F205P"),
      PrenotazioneEsame("E30", "DNGVCN07C05D332Q"),
      PrenotazioneEsame("E06", "FRNLGU96F22L219Z"),
      PrenotazioneEsame("E14", "RVINNT91H15A345B"),
      PrenotazioneEsame("E18", "MNTVLR98M27B111C"),
      PrenotazioneEsame("E24", "MCLNRC86P08C222D"),
      PrenotazioneEsame("E42", "DSNSFN88B01F205F")
    ];

    final guideIniziali = [
      SlotGuida("G001", creaData("2026-05-04"), "08:00", "09:00", "Istruttore Mario", "B", "RSSMRC08A12H501A"),
      SlotGuida("G002", creaData("2026-05-04"), "13:00", "14:00", "Istruttore Luigi", "AM", "RSSLNZ12A01H501A"),
      SlotGuida("G003", creaData("2026-05-04"), "19:00", "20:00", "Istruttrice Giovanna", "A1", null),
      SlotGuida("G004", creaData("2026-05-05"), "08:00", "09:00", "Istruttore Mario", "B", "BNCFNC08B25F205B"),
      SlotGuida("G005", creaData("2026-05-05"), "13:00", "14:00", "Istruttore Luigi", "A1", "DLCLSN10A15H501R"),
      SlotGuida("G006", creaData("2026-05-05"), "19:00", "20:00", "Istruttrice Giovanna", "B", null),
      SlotGuida("G007", creaData("2026-05-06"), "08:00", "09:00", "Istruttore Mario", "C", "FRNLGU96F22L219Z"),
      SlotGuida("G008", creaData("2026-05-06"), "13:00", "14:00", "Istruttore Luigi", "B", "CLMLCU07C04D332C"),
      SlotGuida("G009", creaData("2026-05-06"), "19:00", "20:00", "Istruttrice Giovanna", "AM", null),
      SlotGuida("G010", creaData("2026-05-07"), "08:00", "09:00", "Istruttore Mario", "B", "RMNLSS07D15G444D"),
      SlotGuida("G011", creaData("2026-05-07"), "13:00", "14:00", "Istruttore Luigi", "A2", "RSSSMN08E30H501E"),
      SlotGuida("G012", creaData("2026-05-07"), "19:00", "20:00", "Istruttrice Giovanna", "B", "FBBLSS05F26L219P"),
      SlotGuida("G013", creaData("2026-05-08"), "08:00", "09:00", "Istruttore Mario", "B", null),
      SlotGuida("G014", creaData("2026-05-08"), "13:00", "14:00", "Istruttore Luigi", "AM", "CSTNDR10C10D332T"),
      SlotGuida("G015", creaData("2026-05-08"), "19:00", "20:00", "Istruttrice Giovanna", "B", "GLLBRC06F12L219F"),
      SlotGuida("G016", creaData("2026-05-09"), "08:00", "09:00", "Istruttore Mario", "B", "MRTPTR08G22F839G"),
      SlotGuida("G017", creaData("2026-05-09"), "13:00", "14:00", "Istruttore Luigi", "A", "VLNLVC05A20H501U"),
      SlotGuida("G018", creaData("2026-05-09"), "19:00", "20:00", "Istruttrice Giovanna", "B", null),
      SlotGuida("G019", creaData("2026-05-11"), "08:00", "09:00", "Istruttore Mario", "B", "RSSMRC08A12H501A"),
      SlotGuida("G020", creaData("2026-05-11"), "13:00", "14:00", "Istruttore Luigi", "AM", null),
      SlotGuida("G021", creaData("2026-05-11"), "19:00", "20:00", "Istruttrice Giovanna", "B", "BNCFNC08B25F205B"),
      SlotGuida("G022", creaData("2026-05-12"), "08:00", "09:00", "Istruttore Mario", "A1", "MNCCHR09B28F205S"),
      SlotGuida("G023", creaData("2026-05-12"), "13:00", "14:00", "Istruttore Luigi", "B", null),
      SlotGuida("G024", creaData("2026-05-12"), "19:00", "20:00", "Istruttrice Giovanna", "CE", "MNTVLR98M27B111C"),
      SlotGuida("G025", creaData("2026-05-13"), "08:00", "09:00", "Istruttore Mario", "B", "GTTFRC00B02F205V"),
      SlotGuida("G026", creaData("2026-05-13"), "13:00", "14:00", "Istruttore Luigi", "A2", "LNGJCP06M19B111I"),
      SlotGuida("G027", creaData("2026-05-13"), "19:00", "20:00", "Istruttrice Giovanna", "B", null),
      SlotGuida("G028", creaData("2026-05-14"), "08:00", "09:00", "Istruttore Mario", "B", "PRSCST04H03A345V"),
      SlotGuida("G029", creaData("2026-05-14"), "13:00", "14:00", "Istruttore Luigi", "A1", "BRBLNE09H11A345Y"),
      SlotGuida("G030", creaData("2026-05-14"), "19:00", "20:00", "Istruttrice Giovanna", "C", null),
      SlotGuida("G031", creaData("2026-05-15"), "08:00", "09:00", "Istruttore Mario", "B", "PLLLRI99C15D332W"),
      SlotGuida("G032", creaData("2026-05-15"), "13:00", "14:00", "Istruttore Luigi", "AM", "FRRMTT11C22D332K"),
      SlotGuida("G033", creaData("2026-05-15"), "19:00", "20:00", "Istruttrice Giovanna", "B", "SNNSNR97E09H501Y"),
      SlotGuida("G034", creaData("2026-05-16"), "08:00", "09:00", "Istruttore Mario", "B", null),
      SlotGuida("G035", creaData("2026-05-16"), "13:00", "14:00", "Istruttore Luigi", "B", "PGLVNT08G28F839K"),
      SlotGuida("G036", creaData("2026-05-16"), "19:00", "20:00", "Istruttrice Giovanna", "A", "NREGLC01F17L219J"),
      SlotGuida("G037", creaData("2026-05-18"), "08:00", "09:00", "Istruttore Mario", "B", "FLPMTT06H09A345L"),
      SlotGuida("G038", creaData("2026-05-18"), "13:00", "14:00", "Istruttore Luigi", "AM", null),
      SlotGuida("G039", creaData("2026-05-18"), "19:00", "20:00", "Istruttrice Giovanna", "B", "LMBMNC96B24F205P"),
      SlotGuida("G040", creaData("2026-05-19"), "08:00", "09:00", "Istruttore Mario", "B", "DNGVCN07C05D332Q"),
      SlotGuida("G041", creaData("2026-05-19"), "13:00", "14:00", "Istruttore Luigi", "D", "RVINNT91H15A345B"),
      SlotGuida("G042", creaData("2026-05-19"), "19:00", "20:00", "Istruttrice Giovanna", "A1", null),
      SlotGuida("G043", creaData("2026-05-20"), "08:00", "09:00", "Istruttore Mario", "B", "RSSMRC08A12H501A"),
      SlotGuida("G044", creaData("2026-05-20"), "13:00", "14:00", "Istruttore Luigi", "B", null),
      SlotGuida("G045", creaData("2026-05-20"), "19:00", "20:00", "Istruttrice Giovanna", "DE", "MCLNRC86P08C222D"),
      SlotGuida("G046", creaData("2026-05-21"), "08:00", "09:00", "Istruttore Mario", "A", "BSSGRG04M20B111M"),
      SlotGuida("G047", creaData("2026-05-21"), "13:00", "14:00", "Istruttore Luigi", "B", "CLMLCU07C04D332C"),
      SlotGuida("G048", creaData("2026-05-21"), "19:00", "20:00", "Istruttrice Giovanna", "B", null),
      SlotGuida("G049", creaData("2026-05-22"), "08:00", "09:00", "Istruttore Mario", "B", "RMNLSS07D15G444D"),
      SlotGuida("G050", creaData("2026-05-22"), "13:00", "14:00", "Istruttore Luigi", "A2", "DNGMIA07D03G444N"),
      SlotGuida("G051", creaData("2026-05-22"), "19:00", "20:00", "Istruttrice Giovanna", "CE", "DSNSFN88B01F205F"),
      SlotGuida("G052", creaData("2026-05-23"), "08:00", "09:00", "Istruttore Mario", "B", null),
      SlotGuida("G053", creaData("2026-05-23"), "13:00", "14:00", "Istruttore Luigi", "A", "GRSCMN99A13H501O"),
      SlotGuida("G054", creaData("2026-05-23"), "19:00", "20:00", "Istruttrice Giovanna", "B", "GLLBRC06F12L219F"),
      SlotGuida("G055", creaData("2026-05-25"), "08:00", "09:00", "Istruttore Mario", "B", null),
      SlotGuida("G056", creaData("2026-05-25"), "13:00", "14:00", "Istruttore Luigi", "A2", "SRRRNN06B10F205L"),
      SlotGuida("G057", creaData("2026-05-25"), "19:00", "20:00", "Istruttrice Giovanna", "B", "MRTPTR08G22F839G"),
      SlotGuida("G058", creaData("2026-05-26"), "08:00", "09:00", "Istruttore Mario", "B", "FBBLSS05F26L219P"),
      SlotGuida("G059", creaData("2026-05-26"), "13:00", "14:00", "Istruttore Luigi", "AM", null),
      SlotGuida("G060", creaData("2026-05-26"), "19:00", "20:00", "Istruttrice Giovanna", "A1", "DLCLSN10A15H501R"),
      SlotGuida("G061", creaData("2026-05-27"), "08:00", "09:00", "Istruttore Mario", "B", null),
      SlotGuida("G062", creaData("2026-05-27"), "13:00", "14:00", "Istruttore Luigi", "B", "BNCFNC08B25F205B"),
      SlotGuida("G063", creaData("2026-05-27"), "19:00", "20:00", "Istruttrice Giovanna", "C", "FRNLGU96F22L219Z"),
      SlotGuida("G064", creaData("2026-05-28"), "08:00", "09:00", "Istruttore Mario", "B", "GTTFRC00B02F205V"),
      SlotGuida("G065", creaData("2026-05-28"), "13:00", "14:00", "Istruttore Luigi", "A", null),
      SlotGuida("G066", creaData("2026-05-28"), "19:00", "20:00", "Istruttrice Giovanna", "B", "PRSCST04H03A345V"),
      SlotGuida("G067", creaData("2026-05-29"), "08:00", "09:00", "Istruttore Mario", "B", "PLLLRI99C15D332W"),
      SlotGuida("G068", creaData("2026-05-29"), "13:00", "14:00", "Istruttore Luigi", "B", null),
      SlotGuida("G069", creaData("2026-05-29"), "19:00", "20:00", "Istruttrice Giovanna", "B", "SNNSNR97E09H501Y"),
      SlotGuida("G070", creaData("2026-05-30"), "08:00", "09:00", "Istruttore Mario", "B", "PGLVNT08G28F839K"),
      SlotGuida("G071", creaData("2026-05-30"), "13:00", "14:00", "Istruttore Luigi", "A1", null),
      SlotGuida("G072", creaData("2026-05-30"), "19:00", "20:00", "Istruttrice Giovanna", "B", "FLPMTT06H09A345L"),
      SlotGuida("G073", creaData("2026-06-01"), "08:00", "09:00", "Istruttore Mario", "B", "LMBMNC96B24F205P"),
      SlotGuida("G074", creaData("2026-06-01"), "13:00", "14:00", "Istruttore Luigi", "B", null),
      SlotGuida("G075", creaData("2026-06-01"), "19:00", "20:00", "Istruttrice Giovanna", "B", "DNGVCN07C05D332Q"),
      SlotGuida("G076", creaData("2026-06-02"), "08:00", "09:00", "Istruttore Mario", "A", "NREGLC01F17L219J"),
      SlotGuida("G077", creaData("2026-06-02"), "13:00", "14:00", "Istruttore Luigi", "B", "RSSMRC08A12H501A"),
      SlotGuida("G078", creaData("2026-06-02"), "19:00", "20:00", "Istruttrice Giovanna", "AM", null),
      SlotGuida("G079", creaData("2026-06-03"), "08:00", "09:00", "Istruttore Mario", "B", "CLMLCU07C04D332C"),
      SlotGuida("G080", creaData("2026-06-03"), "13:00", "14:00", "Istruttore Luigi", "A2", null),
      SlotGuida("G081", creaData("2026-06-03"), "19:00", "20:00", "Istruttrice Giovanna", "B", "RMNLSS07D15G444D"),
      SlotGuida("G082", creaData("2026-06-04"), "08:00", "09:00", "Istruttore Mario", "B", "GLLBRC06F12L219F"),
      SlotGuida("G083", creaData("2026-06-04"), "13:00", "14:00", "Istruttore Luigi", "B", null),
      SlotGuida("G084", creaData("2026-06-04"), "19:00", "20:00", "Istruttrice Giovanna", "B", "FBBLSS05F26L219P"),
      SlotGuida("G085", creaData("2026-06-05"), "08:00", "09:00", "Istruttore Mario", "A", null),
      SlotGuida("G086", creaData("2026-06-05"), "13:00", "14:00", "Istruttore Luigi", "B", "PRSCST04H03A345V"),
      SlotGuida("G087", creaData("2026-06-05"), "19:00", "20:00", "Istruttrice Giovanna", "B", "PLLLRI99C15D332W"),
      SlotGuida("G088", creaData("2026-06-06"), "08:00", "09:00", "Istruttore Mario", "B", "SNNSNR97E09H501Y"),
      SlotGuida("G089", creaData("2026-06-06"), "13:00", "14:00", "Istruttore Luigi", "C", null),
      SlotGuida("G090", creaData("2026-06-06"), "19:00", "20:00", "Istruttrice Giovanna", "B", "PGLVNT08G28F839K")
    ];

    // Salvataggio nel DB
    for (var l in lezioniIniziali) {
      await db.collection("lezioni").doc(l.idLezione).set(l.toFirestore());
    }

    for (var e in esamiIniziali) {
      await db.collection("esami").doc(e.idEsame).set(e.toFirestore());
    }

    for (var g in guideIniziali) {
      await db.collection("slot_guide").doc(g.idGuida).set(g.toFirestore());
    }

    for (var esito in esitiIniziali) {
      await db.collection("esiti_esami").doc("${esito.idEsame}_${esito.codiceFiscale}").set(esito.toFirestore());
    }

    for (var p in prenotazioniIniziali) {
      await db.collection("prenotazioni_esami").doc("${p.idEsame}_${p.codiceFiscale}").set(p.toFirestore());
    }

    print("Database popolato con successo!");
  }
}
