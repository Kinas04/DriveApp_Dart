import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'view/SchermataLogin.dart';
import 'view/SchermataRegistrazione.dart';
import 'view/MainScreen.dart';
import 'viewModel/UtenteViewModel.dart';
import 'viewModel/CalendarioViewModel.dart';
import 'viewModel/EsitiViewModel.dart';
import 'viewModel/PrenotaViewModel.dart';
import 'repository/UtenteRepository.dart';
import 'repository/ConnectivityCheckerImpl.dart';
import 'data/PreferenzeUtente.dart';

void main() async {
  //Come prima cosa, inizializzo Firebase (FONDAMENTALE) e la formattazione italiana prevista per i nostri scopi
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('it_IT', null);

  //Inizializzo una variabile immutabile (final) che fa riferimento alla repository dell'utente
  final repository = UtenteRepository();
  
  runApp(
    /*Quando avviamo l'app, con Multiprovider iniettiamo contemporaneamente diversi oggetti
    che corrispondono in questo caso ai vari ViewModel
    ogni ChangeNotifier crea un'istanza di questi view model (per ognuna, tranne per utente, è
    sufficiente passare il riferimento alla repository condivisa tra le stesse. Utente richiede
    più parametri tra cui le sue preferenze e il check per la connessione
    Viene creato quindi un albero di widget*/
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UtenteViewModel(
            repository: repository,
            userPrefs: PreferencesRepository(),
            networkChecker: ConnectivityCheckerImpl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CalendarioViewModel(repository: repository),
        ),
        ChangeNotifierProvider(
          create: (_) => EsitiViewModel(repository: repository),
        ),
        ChangeNotifierProvider(
          create: (_) => PrenotaViewModel(repository: repository),
        ),
      ],
      /*Alla fine decidiamo il widget FIGLIO che accede al resto dell'albero
      In questo caso tutta l'app, quindi qualsiasi schermata può recuperare i viewmodel */
      child: const MyApp(),
    ),
  );
}

/*Quindi, come si vede anche nelle varie schermate, utilizzando il contesto è possibile "navigare" verso le altre pagine
con "push e pull" a seconda se è necessario entrare in schermata o uscire (es. tasto chiudi, esci...) */

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
      //Serve al calendario per avere i mesi in italiano
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('it', 'IT'),
      ],
      locale: const Locale('it', 'IT'),
      home: const RootNavigator(),
    );
  }
}

class RootNavigator extends StatefulWidget {
  const RootNavigator({super.key});

  @override
  State<RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<RootNavigator> {
  bool mostraRegistrazione = false;

  @override
  Widget build(BuildContext context) {
    // Usiamo la funzione Consumer per reagire ai cambiamenti del ViewModel, passandolo come tipo
    return Consumer<UtenteViewModel>(
      builder: (context, viewModel, child) {
        //Schermata di caricamento iniziale
        if (viewModel.caricamentoIniziale) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        //Se c'è un errore di connessione persistente all'avvio
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

        //Se l'utente è loggato correttamente, mostra la schermata principale
        if (viewModel.utenteLoggato != null) {
          return const MainScreen();
        }

        /* Flusso di Autenticazione:
        ALl'interno abbiamo due listener che portano rispettivamente alla schermata di registrazione o login
        in base al valore di mostraRegistrazione, si riesce a switchare tra le due schermate*/
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
