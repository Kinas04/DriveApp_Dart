import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../view_model/utente_view_model.dart';
import '../view_model/esiti_view_model.dart';
import '../model/esito_esame.dart';
import '../model/esame.dart';

//Schermata che visualizza lo storico dei risultati ottenuti dall'utente negli esami sostenuti
class SchermataEsiti extends StatefulWidget {
  const SchermataEsiti({super.key});

  @override
  State<SchermataEsiti> createState() => _SchermataEsitiState();
}

class _SchermataEsitiState extends State<SchermataEsiti> {
  //Liste locali per memorizzare gli esiti e i dettagli degli esami associati
  List<EsitoEsame> _esiti = [];
  Map<String, Esame> _dettagliEsami = {};
  
  bool _inCaricamento = true;
  bool _erroreCaricamento = false;

  @override
  void initState() {
    super.initState();
    //richiediamo i dati al database non appena la schermata viene inizializzata e il contesto è pronto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _caricaDati();
    });
  }

  /*chiamata al ViewModel per recuperare lo storico degli esiti dell'utente.
  La logica prevede il recupero degli esiti e successivamente dei dettagli di ogni esame coinvolto*/
  Future<void> _caricaDati() async {
    final utenteViewModel = Provider.of<UtenteViewModel>(context, listen: false);
    final esitiViewModel = Provider.of<EsitiViewModel>(context, listen: false);
    
    final cf = utenteViewModel.utenteLoggato?.codiceFiscale;
    if (cf == null) return;

    //Attiviamo lo stato di caricamento grafico
    setState(() {
      _inCaricamento = true;
      _erroreCaricamento = false; //Reset di eventuali errori precedenti
    });

    await esitiViewModel.caricaEsiti(cf, (esiti, dettagli, errore) {
      //Verifico che l'utente non abbia lasciato la pagina durante l'attesa della risposta dal server
      if (mounted) {
        setState(() {
          _esiti = esiti;
          _dettagliEsami = dettagli;
          _erroreCaricamento = errore;
          _inCaricamento = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Titolo della sezione con padding dedicato
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text(
                "Esiti esami",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            //Il contenuto della lista occupa tutto lo spazio rimanente
            Expanded(child: _buildContenuto()),
          ],
        ),
      ),
    );
  }

  //gestisce la visualizzazione condizionale: indicatore di caricamento, messaggio di errore o lista dati
  Widget _buildContenuto() {
    if (_inCaricamento) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erroreCaricamento) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Errore durante il caricamento degli esiti", style: TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _caricaDati, child: const Text("RIPROVA")),
          ],
        ),
      );
    }

    //Messaggio mostrato se l'utente non ha ancora sostenuto alcun esame
    if (_esiti.isEmpty) {
      return const Center(
        child: Text("Nessun esito disponibile", style: TextStyle(color: Colors.black54)),
      );
    }

    //Rendering della lista degli esiti con spaziatura tra le card
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _esiti.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final esito = _esiti[index];
        final esame = _dettagliEsami[esito.idEsame];
        
        //Determiniamo se l'utente è stato idoneo per scegliere l'icona e il colore della card
        final isPromosso = esito.esito.toLowerCase() == "idoneo" || esito.esito.toLowerCase() == "promosso";
        
        final formatData = DateFormat('EEE d MMM', 'it_IT');
        final stringaDataLuogo = esame != null 
            ? "${formatData.format(esame.data)}, ${esame.luogo}" 
            : "Data non disponibile";

        //Costruiamo la card grafica per il singolo esito
        return _buildEsitoCard(
          context,
          isPromosso: isPromosso,
          titolo: esito.esito.toUpperCase(),
          esame: esame != null ? "Esame ${esame.tipologia}" : "Esame sconosciuto",
          patente: esame != null ? "Patente ${esame.categoriaPatente}" : "",
          dataLuogo: stringaDataLuogo,
          color: isPromosso ? const Color(0xFFDEE1F3) : const Color(0xFFF9F1F7),
          onVedi: () {
            if (esame != null) {
              _mostraDettagliEsame(context, esito, esame);
            }
          },
        );
      },
    );
  }

  //mostra un popup (Dialog) con le informazioni dettagliate dell'appello d'esame selezionato
  void _mostraDettagliEsame(BuildContext context, EsitoEsame esito, Esame esame) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Dettaglio Esame ${esame.tipologia}"),
        //Uso SingleChildScrollView per evitare overflow grafici in modalità orizzontale (landscape)
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Categoria: Patente ${esame.categoriaPatente}"),
              Text("Data: ${DateFormat('dd/MM/yyyy').format(esame.data)}"),
              Text("Orario: ${esame.oraInizio} - ${esame.oraFine}"),
              Text("Luogo: ${esame.luogo}"),
              const Divider(height: 24),
              Text(
                "ESITO: ${esito.esito.toUpperCase()}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: (esito.esito.toLowerCase() == "idoneo" || esito.esito.toLowerCase() == "promosso")
                      ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
        actions: [
          //Pulsante per chiudere il popup informativo
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CHIUDI"),
          ),
        ],
      ),
    );
  }

  //costruisce la card grafica contenente l'anteprima dell'esito (es. Promosso/Respinto)
  Widget _buildEsitoCard(
    BuildContext context, {
    required bool isPromosso,
    required String titolo,
    required String esame,
    required String patente,
    required String dataLuogo,
    required Color color,
    required VoidCallback onVedi,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Icona di stato: spunta per idoneo, croce per respinto
          Icon(
            isPromosso ? Icons.check : Icons.close,
            size: 24,
            color: Colors.black87,
          ),
          const SizedBox(width: 16),
          //Colonna centrale con i testi descrittivi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titolo,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                if (patente.isNotEmpty)
                  Text(
                    patente,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  esame,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dataLuogo,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          //Pulsante interattivo per aprire la modale con tutti i dettagli
          InkWell(
            onTap: onVedi,
            child: const Row(
              children: [
                Text(
                  "Vedi",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_right, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
