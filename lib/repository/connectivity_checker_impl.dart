import 'package:connectivity_plus/connectivity_plus.dart';
import 'connectivity_checker.dart';

//Implementazione concreta del controllo di rete tramite il pacchetto connectivity_plus
class ConnectivityCheckerImpl implements ConnectivityChecker {
  @override
  //Richiama le API di sistema per verificare se il dispositivo ha accesso a internet (WiFi o Dati Mobili)
  Future<bool> isInternetAvailable() async {
    //Ottiene la lista dei risultati di connettività attuali
    final List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();

    // Se la lista contiene solo 'none' o risulta vuota, consideriamo il dispositivo offline
    if (connectivityResult.isEmpty ||
        connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }

    // Altrimenti, se è presente almeno una modalità di connessione attiva, restituiamo true
    return true;
  }
}
