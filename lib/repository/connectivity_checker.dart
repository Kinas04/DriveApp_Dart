//Interfaccia che definisce il metodo per il controllo dello stato della connessione di rete
abstract class ConnectivityChecker {
  //restituisce un valore booleano che indica se la connessione internet è attualmente disponibile
  Future<bool> isInternetAvailable();
}
