import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'view/schermata_login.dart';
import 'view/schermata_registrazione.dart';
import 'view/main_screen.dart';
import 'view_model/utente_view_model.dart';
import 'view_model/calendario_view_model.dart';
import 'view_model/esiti_view_model.dart';
import 'view_model/prenota_view_model.dart';
import 'repository/utente_repository.dart';
import 'repository/connectivity_checker_impl.dart';
import 'data/preferences_repository.dart';

//Punto di ingresso principale dell'applicazione Flutter
void main() async {
  //Inizializzo i binding di sistema e configuro Firebase (fondamentale per Auth e Firestore)
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  //Configuro il supporto alla localizzazione italiana per la formattazione delle date
  await initializeDateFormatting('it_IT', null);

  //Istanzio la repository che verrà condivisa tra tutti i ViewModel (Pattern Dependency Injection)
  final repository = UtenteRepository();
  
  runApp(
    /*Utilizzo MultiProvider per iniettare le dipendenze logiche a livello globale
    Ogni ViewModel viene creato una sola volta e reso accessibile da qualsiasi widget dell'app*/
    MultiProvider(
      providers: [
        //ViewModel utente: gestisce autenticazione, persistenza locale e stato della connessione
        ChangeNotifierProvider(
          create: (_) => UtenteViewModel(
            repository: repository,
            userPrefs: PreferencesRepository(),
            networkChecker: ConnectivityCheckerImpl(),
          ),
        ),
        //ViewModel per la gestione degli eventi del calendario (Lezioni ed Esami)
        ChangeNotifierProvider(
          create: (_) => CalendarioViewModel(repository: repository, networkChecker: ConnectivityCheckerImpl()),
        ),
        //ViewModel per la visualizzazione dello storico degli esiti
        ChangeNotifierProvider(
          create: (_) => EsitiViewModel(repository: repository, networkChecker: ConnectivityCheckerImpl()),
        ),
        //ViewModel dedicato alla logica di prenotazione di nuovi appelli o guide
        ChangeNotifierProvider(
          create: (_) => PrenotaViewModel(repository: repository, networkChecker: ConnectivityCheckerImpl()),
        ),
      ],
      //L'intera applicazione (MyApp) è il widget figlio che può usufruire dei provider definiti sopra
      child: const MyApp(),
    ),
  );
}

//Widget root dell'app che configura il tema Material Design e il sistema di navigazione
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drive App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      //Configurazione delegati per tradurre i widget standard di Flutter (es. calendari, menu) in italiano
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('it', 'IT'),
      ],
      locale: const Locale('it', 'IT'),
      //Avviamo il RootNavigator che deciderà quale schermata mostrare (Login o Home)
      home: const RootNavigator(),
    );
  }
}

//Gestore della navigazione principale che reagisce allo stato dell'autenticazione utente
class RootNavigator extends StatefulWidget {
  const RootNavigator({super.key});

  @override
  State<RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<RootNavigator> {
  //Stato locale per switchare graficamente tra Login e Registrazione
  bool mostraRegistrazione = false;

  @override
  Widget build(BuildContext context) {
    //Reagiamo istantaneamente ai cambiamenti del ViewModel dell'utente loggato
    return Consumer<UtenteViewModel>(
      builder: (context, viewModel, child) {
        //Visualizzazione indicatore di caricamento durante il ripristino della sessione all'avvio
        if (viewModel.caricamentoIniziale) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        //Gestione specifica dell'errore di connessione persistente che blocca l'operatività iniziale
        if (viewModel.erroreConnessione) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      "Connessione Assente",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "L'app ha bisogno di internet per mantenere i dati aggiornati. Controlla la tua connessione e riprova.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    //Pulsante per forzare un nuovo tentativo di collegamento al server
                    ElevatedButton(
                      onPressed: () => viewModel.riprovaConnessione(),
                      child: const Text("RIPROVA"),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        //Se i dati dell'utente sono presenti (anche caricati offline per RNF5), mostra la dashboard
        if (viewModel.utenteLoggato != null) {
          return const MainScreen();
        }

        //In assenza di login, mostra il flusso di autenticazione con animazione fluida tra le due schermate
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: mostraRegistrazione
              ? SchermataRegistrazione(
                  key: const ValueKey('Registrazione'),
                  onTornaAlLogin: () => setState(() => mostraRegistrazione = false),
                )
              : SchermataLogin(
                  key: const ValueKey('Login'),
                  onVaiARegistrazione: () => setState(() => mostraRegistrazione = true),
                ),
        );
      },
    );
  }
}
