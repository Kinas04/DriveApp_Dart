import 'package:connectivity_plus/connectivity_plus.dart';
import 'ConnectivityChecker.dart';

class ConnectivityCheckerImpl implements ConnectivityChecker {
  @override
  //Richiamo qui l'interfaccia e verifico effettivamente la connessione
  Future<bool> isInternetAvailable() async {
    final List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();

    // Se la lista contiene 'none' o è vuota, non c'è connessione
    if (connectivityResult.isEmpty || connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }
    
    // Altrimenti, se c'è almeno un elemento che non sia 'none', c'è connessione
    return true;
  }
}
