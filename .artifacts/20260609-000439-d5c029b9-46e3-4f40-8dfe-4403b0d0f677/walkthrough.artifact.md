# Riepilogo Interventi e Risoluzione Problematiche

Ho completato la revisione totale del progetto, risolvendo tutti i bug segnalati e migliorando la qualità complessiva del codice.

## 1. Sicurezza e Persistenza Offline (RNF5)
- **Password**: Rimosso definitivamente il campo `password` dal modello `Utente` e dai salvataggi su Firestore.
- **Dati Locali**: Implementato il salvataggio dell'oggetto `Utente` in formato JSON nelle preferenze locali.
- **Accesso Offline**: L'app ora carica i dati locali all'avvio se Firebase Auth ha una sessione attiva ma non c'è connessione internet.

## 2. Esperienza Utente (UX)
- **Bug Cursore**: Risolto il problema del cursore che saltava all'inizio durante la digitazione in Login e Registrazione (Nome, Cognome, CF). Ora la formattazione avviene mantenendo la selezione.
- **Dropdown**: Corretti i parametri in `DropdownButtonFormField` (da `initialValue` a `value`).
- **Icone Calendario**: Sostituite le icone generiche con icone semantiche: `school` (Lezioni), `assignment_turned_in` (Esami) e `directions_car` (Guide).
- **Scroll Login**: Rimossi i `SingleChildScrollView` annidati per uno scorrimento più fluido.

## 3. Qualità del Codice e Refactoring
- **Record Dart 3**: Sostituita la classe `Oggetti2` con la sintassi nativa dei Record `(bool, String)`.
- **Memory Leaks**: Aggiunti i metodi `dispose()` per tutti i `TextEditingController` nelle varie schermate.
- **Firme Async**: Modificati i metodi `logout()` e `_cambiaPassword` da `void` a `Future<void>` per una corretta gestione delle attese.
- **Formattazione**: Ripulita la formattazione anomala nei file `preferences_repository.dart` e `connectivity_checker.dart`.

## 4. Configurazione Progetto
- **Application ID**: Aggiornato in `it.univpm.driveapp`.
- **Allineamento Git**: Tutti i file sono ora correttamente tracciati su GitHub con i nomi in `snake_case`.

Le modifiche sono state testate per garantire la stabilità dell'applicazione in ogni scenario d'uso (Online/Offline).
