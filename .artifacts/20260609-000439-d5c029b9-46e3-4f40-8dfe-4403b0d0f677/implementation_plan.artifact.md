# Piano di Risoluzione Bug e Miglioramento Qualità

Questo piano delinea le azioni per risolvere i bug identificati, migliorare la sicurezza e allineare il codice alle best practice di Flutter/Dart.

## User Review Required

- **Filtro Guide**: Confermo che verranno mostrate solo le guide libere (`utentePrenotato == null`) o già prenotate dall'utente loggato.
- **Icone Calendario**: Sostituirò `chat_bubble_outline` con icone semantiche (es. `school`, `event`, `directions_car`).

## Proposed Changes

### Sicurezza e Logica di Business

#### [utente.dart](file:///C:/App_Mobile/DriveApp_Dart/lib/model/utente.dart)
- Verificato: il campo `password` **non è presente** nel modello attuale, quindi non viene salvato su Firestore. Problema già risolto.

#### [utente_view_model.dart](file:///C:/App_Mobile/DriveApp_Dart/lib/view_model/utente_view_model.dart)
- Modifica firma `logout()` in `Future<void>`.
- Aggiunta verifica `auth.currentUser != null` in `_inizializza` prima di caricare i dati.
- Refactor `Oggetti2` usando i `Record` di Dart 3 per una sintassi più moderna.

#### [prenota_view_model.dart](file:///C:/App_Mobile/DriveApp_Dart/lib/view_model/prenota_view_model.dart)
- [GIÀ FATTO] Il filtro per mostrare solo le guide libere o proprie è già presente.

---

### Interfaccia Utente (UI) e Bug UX

#### [schermata_login.dart](file:///C:/App_Mobile/DriveApp_Dart/lib/view/schermata_login.dart)
- Fix cursore CF: applicazione formattazione tramite `TextSelection`.
- Rimozione `SingleChildScrollView` ridondante nel layout compatto.
- Aggiunta `dispose()` per i controller.

#### [schermata_registrazione.dart](file:///C:/App_Mobile/DriveApp_Dart/lib/view/schermata_registrazione.dart)
- Fix cursore per Nome, Cognome e CF.
- Sostituzione `initialValue` con `value` in `DropdownButtonFormField`.
- Aggiunta `dispose()` per i controller.

#### [schermata_sicurezza.dart](file:///C:/App_Mobile/DriveApp_Dart/lib/view/schermata_sicurezza.dart)
- Modifica firma `_cambiaPassword` in `Future<void>`.
- Aggiunta `dispose()` per i controller.

#### [schermata_calendario.dart](file:///C:/App_Mobile/DriveApp_Dart/lib/view/schermata_calendario.dart)
- Sostituzione icona generica con icone specifiche per Lezioni, Esami e Guide.

---

### Refactoring e Formattazione

#### [preferences_repository.dart](file:///C:/App_Mobile/DriveApp_Dart/lib/data/preferences_repository.dart)
#### [connectivity_checker.dart](file:///C:/App_Mobile/DriveApp_Dart/lib/repository/connectivity_checker.dart)
#### [connectivity_checker_impl.dart](file:///C:/App_Mobile/DriveApp_Dart/lib/repository/connectivity_checker_impl.dart)
- Allineamento formattazione (rimozione line break anomali).

## Verification Plan

### Manual Verification
- **Test UX**: Verificare che scrivendo il CF o il Nome il cursore non torni all'inizio.
- **Test Sicurezza**: Verificare che il logout sia completato prima della navigazione.
- **Test Navigazione**: Verificare il corretto switch tra le tab del calendario con le nuove icone.
- **Test Offline**: Confermare che con sessione Firebase scaduta (simulando null su currentUser) l'app chieda il login anche se il CF è salvato.
