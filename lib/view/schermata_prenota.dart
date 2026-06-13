import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../view_model/utente_view_model.dart';
import '../view_model/prenota_view_model.dart';
import '../model/esame.dart';
import '../model/slot_guida.dart';

//Schermata che permette all'utente di visualizzare e prenotare nuovi appelli d'esame o guide pratiche
class SchermataPrenota extends StatefulWidget {
  //Callback facoltativa per l'apertura del menu laterale (usata su Tablet)
  final VoidCallback? onMenuClick;
  const SchermataPrenota({super.key, this.onMenuClick});

  @override
  State<SchermataPrenota> createState() => _SchermataPrenotaState();
}

class _SchermataPrenotaState extends State<SchermataPrenota> with TickerProviderStateMixin {
  //Controller per la gestione dei due tab principali (Esami e Guide)
  late TabController _tabController;

  //Liste locali per memorizzare i dati ricevuti dal database
  List<Esame> _listaEsami = [];
  List<SlotGuida> _listaGuide = [];
  
  //Insieme di identificativi per tracciare quali elementi l'utente ha già prenotato
  Set<String> _elementiPrenotati = {};
  
  bool _inCaricamento = true;
  bool _erroreCaricamento = false;
  
  //Flag per gestire lo stato di attesa durante la scrittura sul database
  bool _inPrenotazione = false;

  @override
  void initState() {
    super.initState();
    //Inizializziamo il TabController per gestire lo switch tra le due categorie di prenotazione
    _tabController = TabController(length: 2, vsync: this);
    
    //Aggiungiamo un listener per ricaricare i dati ogni volta che l'utente cambia tab
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _caricaDati();
      }
    });

    //Avviamo il caricamento iniziale dei dati non appena il frame è pronto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _caricaDati();
    });
  }

  @override
  void dispose() {
    //Liberiamo le risorse del controller quando la schermata viene chiusa
    _tabController.dispose();
    super.dispose();
  }

  //chiamata al ViewModel per caricare le liste degli elementi prenotabili filtrati per l'utente loggato
  Future<void> _caricaDati() async {
    final utenteViewModel = Provider.of<UtenteViewModel>(context, listen: false);
    final prenotaViewModel = Provider.of<PrenotaViewModel>(context, listen: false);

    final utente = utenteViewModel.utenteLoggato;
    if (utente == null) return;

    //Attiviamo l'indicatore di caricamento a video
    setState(() {
      _inCaricamento = true;
      _erroreCaricamento = false;
    });

    //Recuperiamo gli elementi disponibili dal database tramite il ViewModel dedicato
    await prenotaViewModel.caricaElementiPrenotabili(
      utente.categoriaRichiesta,
      utente.codiceFiscale,
      _tabController.index,
      (esami, guide, prenotati, errore) {
        //controllo mounted per evitare errori se l'utente cambia pagina durante il caricamento
        if (mounted) {
          setState(() {
            _listaEsami = esami;
            _listaGuide = guide;
            _elementiPrenotati = prenotati;
            _erroreCaricamento = errore;
            _inCaricamento = false;
          });
        }
      },
    );
  }

  //mostra un popup (Dialog) di avviso per chiedere conferma definitiva prima di salvare la prenotazione
  void _mostraPopupConferma(String id) {
    showDialog(
      context: context,
      barrierDismissible: !_inPrenotazione, //Impedisce la chiusura accidentale durante il salvataggio
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Conferma Prenotazione"),
            content: const Text("Vuoi confermare la prenotazione per questo elemento?"),
            actions: [
              //Pulsante per annullare l'operazione e chiudere il dialog
              TextButton(
                onPressed: _inPrenotazione ? null : () => Navigator.pop(context),
                child: const Text("ANNULLA"),
              ),
              //Pulsante per procedere con la prenotazione effettiva
              TextButton(
                onPressed: _inPrenotazione ? null : () async {
                  setDialogState(() => _inPrenotazione = true);
                  
                  final utenteViewModel = Provider.of<UtenteViewModel>(context, listen: false);
                  final prenotaViewModel = Provider.of<PrenotaViewModel>(context, listen: false);

                  final cf = utenteViewModel.utenteLoggato?.codiceFiscale;
                  if (cf == null) return;

                  //Invio della richiesta di prenotazione al server
                  await prenotaViewModel.prenotaElemento(
                    _tabController.index,
                    id,
                    cf,
                    (successo, messaggio) {
                      //evito errori se l'utente chiude il popup o cambia pagina durante la prenotazione
                      if (mounted) {
                        setDialogState(() => _inPrenotazione = false);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(messaggio)),
                        );
                        //Se la prenotazione ha successo, ricarichiamo la lista aggiornata
                        if (successo) {
                          _caricaDati(); 
                        }
                      }
                    },
                  );
                },
                child: _inPrenotazione 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Text("CONFERMA"),
              ),
            ],
          );
        },
      ),
    );
  }

  //mostra un popup di avviso per permettere all'utente di cancellare una prenotazione già effettuata
  void _mostraPopupAnnulla(String id) {
    showDialog(
      context: context,
      barrierDismissible: !_inPrenotazione,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Annulla Prenotazione"),
            content: const Text("Vuoi davvero annullare la prenotazione per questo elemento?"),
            actions: [
              TextButton(
                onPressed: _inPrenotazione ? null : () => Navigator.pop(context),
                child: const Text("NO"),
              ),
              TextButton(
                onPressed: _inPrenotazione ? null : () async {
                  setDialogState(() => _inPrenotazione = true);
                  
                  final utenteViewModel = Provider.of<UtenteViewModel>(context, listen: false);
                  final prenotaViewModel = Provider.of<PrenotaViewModel>(context, listen: false);

                  final cf = utenteViewModel.utenteLoggato?.codiceFiscale;
                  if (cf == null) return;

                  //Chiamata al metodo di cancellazione nel ViewModel
                  await prenotaViewModel.annullaPrenotazione(
                    _tabController.index,
                    id,
                    cf,
                    (successo, messaggio) {
                      //stessa verifica per l'annullamento: procedo solo se il widget esiste ancora
                      if (mounted) {
                        setDialogState(() => _inPrenotazione = false);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(messaggio)),
                        );
                        //Ricarichiamo i dati per rendere l'elemento nuovamente prenotabile (tornerà nero)
                        if (successo) {
                          _caricaDati();
                        }
                      }
                    },
                  );
                },
                child: _inPrenotazione
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("SÌ, ANNULLA"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double larghezzaSchermo = MediaQuery.of(context).size.width;
    final bool isCompatto = larghezzaSchermo < 600;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildTitolo(isCompatto),
                const SizedBox(height: 16),
                _buildSelettoreTabs(),
                const SizedBox(height: 16),
                _buildSottotitolo(),
                const SizedBox(height: 16),
                //L'area del contenuto è espandibile per occupare tutto lo spazio verticale utile
                Expanded(child: _buildContenuto()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //settiamo il titolo della pagina e gestiamo l'icona menu per la navigazione su tablet
  Widget _buildTitolo(bool isCompatto) {
    return Row(
      children: [
        if (!isCompatto && widget.onMenuClick != null)
          IconButton(
            onPressed: widget.onMenuClick,
            icon: const Icon(Icons.menu),
          ),
        const Text(
          "Prenota",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  //disegna il selettore a tab personalizzato per switchare tra le categorie "Esami" e "Guide"
  Widget _buildSelettoreTabs() {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(28),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
        tabs: const [
          Tab(text: "Esami"),
          Tab(text: "Guide"),
        ],
      ),
    );
  }

  //mostra un testo di guida dinamico che varia in base alla disponibilità degli elementi caricati
  Widget _buildSottotitolo() {
    if (_inCaricamento || _erroreCaricamento) return const SizedBox.shrink();

    String testo = "";
    if (_tabController.index == 0) {
      testo = _listaEsami.isEmpty ? "Nessun esame disponibile" : "Scegli un esame da prenotare";
    } else {
      testo = _listaGuide.isEmpty ? "Nessuna guida disponibile" : "Scegli una guida da prenotare";
    }

    return Text(
      testo,
      style: TextStyle(fontSize: 16, color: Colors.black.withValues(alpha: 0.8)),
    );
  }

  //gestisce il corpo della pagina caricando la ListView corretta o l'indicatore di caricamento
  Widget _buildContenuto() {
    if (_inCaricamento) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erroreCaricamento) {
      return Center(
        child: Text(
          _tabController.index == 0 ? "Errore caricamento esami" : "Errore caricamento guide",
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    //Seleziono la lista di dati da visualizzare in base all'indice del TabController
    final items = _tabController.index == 0 ? _listaEsami : _listaGuide;

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        //Rendering dinamico: costruisco la riga passando parametri specifici per Esame o Guida
        if (item is Esame) {
          return _buildRigaPrenotazione(
            id: item.idEsame,
            titolo: "Esame ${item.tipologia} (Cat. ${item.categoriaPatente})",
            data: item.data,
            ora: "${item.oraInizio}-${item.oraFine}",
            isPrenotato: _elementiPrenotati.contains(item.idEsame),
          );
        } else if (item is SlotGuida) {
          return _buildRigaPrenotazione(
            id: item.idGuida,
            titolo: "Guida (${item.istruttore})",
            data: item.data,
            ora: "${item.oraInizio}-${item.oraFine}",
            isPrenotato: _elementiPrenotati.contains(item.idGuida),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  //costruisce la riga interattiva della lista: cambia colore (verde) se l'elemento è già stato prenotato
  Widget _buildRigaPrenotazione({
    required String id,
    required String titolo,
    required DateTime data,
    required String ora,
    required bool isPrenotato,
  }) {
    final formatData = DateFormat('EEE d MMM', 'it_IT');
    //Se l'elemento è già prenotato, usiamo il verde e l'icona spunta, altrimenti nero e orologio
    final Color colorePrincipale = isPrenotato ? Colors.green : Colors.black;
    final IconData iconaStato = isPrenotato ? Icons.check : Icons.access_time;

    //Sostanzialmente, questa funzione mostra l'effetto onda al tocco (InkWell) per rendere la riga cliccabile
    return InkWell(
      /*Se l'elemento non è ancora prenotato, apre il popup di conferma.
      Se è già prenotato, apre il popup per permetterne l'annullamento (RNF5)*/
      onTap: () => isPrenotato ? _mostraPopupAnnulla(id) : _mostraPopupConferma(id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            //Icona indicativa dello stato della prenotazione
            Icon(iconaStato, color: colorePrincipale, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titolo,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: colorePrincipale,
                    ),
                  ),
                  Text(
                    "${formatData.format(data)}, $ora",
                    style: TextStyle(
                      fontSize: 15,
                      color: colorePrincipale.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            //Mostra una freccia verso destra solo se l'elemento è ancora prenotabile
            if (!isPrenotato)
              const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
